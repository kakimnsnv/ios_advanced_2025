//
//  HeroDetailView.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import SwiftUI

struct HeroDetailView: View {
    @ObservedObject var viewModel: HeroDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: viewModel.hero.images.lg)) { phase in
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
                    
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.hero.name)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(viewModel.hero.biography.fullName)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 16) {
                            Label(viewModel.hero.appearance.gender, systemImage: "person.fill")
                                .foregroundColor(.white.opacity(0.8))
                            
                            if let race = viewModel.hero.appearance.race {
                                Label(race, systemImage: "person.and.person.fill")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Label(viewModel.hero.biography.alignment.capitalized, systemImage: viewModel.hero.biography.alignment == "good" ? "shield.fill" : "xmark.shield.fill")
                                .foregroundColor(viewModel.hero.biography.alignment == "good" ? .green : .red)
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(spacing: 20) {
                    Text("Power Stats")
                        .font(.headline)
                        .padding(.top, 20)
                    
                    HStack(spacing: 12) {
                        StatusBarView(
                            value: viewModel.hero.powerstats.strength,
                            label: "STR",
                            color: .red
                        )
                        
                        StatusBarView(
                            value: viewModel.hero.powerstats.intelligence,
                            label: "INT",
                            color: .blue
                        )
                        
                        StatusBarView(
                            value: viewModel.hero.powerstats.speed,
                            label: "SPD",
                            color: .green
                        )
                        
                        StatusBarView(
                            value: viewModel.hero.powerstats.durability,
                            label: "DUR",
                            color: .orange
                        )
                        
                        StatusBarView(
                            value: viewModel.hero.powerstats.power,
                            label: "PWR",
                            color: .purple
                        )
                        
                        StatusBarView(
                            value: viewModel.hero.powerstats.combat,
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
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        TabButtonView(title: "Biography", isSelected: viewModel.selectedTab == 0) {
                            viewModel.selectedTab = 0
                        }
                        TabButtonView(title: "Appearance", isSelected: viewModel.selectedTab == 1) {
                            viewModel.selectedTab = 1
                        }
                        TabButtonView(title: "Connections", isSelected: viewModel.selectedTab == 2) {
                            viewModel.selectedTab = 2
                        }
                    }
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        switch viewModel.selectedTab {
                        case 0:
                            InfoRowView(title: "Full Name", value: viewModel.hero.biography.fullName)
                            InfoRowView(title: "Alter Egos", value: viewModel.hero.biography.alterEgos)
                            InfoRowView(title: "Aliases", value: viewModel.hero.biography.aliases.joined(separator: ", "))
                            InfoRowView(title: "Place of Birth", value: viewModel.hero.biography.placeOfBirth)
                            InfoRowView(title: "First Appearance", value: viewModel.hero.biography.firstAppearance)
                            InfoRowView(title: "Publisher", value: viewModel.hero.biography.publisher ?? "")
                            
                            InfoRowView(title: "Occupation", value: viewModel.hero.work.occupation)
                            InfoRowView(title: "Base", value: viewModel.hero.work.base)
                            
                        case 1:
                            InfoRowView(title: "Gender", value: viewModel.hero.appearance.gender)
                            if let race = viewModel.hero.appearance.race {
                                InfoRowView(title: "Race", value: race)
                            }
                            InfoRowView(title: "Height", value: viewModel.hero.appearance.height.joined(separator: " / "))
                            InfoRowView(title: "Weight", value: viewModel.hero.appearance.weight.joined(separator: " / "))
                            InfoRowView(title: "Eye Color", value: viewModel.hero.appearance.eyeColor)
                            InfoRowView(title: "Hair Color", value: viewModel.hero.appearance.hairColor)
                            
                        case 2:
                            InfoRowView(title: "Group Affiliation", value: viewModel.hero.connections.groupAffiliation)
                            InfoRowView(title: "Relatives", value: viewModel.hero.connections.relatives)
                            
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut, value: viewModel.selectedTab)
                }
                .background(Color(.systemBackground))
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

