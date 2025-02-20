//
//  PostManager.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

/// Manages posts in memory.
class PostManager: ObservableObject {
    // Dictionary keyed by UUID for O(1) lookups.
    @Published private var postsDict: [UUID: Post] = [:]
    
    weak var delegate: PostManagerDelegate?
    
    /// Adds a new post.
    func addPost(authorId: UUID, imageLink: URL?, content: String, hashtags: [String]) {
        let newPost = Post(id: UUID(), authorId: authorId, imageLink: imageLink, content: content, hashtags: hashtags, likes: 0, timestamp: Date())
        postsDict[newPost.id] = newPost
        delegate?.didAddPost(newPost)
    }
    
    /// Increments the like count for a given post.
    func likePost(post: Post) {
        guard var currentPost = postsDict[post.id] else { return }
        currentPost.likes += 1
        postsDict[currentPost.id] = currentPost
        delegate?.didLikePost(currentPost)
    }
    
    /// Provides an array of posts.
    var posts: [Post] {
        return Array(postsDict.values)
    }
}
