//
//  ContentView.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            Tab("Feed", systemImage: "newspaper.fill"){
                FeedView()
            }
            
            Tab("Profile", systemImage: "person.fill"){
                ProfileView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ImageLoader())
        .environmentObject(ProfileManager())
}
