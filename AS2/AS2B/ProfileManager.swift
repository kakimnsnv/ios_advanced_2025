//
//  ProfileManager.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

/// Manages user profiles in memory.
class ProfileManager: ObservableObject {
    @Published private var profilesDict: [UUID: UserProfile] = [:]
    
    weak var delegate: ProfileManagerDelegate?
    
    func addProfile(username: String, avatarURL: String?, bio: String) {
        let newProfile = UserProfile(id: UUID(), username: username, avatarURL: avatarURL, bio: bio, followers: 0)
        profilesDict[newProfile.id] = newProfile
        delegate?.didAddProfile(newProfile)
    }
        
        /// Provides an array of user profiles.
    var profiles: [UserProfile] {
        return Array(profilesDict.values)
    }
        
        /// Retrieves a profile by its ID.
    func profile(for id: UUID) -> UserProfile? {
        return profilesDict[id]
    }
}
