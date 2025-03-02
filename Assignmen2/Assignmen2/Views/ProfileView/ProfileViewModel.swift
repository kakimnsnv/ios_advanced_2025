//
//  ProfileViewModel.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

class ProfileViewModel: ObservableObject, ProfileUpdateDelegate {
    @Published var profile: UserProfile?
    @Published var errorMessage: String?
    @ObservedObject var profileManager: ProfileManager
    
    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
        self.profileManager.delegate = self
    }
    
    var onProfileUpdate: ((UserProfile) -> Void)?
    
    /// Initiates loading of a profile by username.
    func loadProfile(username: String) {
        profileManager.loadProfile(username: username)
    }
    
    func profileDidUpdate(_ profile: UserProfile) {
        DispatchQueue.main.async{
            self.errorMessage = nil
            self.profile = profile
            self.onProfileUpdate?(profile)
        }
    }
    
    func profileLoadingError(_ error: Error) {
        DispatchQueue.main.async {
            self.profile = nil
            self.errorMessage = error.localizedDescription
        }
    }
}
