//
//  AS2CApp.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

@main
struct SocialFeedApp: App {
    // Initialize core services
    @StateObject private var profileManager = ProfileManager()
    @StateObject private var feedSystem: FeedSystem
    
    init() {
        // Initialize feedSystem with profileManager
        let feedSystemInstance = FeedSystem(profileManager: ProfileManager())
        _feedSystem = StateObject(wrappedValue: feedSystemInstance)
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView(feedSystem: feedSystem, profileManager: profileManager)
                    .tabItem {
                        Label("Feed", systemImage: "list.bullet")
                    }
                
                NavigationView {
                    UserProfileView(profileManager: profileManager)
                }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            }
        }
    }
}

