//
//  FeedView.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

struct FeedView: View {
    @EnvironmentObject var postManager: PostManager
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        NavigationView {
            List {
                ForEach(postManager.posts.sorted(by: { $0.timestamp > $1.timestamp })) { post in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if let author = profileManager.profile(for: post.authorId) {
                                Text(author.username)
                                    .font(.headline)
                            } else {
                                Text("Unknown Author")
                                    .font(.headline)
                            }
                            Spacer()
                            Text(post.timestamp, style: .time)
                                .font(.caption)
                        }
                        if let imageURL = post.imageLink {
                            RemoteImage(url: imageURL)
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        }
                        Text(post.content)
                            .font(.body)
                        if !post.hashtags.isEmpty {
                            Text(post.hashtags.map { "#\($0)" }.joined(separator: " "))
                                .foregroundColor(.blue)
                        }
                        HStack {
                            Button(action: {
                                postManager.likePost(post: post)
                            }) {
                                Image(systemName: "hand.thumbsup")
                            }
                            Text("\(post.likes)")
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Feed")
        }
    }
}
