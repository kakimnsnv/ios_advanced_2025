//
//  Post.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//


import Foundation
import SwiftUI

struct Post: Identifiable, Hashable, Equatable, Codable {
    let id: UUID
    let authorId: UUID
    var content: String
    var imageUrl: URL?
    var likes: Int
    var timestamp: Date
    
    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        // Only use immutable properties for hashing
        hasher.combine(id)
    }
    
    // MARK: - Equatable Implementation
    static func == (lhs: Post, rhs: Post) -> Bool {
        // Posts are equal if they have the same ID
        return lhs.id == rhs.id
    }
    
    // MARK: - Initializers
    init(id: UUID = UUID(), authorId: UUID, content: String, imageUrl: URL? = nil, likes: Int = 0, timestamp: Date = Date()) {
        self.id = id
        self.authorId = authorId
        self.content = content
        self.imageUrl = imageUrl
        self.likes = likes
        self.timestamp = timestamp
    }
}
