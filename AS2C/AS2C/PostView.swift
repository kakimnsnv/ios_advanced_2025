//
//  PostView.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//


import SwiftUI

struct PostView: View {
    // MARK: - Properties
    /// The post to display
    let post: Post
    
    /// Profile manager to fetch author details
    @ObservedObject var profileManager: ProfileManager
    
    /// Image loader for post images
    /// Using StateObject to create and own the image loader for this view's lifecycle
    @StateObject private var imageLoader = ImageLoader()
    
    /// State to store the author profile
    @State private var author: UserProfile?
    
    /// Tracks if the post is liked
    @State private var isLiked = false
    
    /// Counts local likes (for optimistic UI updates)
    @State private var likeCount: Int
    
    /// Loading state for author profile
    @State private var isLoadingAuthor = false
    
    // MARK: - Initialization
    init(post: Post, profileManager: ProfileManager) {
        self.post = post
        self.profileManager = profileManager
        self._likeCount = State(initialValue: post.likes)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack(spacing: 12) {
                // Author Avatar
                if let author = author, let avatarUrl = author.avatarUrl {
                    AsyncImage(url: avatarUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 40, height: 40)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    if isLoadingAuthor {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(author?.username ?? "Loading...")
                        .font(.headline)
                    
                    Text(formatDate(post.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Post Content
            Text(post.content)
                .font(.body)
                .padding(.vertical, 8)
            
            // Post Image (if available)
            if let imageUrl = post.imageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.gray.opacity(0.1))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Image failed to load")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(8)
            }
            
            // Engagement Section
            HStack(spacing: 20) {
                Button(action: toggleLike) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .primary)
                        Text("\(likeCount)")
                    }
                }
                
                Button(action: {
                    // Share functionality would go here
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                }
                
                Spacer()
            }
            .font(.subheadline)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            loadAuthor()
        }
    }
    
    // MARK: - Methods
    
    /// Loads the author profile for this post
    private func loadAuthor() {
        let authorIdString = post.authorId.uuidString
        
        // Check if the profile is already cached
        if let cachedProfile = profileManager.activeProfiles[authorIdString] {
            author = cachedProfile
            return
        }
        
        // Load profile from network
        isLoadingAuthor = true
        profileManager.loadProfile(id: authorIdString) { result in
            isLoadingAuthor = false
            
            switch result {
            case .success(let profile):
                author = profile
            case .failure:
                // Handle error silently, keeping the placeholder UI
                break
            }
        }
    }
    
    /// Toggles the like state of the post
    private func toggleLike() {
        // Optimistic UI update
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        
        // In a real app, you would call an API to update the like status
        // updateLikeStatus(postId: post.id, isLiked: isLiked)
    }
    
    /// Formats the post date
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// Preview provider for PostView
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePost = Post(
            authorId: UUID(),
            content: "This is a sample post content with some text to show how the post view looks like.",
            imageUrl: URL(string: "https://example.com/image.jpg"),
            likes: 42,
            timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
        )
        
        return PostView(post: samplePost, profileManager: ProfileManager())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}