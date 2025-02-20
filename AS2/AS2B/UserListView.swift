//
//  UserListView.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

struct UserListView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @State private var showingAddUser = false

    var body: some View {
        NavigationView {
            List {
                ForEach(profileManager.profiles) { user in
                    HStack {
                        if let avatarURLString = user.avatarURL, let url = URL(string: avatarURLString) {
                            RemoteImage(url: url)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        VStack(alignment: .leading) {
                            Text(user.username)
                                .font(.headline)
                            Text(user.bio)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .navigationBarItems(trailing: Button(action: {
                showingAddUser.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddUser) {
                AddUserView()
                    .environmentObject(profileManager)
            }
        }
    }
}
