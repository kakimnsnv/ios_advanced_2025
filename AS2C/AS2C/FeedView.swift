//
//  FeedView.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//


import SwiftUI

struct FeedView: View {
    // MARK: - Properties
    
    /// Feed system for post management
    @ObservedObject var feedSystem: FeedSystem
    
    /// Profile manager for user data
    @ObservedObject var profileManager: ProfileManager
    
    /// State for new post creation
    @State private var newPostContent = ""
    @State private var newPostImageUrl = ""
    @State private var isShowingNewPostSheet = false
    
    /// Loading states
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    /// Refresh control state
    @State private var isRefreshing = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading && feedSystem.feedPosts.isEmpty {
                    ProgressView("Loading feed...")
                } else if let error = errorMessage, feedSystem.feedPosts.isEmpty {
                    errorView(message: error)
                } else {
                    feedListView
                }
            }
            .navigationTitle("Social Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingNewPostSheet = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $isShowingNewPostSheet) {
                newPostView
            }
            .onAppear {
                loadFeed()
            }
        }
    }
    
    // MARK: - Feed List View
    private var feedListView: some View {
        List {
            ForEach(feedSystem.feedPosts) { post in
                PostView(post: post, profileManager: profileManager)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .padding(.horizontal)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await refreshFeed()
        }
    }
    
    // MARK: - New Post View
    private var newPostView: some View {
        NavigationView {
            Form {
                Section(header: Text("New Post")) {
                    TextField("What's on your mind?", text: $newPostContent)
                        .frame(height: 100, alignment: .top)
                        .multilineTextAlignment(.leading)
                    
                    TextField("Image URL (optional)", text: $newPostImageUrl)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                    
                    if !newPostImageUrl.isEmpty, let url = URL(string: newPostImageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Text("Invalid image URL")
                                    .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isShowingNewPostSheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createNewPost()
                    }
                    .disabled(newPostContent.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error loading feed")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                loadFeed()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Methods
    
    /// Loads the feed posts
    private func loadFeed() {
        isLoading = true
        errorMessage = nil
        
        _ = feedSystem.fetchPosts()
            .sink(receiveCompletion: { completion in
                isLoading = false
                
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                }
            }, receiveValue: { posts in
                feedSystem.feedPosts = posts 
                isLoading = false
            })
    }
    
    /// Refreshes the feed (for pull-to-refresh)
    private func refreshFeed() async {
        await withCheckedContinuation { continuation in
            _ = feedSystem.fetchPosts()
                .sink(receiveCompletion: { _ in
                    continuation.resume()
                }, receiveValue: { _ in })
        }
    }
    
    /// Creates a new post
    private func createNewPost() {
        guard let currentUser = profileManager.activeProfiles.values.first else {
            // In a real app, you'd handle this with proper user authentication
            errorMessage = "No active user profile found"
            return
        }
        
        // Create the new post
        var imageUrl: URL? = nil
        if !newPostImageUrl.isEmpty, let url = URL(string: newPostImageUrl) {
            imageUrl = url
        }
        
        let newPost = Post(
            authorId: currentUser.id,
            content: newPostContent,
            imageUrl: imageUrl
        )
        
        // Add post to feed
        _ = feedSystem.addPost(newPost)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                }
                
                // Close the sheet regardless of success/failure
                isShowingNewPostSheet = false
                
                // Reset form
                newPostContent = ""
                newPostImageUrl = ""
            }, receiveValue: { _ in
                // Post added successfully
            })
    }
}
