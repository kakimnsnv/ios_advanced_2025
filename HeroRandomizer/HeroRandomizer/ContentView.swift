//
//  ContentView.swift
//  HeroRandomizer
//
//  Created by kakim nyssanov on 02.03.2025.
//

import SwiftUI

//struct ContentView: View {
//    @ObservedObject var viewModel: ViewModel
//    var body: some View {
//        VStack {
//            AsyncImage(url: URL(string: viewModel.selectedHero?.images.md ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(height: 300)
//                case .success(let image):
//                    image
//                        .resizable()
//                        .frame(height: 300)
//                case .failure(let error):
//                    Text(error.localizedDescription)
//                        .backgroundStyle(.red.opacity(0.5))
//                        .frame(height: 300)
//                @unknown default:
//                    Color.red.frame(height: 300)
//                }
//            }
//            .padding(32)
//
//            Spacer()
//
//            Button {
//                viewModel.getRandomHero()
//            } label: {
//                Text("Roll Hero")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//        .onAppear{
//            Task{
//                await viewModel.fetchHeroes()
//            }
//        }
//    }
//}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            if viewModel.selectedHero != nil {
                VStack{
                    VStack(spacing: 0) {
                        // Hero Image with Gradient Overlay
                        ZStack(alignment: .bottom) {
                            AsyncImage(url: URL(string: viewModel.selectedHero!.images.lg)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle().fill(Color.gray.opacity(0.2))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Rectangle().fill(Color.gray.opacity(0.2))
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    Rectangle().fill(Color.gray.opacity(0.2))
                                }
                            }
                            .frame(height: 400)
                            .clipped()
                            
                            // Gradient overlay
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 200)
                            
                            // Hero name and basic info
                            VStack(alignment: .leading, spacing: 8) {
                                    HStack{
                                        Button {
                                            viewModel.getPrevHero()
                                        } label: {
                                            Image(systemName: "arrow.backward.circle")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(width: 30)
                                                .foregroundStyle(.yellow)
                                        }
                                        Spacer()
                                        
                                        Text(viewModel.selectedHero!.name)
                                            .font(.system(size: 42, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        Button {
                                            viewModel.getNextHero()
                                        } label: {
                                            Image(systemName: "arrow.forward.circle")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(width: 30)
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                
                                Text(viewModel.selectedHero!.biography.fullName)
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack(spacing: 16) {
                                    Label(viewModel.selectedHero!.appearance.gender, systemImage: "person.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    if let race = viewModel.selectedHero!.appearance.race {
                                        Label(race, systemImage: "person.and.person.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Label(viewModel.selectedHero!.biography.alignment.capitalized, systemImage: viewModel.selectedHero!.biography.alignment == "good" ? "shield.fill" : "xmark.shield.fill")
                                        .foregroundColor(viewModel.selectedHero!.biography.alignment == "good" ? .green : .red)
                                }
                                .font(.subheadline)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                            
                            // Power Stats Visualization
                        VStack(spacing: 20) {
                            Text("Power Stats")
                                .font(.headline)
                                .padding(.top, 20)
                            
                            HStack(spacing: 12) {
                                StatBarView(
                                    value: viewModel.selectedHero!.powerstats.strength,
                                    label: "STR",
                                    color: .red
                                )
                                
                                StatBarView(
                                    value: viewModel.selectedHero!.powerstats.intelligence,
                                    label: "INT",
                                    color: .blue
                                )
                                
                                StatBarView(
                                    value: viewModel.selectedHero!.powerstats.speed,
                                    label: "SPD",
                                    color: .green
                                )
                                
                                StatBarView(
                                    value: viewModel.selectedHero!.powerstats.durability,
                                    label: "DUR",
                                    color: .orange
                                )
                                
                                StatBarView(
                                    value: viewModel.selectedHero!.powerstats.power,
                                    label: "PWR",
                                    color: .purple
                                )
                                
                                StatBarView(
                                    value: viewModel.selectedHero!.powerstats.combat,
                                    label: "CMB",
                                    color: .yellow
                                )
                            }
                            .padding(.horizontal)
                            .frame(height: 150)
                        }
                        .padding(.vertical, 20)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .offset(y: -20)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        

                        
                        // Tab View for additional information
                        VStack(spacing: 0) {
                            // Custom tab bar
                            HStack(spacing: 0) {
                                TabButton(title: "Biography", isSelected: selectedTab == 0) {
                                    selectedTab = 0
                                }
                                
                                TabButton(title: "Appearance", isSelected: selectedTab == 1) {
                                    selectedTab = 1
                                }
                                
                                TabButton(title: "Connections", isSelected: selectedTab == 2) {
                                    selectedTab = 2
                                }
                            }
                            .padding(.top)
                            
                            // Tab content
                            VStack(alignment: .leading, spacing: 16) {
                                switch selectedTab {
                                case 0:
                                    // Biography
                                    InfoRow(title: "Full Name", value: viewModel.selectedHero!.biography.fullName)
                                    InfoRow(title: "Alter Egos", value: viewModel.selectedHero!.biography.alterEgos)
                                    InfoRow(title: "Aliases", value: viewModel.selectedHero!.biography.aliases.joined(separator: ", "))
                                    InfoRow(title: "Place of Birth", value: viewModel.selectedHero!.biography.placeOfBirth)
                                    InfoRow(title: "First Appearance", value: viewModel.selectedHero!.biography.firstAppearance)
                                    InfoRow(title: "Publisher", value: viewModel.selectedHero!.biography.publisher ?? "")
                                    
                                    InfoRow(title: "Occupation", value: viewModel.selectedHero!.work.occupation)
                                    InfoRow(title: "Base", value: viewModel.selectedHero!.work.base)
                                    
                                case 1:
                                    // Appearance
                                    InfoRow(title: "Gender", value: viewModel.selectedHero!.appearance.gender)
                                    if let race = viewModel.selectedHero!.appearance.race {
                                        InfoRow(title: "Race", value: race)
                                    }
                                    InfoRow(title: "Height", value: viewModel.selectedHero!.appearance.height.joined(separator: " / "))
                                    InfoRow(title: "Weight", value: viewModel.selectedHero!.appearance.weight.joined(separator: " / "))
                                    InfoRow(title: "Eye Color", value: viewModel.selectedHero!.appearance.eyeColor)
                                    InfoRow(title: "Hair Color", value: viewModel.selectedHero!.appearance.hairColor)
                                    
                                case 2:
                                    // Connections
                                    InfoRow(title: "Group Affiliation", value: viewModel.selectedHero!.connections.groupAffiliation)
                                    InfoRow(title: "Relatives", value: viewModel.selectedHero!.connections.relatives)
                                    
                                default:
                                    EmptyView()
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.easeInOut, value: selectedTab)
                        }
                        .background(Color(.systemBackground))
                    }
                }
            }else{
                Text("Selecting error")
            }
        }
        .onAppear{
            Task{
                await viewModel.fetchHeroes()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Supporting Views
struct StatBarView: View {
    let value: Int
    let label: String
    let color: Color
    @State private var animatedHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(width: 30)
                
                Rectangle()
                    .fill(color)
                    .frame(width: 30, height: animatedHeight)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(label)
                
                .font(.caption)
                .fontWeight(.bold)
            
            Text("\(value)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedHeight = CGFloat(value) / 100 * 120
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
            
            Divider()
                .padding(.top, 4)
        }
    }
}

#Preview {
    let viewModel = ViewModel()
    ContentView(viewModel: viewModel)
}
