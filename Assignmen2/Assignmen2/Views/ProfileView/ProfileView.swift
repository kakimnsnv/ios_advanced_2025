//
//  ProfileView.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileManager :ProfileManager
    @StateObject private var viewModel = ProfileViewModel(profileManager: profileManager)
    @State private var bioInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading){
            if var profile = viewModel.profile{
                HStack{
                    if profile.avatarURL != nil {
                        AsyncImage(url: URL(string:profile.avatarURL!)){ result in
                            if let image = result.image{
                                    image
                                    .resizable()
                                    .scaledToFit()
                            }else if result.error != nil {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            } else {
                                ProgressView()
                                    .font(.largeTitle)
                            }
                        }
                        .frame(width: 100)
                        .clipShape(.circle)
                    }else {
                        Text("")
                            .padding(40)
                            .background(.black)
                            .clipShape(.circle)
                    }
                    VStack(spacing: 15){
                        Text(profile.username)
                            .font(.title2)
                        Text("Followers: \(profile.followers)")
                            .font(.callout)
                    }
                }
                HStack{
                    Text("Bio:")
                        .font(.title2)
                        .foregroundColor(.black.opacity(0.8))
                    TextField("Enter bio", text: $bioInput)
                        .textFieldStyle(.roundedBorder)
                }
                Spacer()
                if profile.bio != bioInput {
                    Button{
                        profile.bio = bioInput
                        viewModel.profileDidUpdate(profile)
                    } label: {
                        Text("Update profile bio")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .foregroundStyle(.white)
                            .clipShape(.buttonBorder)
                    }
                }
            }
        }
        .padding()
        .onAppear{
            viewModel.onProfileUpdate = {profile in
                self.bioInput = profile.bio
                print(profile)
            }
            viewModel.loadProfile(username: "Username")
        }
    }
}
        
#Preview{
    ProfileView()
}
