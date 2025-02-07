//
//  ContentView.swift
//  About me
//
//  Created by kakim nyssanov on 06.02.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/84794256?s=400&u=1a0de2b3ee32164da6da746daaf371fc0476175c&v=4")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    InfoField(label: "Name", value: "Kakimbek")
                    InfoField(label: "Surname", value: "Nyssanov")
                    InfoField(label: "Birthday", value: "2005.03.19")
                    InfoField(label: "Course", value: "3rd")
                    InfoField(label: "Contacts anywhere", value: "@kakimnsnv")
                    InfoField(label: "About", value: "I am a flutter developer, but now I am trying new fields like backend, DevOps, or as of now just SwiftUI. My hometown is Aktau 🌊🔥. I am very passionate about it and technology!")
                    
                    Spacer()
                    
                    NavigationLink(destination: HobbiesView()) {
                        Text("Interests ⚡️")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: GoalsView()) {
                        Text("Goals ⚡️")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                }
                .padding()
                .navigationTitle("@kakimnsnv")
            }
        }
    }
}

struct InfoField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.title2)
                .foregroundColor(.black.opacity(0.8))
            Text(value)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                )
                .foregroundColor(.black)
        }
    }
}

struct Hobby: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
}

struct HobbiesView: View {
    let hobbies: [Hobby] = [
        Hobby(name: "Startups", description: "Bringing new ideas and create new unicorn 🦄", imageName: "brain.head.profile.fill"),
        Hobby(name: "Hiking", description: "Exploring nature and enjoying scenic landscapes.", imageName: "leaf"),
        Hobby(name: "Coding", description: "Building apps and solving problems through code.", imageName: "laptopcomputer")
    ]
    
    var body: some View {
        List(hobbies) { hobby in
            HStack {
                Image(systemName: hobby.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(hobby.name)
                        .font(.headline)
                    Text(hobby.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 5)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Interests ⚡️")
    }
}

struct GoalsView: View {
    let goals: [String] = [
        "Become a lead Go developer.",
        "Build an innovative app that impacts lives of students.",
        "Master Flutter with advanced animations and optimizations.",
        "Learn SwiftUI for native apple products, and hope some day work at Apple. I love Apple ♡",
        "Contribute to open-source projects."
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(goals.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        Text(goals[index])
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Goals ⚡️")
    }
}

#Preview {
    ContentView()
}
