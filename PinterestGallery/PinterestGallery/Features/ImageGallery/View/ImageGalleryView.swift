//
//  ImageGalleryView.swift
//  PinterestGallery
//
//  Created by kakim nyssanov on 01.04.2025.
//

import SwiftUI

struct ImageGalleryView: View {
    @StateObject private var viewModel = ImageGalleryViewModel()
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]
    @State private var isPresentingFullScreenImage: Bool = false
    @State private var selectedImage: ImageItem? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    // Pull to refresh (requires iOS 15+)
                    if #available(iOS 15.0, *) {
                        RefreshControl(coordinateSpace: .named("RefreshControl")) {
                            await refreshImages()
                        }
                    }
                    
                    // Show message if no images
                    if viewModel.imageItems.isEmpty && !viewModel.isLoading {
                        VStack(spacing: 20) {
                            Text("No images to display")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                viewModel.loadMoreImages()
                            }) {
                                Text("Load Images")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.imageItems) { item in
                                ImageItemView(imageItem: item)
                                    .aspectRatio(CGFloat(item.width) / CGFloat(item.height), contentMode: .fit)
                                    .onTapGesture {
                                        selectedImage = item
                                        isPresentingFullScreenImage = true
                                    }
                                    // This is the key for infinite scrolling
                                    .onAppear {
                                        // If this is one of the last 3 items, load more
                                        if item.id == viewModel.imageItems.suffix(3).first?.id && !viewModel.isLoading {
                                            viewModel.loadMoreImages()
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                        
                        // Keep the button as a fallback for when infinite scrolling doesn't trigger
                        Button(action: {
                            viewModel.loadMoreImages()
                        }) {
                            Text("Load More Images")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                        .disabled(viewModel.isLoading)
                    }
                }
                .coordinateSpace(name: "RefreshControl")
                
                // Error overlay with retry button
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.yellow)
                            
                            Text(errorMessage)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                viewModel.errorMessage = nil
                                viewModel.retryLoadingImages()
                            }) {
                                Text("Retry")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.leading, 8)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                        )
                        .padding()
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: viewModel.errorMessage != nil)
                    .zIndex(1)
                }
            }
            .navigationTitle("Pinterest Gallery")
            .sheet(isPresented: $isPresentingFullScreenImage) {
                if let selectedImage = selectedImage, let image = selectedImage.image {
                    FullScreenImageView(image: image)
                }
            }
        }
        .onAppear {
            if viewModel.imageItems.isEmpty {
                viewModel.loadMoreImages()
            }
        }
    }
    
    @MainActor
    private func refreshImages() async {
        viewModel.refreshImages()
    }
}

// For iOS 15+ pull-to-refresh functionality
@available(iOS 15.0, *)
struct RefreshControl: View {
    var coordinateSpace: CoordinateSpace
    var onRefresh: () async -> Void
    @State private var isRefreshing = false
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: coordinateSpace).midY > 50 {
                Spacer()
                    .onAppear {
                        if !isRefreshing {
                            isRefreshing = true
                            Task {
                                await onRefresh()
                                isRefreshing = false
                            }
                        }
                    }
            } else if geometry.frame(in: coordinateSpace).maxY < 1 {
                Spacer()
                    .onAppear {
                        isRefreshing = false
                    }
            }
            HStack {
                Spacer()
                if isRefreshing {
                    ProgressView()
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}

// This view will show an image in full-screen when tapped
struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .navigationBarItems(trailing: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    })
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

// Helper struct for showing errors in alerts
struct ImageGalleryError: Identifiable {
    let id = UUID()
    let message: String
}

#Preview{
    ImageGalleryView()
}
