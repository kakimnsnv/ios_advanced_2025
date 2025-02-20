//
//  AddUserView.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

struct AddUserView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var avatarURL: String = ""
    @State private var bio: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Username", text: $username)
                    TextField("Avatar URL", text: $avatarURL)
                    TextField("Bio", text: $bio)
                }
            }
            .navigationTitle("New User")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                profileManager.addProfile(username: username, avatarURL: avatarURL.isEmpty ? nil : avatarURL, bio: bio)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
