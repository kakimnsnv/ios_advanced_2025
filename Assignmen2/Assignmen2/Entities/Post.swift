//
//  Post.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

struct Post: Hashable, Identifiable {
    let id: UUID
    let authorId: UUID
    let imageLink: URL?
    let content: String
    let hashtags: [String]
    var likes: Int
    let timestamp: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}
