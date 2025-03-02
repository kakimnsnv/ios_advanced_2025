//
//  ProfileManager.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

/// Manages user profiles in memory.
class ProfileManager: ObservableObject {
    @Published var profiles: [UserProfile] = []
    
    /// Adds a new user profile.
    func addProfile(username: String, avatarURL: String?, bio: String) {
        let newUser = UserProfile(id: UUID(), username: username, avatarURL: avatarURL, bio: bio, followers: 0)
        profiles.append(newUser)
    }
}
