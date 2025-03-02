//
//  FeedViewModel.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

class FeedViewModel: ObservableObject {
    @Published private var feedSystem = FeedSystem()
    
    var posts: [Post] {feedSystem.feedPosts}
    var hashtags: [String] {Array(feedSystem.hashtags)}
    
    func addPost(content: String, author: UserProfile, hashtags: [String], imageLink: String){
        let newPost = Post(id: UUID(), authorId: author.id, imageLink: URL(string: imageLink), content: content, hashtags: hashtags, likes: 0, timestamp: Date.now)
        feedSystem.addPost(newPost)
    }

    func removePost(_ post: Post) {
        feedSystem.removePost(post)
    }
    
    func addUser(_ user: UserProfile){
        feedSystem.addUser(user)
    }
}
