//
//  PostManager.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

/// Manages posts in memory.
class PostManager: ObservableObject {
    @Published var posts: [Post] = []
    
    /// Adds a new post.
    func addPost(authorId: UUID, imageLink: URL?, content: String, hashtags: [String]) {
        let newPost = Post(id: UUID(), authorId: authorId, imageLink: imageLink, content: content, hashtags: hashtags, likes: 0, timestamp: Date())
        posts.append(newPost)
    }
    
    /// Increments the like count for a given post.
    func likePost(post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].likes += 1
        }
    }
}
