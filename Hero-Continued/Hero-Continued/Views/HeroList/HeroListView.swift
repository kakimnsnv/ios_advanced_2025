//
//  HeroListView.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import SwiftUI

struct HeroListView: View {
    @ObservedObject var viewModel: HeroListViewModel
    
    var body: some View {
        VStack {
            // Search bar
            SearchBar(text: $viewModel.searchText)
                .padding()
            
            switch viewModel.viewState {
            case .loading:
                LoadingView()
            case .loaded:
                heroList
            case .error(let message):
                ErrorView(message: message) {
                    Task {
                        await viewModel.fetchHeroes()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchHeroes()
            }
        }
    }
    
    private var heroList: some View {
        List {
            ForEach(viewModel.filteredHeroes) { hero in
                HeroRow(hero: hero)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.showHeroDetail(hero: hero)
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct HeroRow: View {
    let hero: Superhero
    
    var body: some View {
        HStack(spacing: 16) {
            // Hero thumbnail
            AsyncImage(url: URL(string: hero.images.sm)) { phase in
                switch phase {
                case .empty:
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                case .failure:
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                }
            }
            .frame(width: 60, height: 60)
            
            // Hero info
            VStack(alignment: .leading, spacing: 4) {
                Text(hero.name)
                    .font(.headline)
                
                Text(hero.biography.fullName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Power Stats indicators
                HStack(spacing: 8) {
                    PowerStatIndicator(value: hero.powerstats.strength, label: "STR", color: .red)
                    PowerStatIndicator(value: hero.powerstats.intelligence, label: "INT", color: .blue)
                    PowerStatIndicator(value: hero.powerstats.speed, label: "SPD", color: .green)
                }
            }
            
            Spacer()
            
            // Alignment indicator
            AlignmentBadge(alignment: hero.biography.alignment)
        }
        .padding(.vertical, 8)
    }
}

struct PowerStatIndicator: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(width: 24, height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(color)
                    .frame(width: CGFloat(value) / 100 * 24, height: 4)
                    .cornerRadius(2)
            }
        }
    }
}

struct AlignmentBadge: View {
    let alignment: String
    
    var body: some View {
        Text(alignment.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(alignment == "good" ? Color.green.opacity(0.2) : alignment == "bad" ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
            )
            .foregroundColor(alignment == "good" ? .green : alignment == "bad" ? .red : .gray)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search heroes", text: $text)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text("Loading heroes...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
