//
//  FeedSystem.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

class FeedSystem: ObservableObject {
    @Published private(set) var userCache: [UUID: UserProfile] = [:]
    @Published private(set) var feedPosts: [Post] = []
    @Published private(set) var hashtags: Set<String> = []
    
    func addPost(_ post: Post) {
        feedPosts.insert(post, at: 0)
        recalculateHashtags()
    }
    
    func removePost(_ post: Post) {
        if let index = feedPosts.firstIndex(of: post){
            feedPosts.remove(at: index)
            recalculateHashtags()
        }
    }
    
    func addUser(_ user: UserProfile) {
        userCache[user.id] = user
    }

    func getUser(id: UUID) -> UserProfile? {
        return userCache[id]
    }
    
    private func recalculateHashtags() {
        hashtags = Set(feedPosts.flatMap { $0.hashtags })
    }
}
