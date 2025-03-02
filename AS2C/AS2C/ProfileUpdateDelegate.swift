//
//  ProfileUpdateDelegate.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//


import Foundation
import SwiftUI

/// Protocol defining methods for handling profile update events
/// AnyObject constraint restricts conformance to reference types only, which is necessary
/// for using weak references to avoid retain cycles when delegates are used
protocol ProfileUpdateDelegate: AnyObject {
    /// Called when a profile has been successfully updated
    /// - Parameter profile: The updated user profile
    func profileDidUpdate(_ profile: UserProfile)
    
    /// Called when an error occurs during profile loading
    /// - Parameter error: The error that occurred
    func profileLoadingError(_ error: Error)
}

/// Custom error types for profile operations
enum ProfileError: Error {
    case networkError
    case invalidResponse
    case decodingError
    case profileNotFound
    case invalidURL
    
    var localizedDescription: String {
        switch self {
        case .networkError: return "Network connection error"
        case .invalidResponse: return "Invalid server response"
        case .decodingError: return "Could not decode profile data"
        case .profileNotFound: return "Profile not found"
        case .invalidURL: return "Invalid profile URL"
        }
    }
}

/// Manages user profiles and handles profile loading operations
class ProfileManager: ObservableObject {
    /// Dictionary to store active user profiles with their IDs as keys
    /// Dictionary chosen for O(1) lookup performance when accessing profiles by ID
    @Published private(set) var activeProfiles: [String: UserProfile] = [:]
    
    /// Delegate to receive profile update notifications
    /// Weak reference to prevent retain cycles between ProfileManager and its delegate
    weak var delegate: ProfileUpdateDelegate?
    
    /// Closure called when a profile is updated
    /// Using a closure provides a flexible alternative to the delegate pattern
    var onProfileUpdate: ((UserProfile) -> Void)?
    
    /// API base URL for profile operations
    private let apiBaseURL = "localhost:8080/api/v1/profiles"
    
    /// Shared URL session for network requests
    private let urlSession = URLSession.shared
    
    /// Initializes a new ProfileManager with the specified delegate
    /// - Parameter delegate: The delegate that will receive profile update notifications
    init(delegate: ProfileUpdateDelegate? = nil) {
        self.delegate = delegate
    }
    
    /// Loads a user profile by ID from the network
    /// - Parameters:
    ///   - id: The unique identifier of the profile to load
    ///   - completion: Closure called with the result of the loading operation
    func loadProfile(id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "\(apiBaseURL)/\(id)") else {
            completion(.failure(ProfileError.invalidURL))
            return
        }
        
        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            // Using [weak self] to prevent retain cycle
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.profileLoadingError(error)
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let error = ProfileError.invalidResponse
                DispatchQueue.main.async {
                    self.delegate?.profileLoadingError(error)
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = ProfileError.invalidResponse
                DispatchQueue.main.async {
                    self.delegate?.profileLoadingError(error)
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    self.activeProfiles[id] = profile
                    self.delegate?.profileDidUpdate(profile)
                    self.onProfileUpdate?(profile)
                    completion(.success(profile))
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.profileLoadingError(ProfileError.decodingError)
                    completion(.failure(ProfileError.decodingError))
                }
            }
        }
        
        task.resume()
    }
    
    /// Creates a new user profile
    /// - Parameters:
    ///   - profile: Profile to create
    ///   - completion: Closure called with the result of the creation operation
    func createProfile(profile: UserProfile, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: apiBaseURL) else {
            completion(.failure(ProfileError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(profile)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(ProfileError.invalidResponse))
                }
                return
            }
            
            do {
                let createdProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    let idString = createdProfile.id.uuidString
                    self.activeProfiles[idString] = createdProfile
                    self.delegate?.profileDidUpdate(createdProfile)
                    self.onProfileUpdate?(createdProfile)
                    completion(.success(createdProfile))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(ProfileError.decodingError))
                }
            }
        }
        
        task.resume()
    }
    
    /// Updates an existing user profile
    /// - Parameters:
    ///   - profile: Updated profile data
    ///   - completion: Closure called with the result of the update operation
    func updateProfile(profile: UserProfile, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        let idString = profile.id.uuidString
        guard let url = URL(string: "\(apiBaseURL)/\(idString)") else {
            completion(.failure(ProfileError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(profile)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(ProfileError.invalidResponse))
                }
                return
            }
            
            do {
                let updatedProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    self.activeProfiles[idString] = updatedProfile
                    self.delegate?.profileDidUpdate(updatedProfile)
                    self.onProfileUpdate?(updatedProfile)
                    completion(.success(updatedProfile))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(ProfileError.decodingError))
                }
            }
        }
        
        task.resume()
    }
}
