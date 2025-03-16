//
//  NetworkService.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import Foundation

enum NetworkError: Error{
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case unknownError(Error)
    
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

protocol NetworkServiceProtocol {
    func fetchAllHeroes() async throws -> [Superhero]
    func fetchHero(byId id: Int) async throws -> Superhero
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://akabab.github.io/superhero-api/api"
    
    func fetchAllHeroes() async throws -> [Superhero] {
        guard let url = URL(string: "\(baseURL)/all.json") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode([Superhero].self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    func fetchHero(byId id: Int) async throws -> Superhero {
        guard let url = URL(string: "\(baseURL)/id/\(id).json") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(Superhero.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
}
