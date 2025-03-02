//
//  ContentView.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }
            NewPostView()
                .tabItem {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            UserListView()
                .tabItem {
                    Label("Users", systemImage: "person.3")
                }
        }
    }
}

#Preview {
    ContentView()
}
