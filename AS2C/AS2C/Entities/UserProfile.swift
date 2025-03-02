//
//  UserProfile.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//


import Foundation
import SwiftUI

struct UserProfile: Identifiable, Hashable, Equatable, Codable {
    let id: UUID
    let username: String
    var avatarUrl: URL?
    var bio: String
    var followers: Int
    
    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        // Only use immutable properties for hashing to ensure hash value doesn't change
        // during the lifetime of the object
        hasher.combine(id)
    }
    
    // MARK: - Equatable Implementation
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        // Two profiles are considered equal if they have the same ID
        // This is sufficient because IDs are unique
        return lhs.id == rhs.id
    }
    
    // MARK: - Initializers
    init(id: UUID = UUID(), username: String, avatarUrl: URL? = nil, bio: String = "", followers: Int = 0) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.followers = followers
    }
}
