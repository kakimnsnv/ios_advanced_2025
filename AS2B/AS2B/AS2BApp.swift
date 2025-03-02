//
//  AS2BApp.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

@main
struct SocialMediaApp: App {
    @StateObject var profileManager = ProfileManager()
    @StateObject var postManager = PostManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(profileManager)
                .environmentObject(postManager)
        }
    }
}
