//
//  UserProfileView.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//


import SwiftUI

struct UserProfileView: View {
    // MARK: - Properties
    /// Profile manager responsible for loading and updating profiles
    /// Using ObservedObject to observe changes to the ProfileManager
    @ObservedObject var profileManager: ProfileManager
    
    /// Image loader for profile avatars
    /// Using StateObject to create and own the image loader for this view's lifecycle
    @StateObject private var imageLoader = ImageLoader()
    
    /// Currently displayed profile
    @State private var profile: UserProfile?
    
    /// Loading state
    @State private var isLoading = false
    
    /// Error message
    @State private var errorMessage: String?
    
    /// Form fields for profile editing
    @State private var username = ""
    @State private var bio = ""
    @State private var avatarUrlString = ""
    
    /// Profile ID to load
    var profileId: String?
    
    // MARK: - Initialization
    init(profileManager: ProfileManager, profileId: String? = nil) {
        self.profileManager = profileManager
        self.profileId = profileId
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMsg = errorMessage {
                    errorView(message: errorMsg)
                } else if let profile = profile {
                    profileView(profile)
                } else {
                    createProfileForm
                }
            }
            .padding()
        }
        .navigationTitle(profile != nil ? "Profile: \(profile!.username)" : "Create Profile")
        .onAppear {
            setupProfileManager()
            if let profileId = profileId {
                loadProfile(id: profileId)
            }
        }
    }
    
    // MARK: - Profile View
    @ViewBuilder
    private func profileView(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Profile header with avatar
            HStack(spacing: 12) {
                if let avatarUrl = profile.avatarUrl {
                    AsyncImage(url: avatarUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.username)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(profile.followers) followers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Bio section
            Text("Bio")
                .font(.headline)
            
            Text(profile.bio)
                .font(.body)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Divider()
            
            // Edit form
            VStack(alignment: .leading, spacing: 12) {
                Text("Edit Profile")
                    .font(.headline)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Bio", text: $bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Avatar URL", text: $avatarUrlString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                
                Button("Update Profile") {
                    updateProfile()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Create Profile Form
    private var createProfileForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create a New Profile")
                .font(.headline)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Bio", text: $bio)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Avatar URL", text: $avatarUrlString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.URL)
                .autocapitalization(.none)
            
            Button("Create Profile") {
                createNewProfile()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Error View
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error loading profile")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                if let profileId = profileId {
                    loadProfile(id: profileId)
                } else {
                    errorMessage = nil
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Methods
    
    /// Sets up the profile manager
    private func setupProfileManager() {
        // Setup closure for profile updates
        profileManager.onProfileUpdate = { [ self] updatedProfile in
            // Using weak self to prevent retain cycle
//            guard let self = self else { return }
            self.profile = updatedProfile
            self.username = updatedProfile.username
            self.bio = updatedProfile.bio
            self.avatarUrlString = updatedProfile.avatarUrl?.absoluteString ?? ""
        }
    }
    
    /// Loads a profile by ID
    private func loadProfile(id: String) {
        isLoading = true
        errorMessage = nil
        
        profileManager.loadProfile(id: id) { result in
            self.isLoading = false
            
            switch result {
            case .success(let loadedProfile):
                self.profile = loadedProfile
                self.username = loadedProfile.username
                self.bio = loadedProfile.bio
                self.avatarUrlString = loadedProfile.avatarUrl?.absoluteString ?? ""
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Updates the current profile
    private func updateProfile() {
        guard var updatedProfile = profile else { return }
        
        // Update profile fields
        updatedProfile.bio = bio
        if let url = URL(string: avatarUrlString) {
            updatedProfile.avatarUrl = url
        }
        
        isLoading = true
        errorMessage = nil
        
        profileManager.updateProfile(profile: updatedProfile) { result in
            self.isLoading = false
            
            switch result {
            case .success(let updated):
                self.profile = updated
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Creates a new profile
    private func createNewProfile() {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            return
        }
        
        // Create avatar URL if provided
        var avatarUrl: URL? = nil
        if !avatarUrlString.isEmpty, let url = URL(string: avatarUrlString) {
            avatarUrl = url
        }
        
        // Create new profile
        let newProfile = UserProfile(
            username: username,
            avatarUrl: avatarUrl,
            bio: bio
        )
        
        isLoading = true
        errorMessage = nil
        
        profileManager.createProfile(profile: newProfile) { result in
            self.isLoading = false
            
            switch result {
            case .success(let created):
                self.profile = created
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
