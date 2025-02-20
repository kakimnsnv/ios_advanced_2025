//
//  NewPostView.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

struct NewPostView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var postManager: PostManager
    @State private var selectedUser: UserProfile?
    @State private var content: String = ""
    @State private var imageURL: String = ""
    @State private var hashtags: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select User")) {
                    if profileManager.profiles.isEmpty {
                        Text("No users available. Please add a user first.")
                    } else {
                        Picker("User", selection: $selectedUser) {
                            ForEach(profileManager.profiles) { user in
                                Text(user.username).tag(Optional(user))
                            }
                        }
                    }
                }
                
                Section(header: Text("Post Content")) {
                    TextField("Content", text: $content)
                    TextField("Image URL", text: $imageURL)
                    TextField("Hashtags (comma separated)", text: $hashtags)
                }
            }
            .navigationTitle("New Post")
            .navigationBarItems(trailing: Button("Post") {
                if let user = selectedUser {
                    let hashtagArray = hashtags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    let imageLink = URL(string: imageURL)
                    postManager.addPost(authorId: user.id, imageLink: imageLink, content: content, hashtags: hashtagArray)
                    
                    // Reset form fields after posting
                    content = ""
                    imageURL = ""
                    hashtags = ""
                }
            })
        }
    }
}
