//
//  ContentView.swift
//  About me
//
//  Created by kakim nyssanov on 06.02.2025.
//

import SwiftUI



struct ContentView: View {
    init() {
        let whiteAppearance = UINavigationBarAppearance()
        let blackAppearance = UINavigationBarAppearance()
        whiteAppearance.backgroundColor = .white
        blackAppearance.backgroundColor = .black
        blackAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = blackAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = whiteAppearance
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImage(url: URL(string: "https://file.notion.so/f/f/c3c1d212-c1f9-4eeb-be30-1d73097541c1/0f2f331d-01a8-45d0-8fea-75968283455c/IMG_9045.jpeg?table=block&id=58d9b178-28ac-4c0a-b951-2bf3acf1033f&spaceId=c3c1d212-c1f9-4eeb-be30-1d73097541c1&expirationTimestamp=1738872000000&signature=xkxjOa1LbNaFGMFIklzaKV34E5PQDqRBxOW1yb70iU8&downloadName=IMG_9045.jpeg")) { image in
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
                }
                .padding()
                .background(Color.black.edgesIgnoringSafeArea(.all))
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
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
