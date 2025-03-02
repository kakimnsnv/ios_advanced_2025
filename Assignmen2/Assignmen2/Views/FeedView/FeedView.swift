//
//  FeedView 2.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @EnvironmentObject var profileManager :ProfileManager
    @EnvironmentObject var imageLoader :ImageLoader

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.posts) { post in
                        VStack(alignment: .leading) {
                            Text(post.content)
                                .font(.body)
                            Text(post.hashtags.joined(separator: " "))
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(post.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    .onDelete(perform: deletePost)
                }
                
                Button("Add Sample Post") {
                    viewModel.addPost(content: "Hello, SwiftUI!", author: UserProfile(id: UUID(), username: "Stirng", avatarURL: "https://avatars.githubusercontent.com/u/84794256?v=4", bio: "BIOOOO", followers: 0), hashtags: ["#swift", "#ios"], imageLink:"https://avatars.githubusercontent.com/u/84794256?v=4")
                }
                .padding()
            }
            .navigationTitle("Feed")
        }
    }

    private func deletePost(at offsets: IndexSet) {
        for index in offsets {
            viewModel.removePost(viewModel.posts[index])
        }
    }
}


//import SwiftUI
//
//struct FeedView: View {
//    @StateObject private var viewModel = FeedViewModel()
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                List {
//                    ForEach(viewModel.feedSystem.feedPosts) { post in
//                        PostRowView(post: post)
//                    }
//                    .onDelete(perform: deletePost)
//                }
//                .listStyle(PlainListStyle())
//                Button(action: {
//                    viewModel.addRandomPost()
//                }) {
//                    Text("Add Random Post")
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        .padding([.leading, .trailing], 16)
//                }
//            }
//            .navigationTitle("Feed")
//        }
//    }
//    
//    /// Deletes posts from the feed.
//    func deletePost(at offsets: IndexSet) {
//        for index in offsets {
//            let post = viewModel.feedSystem.feedPosts[index]
//            viewModel.removePost(post)
//        }
//    }
//}

#Preview{
    FeedView()
}
