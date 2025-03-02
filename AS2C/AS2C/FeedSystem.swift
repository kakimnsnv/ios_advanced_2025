//
//  FeedSystem.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//
import Foundation
import Combine

class FeedSystem: ObservableObject {
    // MARK: - Collection Choices and Explanations
    
    /// Cache for user profiles indexed by user ID
    /// - Dictionary chosen for O(1) access time when looking up by ID
    /// - Use case: Quick profile lookup when rendering posts
    @Published  var userCache: [String: UserProfile] = [:]
    
    /// Ordered array of posts for the feed
    /// - Array chosen over LinkedList for:
    ///   1. Better cache locality for scrolling through feed
    ///   2. SwiftUI's List works well with arrays
    ///   3. Frequent insertions at beginning are handled efficiently with insert(at:0)
    /// - For very large feeds, we can implement pagination
    @Published var feedPosts: [Post] = []
    
    /// Collection of unique hashtags
    /// - Set chosen for:
    ///   1. O(1) insertion and lookup
    ///   2. Automatic handling of duplicates
    ///   3. Fast membership testing when filtering posts
    @Published  var hashtags: Set<String> = []
    
    /// Dictionary for hashtag-based post lookups
    /// - Dictionary with array values chosen for:
    ///   1. O(1) lookup of posts by hashtag
    ///   2. Maintaining multiple posts per hashtag
    private var hashtagPosts: [String: [Post]] = [:]
    
    // MARK: - Dependencies
    
    /// Profile manager for user data
    private let profileManager: ProfileManager
    
    /// URL session for network requests
    private let urlSession = URLSession.shared
    
    /// API base URL for post operations
    private let apiBaseURL = "localhost:8080/api/v1/posts"
    
    /// Set of subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
        
        // Subscribe to profile updates to keep cache in sync
        profileManager.onProfileUpdate = { [weak self] profile in
            guard let self = self else { return }
            self.userCache[profile.id.uuidString] = profile
        }
    }
    
    // MARK: - Post Management
    
    /// Adds a post to the feed
    /// - Parameter post: The post to add
    /// - Returns: A publisher that emits the added post or an error
    func addPost(_ post: Post) -> AnyPublisher<Post, Error> {
        // Create API request
        guard let url = URL(string: apiBaseURL) else {
            return Fail(error: NSError(domain: "FeedSystem", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(post)
            request.httpBody = jsonData
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "FeedSystem", code: 400, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                }
                return data
            }
            .decode(type: Post.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] newPost in
                guard let self = self else { return }
                
                // Add to the beginning of the feed (most recent first)
                DispatchQueue.main.async {
                    self.feedPosts.insert(newPost, at: 0)
                    
                    // Extract and store hashtags
                    let postHashtags = self.extractHashtags(from: newPost.content)
                    self.hashtags.formUnion(postHashtags)
                    
                    // Update hashtag-post mapping
                    for hashtag in postHashtags {
                        if var posts = self.hashtagPosts[hashtag] {
                            posts.append(newPost)
                            self.hashtagPosts[hashtag] = posts
                        } else {
                            self.hashtagPosts[hashtag] = [newPost]
                        }
                    }
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Removes a post from the feed
    /// - Parameter post: The post to remove
    /// - Returns: A publisher that completes when the post is removed or emits an error
    func removePost(_ post: Post) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(apiBaseURL)/\(post.id.uuidString)") else {
            return Fail(error: NSError(domain: "FeedSystem", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { _, response -> Void in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "FeedSystem", code: 400, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                }
                return ()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    // Remove from feed posts
                    self.feedPosts.removeAll { $0.id == post.id }
                    
                    // Extract hashtags from the post
                    let postHashtags = self.extractHashtags(from: post.content)
                    
                    // Update hashtag-post mapping
                    for hashtag in postHashtags {
                        if var posts = self.hashtagPosts[hashtag] {
                            posts.removeAll { $0.id == post.id }
                            
                            if posts.isEmpty {
                                self.hashtagPosts.removeValue(forKey: hashtag)
                                self.hashtags.remove(hashtag)
                            } else {
                                self.hashtagPosts[hashtag] = posts
                            }
                        }
                    }
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Fetches posts for the feed
    /// - Parameter limit: Maximum number of posts to fetch
    /// - Returns: A publisher that emits an array of posts or an error
    func fetchPosts(limit: Int = 20) -> AnyPublisher<[Post], Error> {
        DispatchQueue.main.async {
            // Sort posts by timestamp (newest first)
            let sortedPosts = posts.sorted { $0.timestamp > $1.timestamp }
            self.feedPosts = sortedPosts
            
            // Extract and store hashtags
            var allHashtags = Set<String>()
            var hashtagToPostsMap = [String: [Post]]()
            
            for post in posts {
                let postHashtags = self.extractHashtags(from: post.content)
                allHashtags.formUnion(postHashtags)
                
                for hashtag in postHashtags {
                    if var postsForHashtag = hashtagToPostsMap[hashtag] {
                        postsForHashtag.append(post)
                        hashtagToPostsMap[hashtag] = postsForHashtag
                    } else {
                        hashtagToPostsMap[hashtag] = [post]
                    }
                }
            }
            
            self.hashtags = allHashtags
            self.hashtagPosts = hashtagToPostsMap
            
            // Preload author profiles
            self.preloadAuthors(for: posts)
        }
    }
    
    /// Fetches posts by a specific author
    /// - Parameter authorId: The ID of the author
    /// - Returns: A publisher that emits an array of posts or an error
    func fetchPosts(by authorId: UUID) -> AnyPublisher<[Post], Error> {
        guard let url = URL(string: "\(apiBaseURL)?authorId=\(authorId.uuidString)") else {
            return Fail(error: NSError(domain: "FeedSystem", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "FeedSystem", code: 400, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                }
                return data
            }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Fetches posts containing a specific hashtag
    /// - Parameter hashtag: The hashtag to search for (without # symbol)
    /// - Returns: An array of posts containing the hashtag
    func posts(withHashtag hashtag: String) -> [Post] {
        return hashtagPosts[hashtag] ?? []
    }
    
    // MARK: - Helper Methods
    
    /// Extracts hashtags from a post's content
    /// - Parameter content: The post content to analyze
    /// - Returns: A set of hashtags (without # symbol)
    private func extractHashtags(from content: String) -> Set<String> {
        let words = content.components(separatedBy: .whitespacesAndNewlines)
        let hashtags = words.filter { $0.hasPrefix("#") }
            .map { String($0.dropFirst()) } // Remove # symbol
            .filter { !$0.isEmpty }
        
        return Set(hashtags)
    }
    
    /// Preloads author profiles for a collection of posts
    /// - Parameter posts: Posts whose authors should be preloaded
    private func preloadAuthors(for posts: [Post]) {
        let authorIds = Set(posts.map { $0.authorId.uuidString })
        
        for authorId in authorIds {
            // Skip if already cached
            if userCache[authorId] != nil {
                continue
            }
            
            // Load author profile
            profileManager.loadProfile(id: authorId) { [weak self] result in
                guard let self = self, case .success(let profile) = result else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.userCache[authorId] = profile
                }
            }
        }
    }
}
