//
//  UserProfile.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

struct UserProfile: Hashable, Identifiable {
    let id: UUID
    let username: String
    let avatarURL: String?
    var bio: String
    var followers: Int
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool{
        return lhs.id == rhs.id
    }
}
