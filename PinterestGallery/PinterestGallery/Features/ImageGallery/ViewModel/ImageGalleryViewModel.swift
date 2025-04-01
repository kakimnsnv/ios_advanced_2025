//
//  ImageGalleryViewModel.swift
//  PinterestGallery
//
//  Created by kakim nyssanov on 01.04.2025.
//

import Foundation
import SwiftUI
import Combine

// Define custom errors for the view model
enum ImageDownloadError: Error {
    case networkError(Error)
    case invalidResponse
    case invalidImageData
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidImageData:
            return "Could not process image data"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

class ImageGalleryViewModel: ObservableObject {
    @Published var imageItems: [ImageItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let baseURL = "https://picsum.photos/id/"
    private var isLoadingMore = false
    
    // Method to refresh all images
    func refreshImages() {
        // Clear the current images
        imageItems = []
        // Load new ones
        loadMoreImages()
    }
    
    // Method to load more images
    func loadMoreImages() {
        guard !isLoading && !isLoadingMore else { return }
        
        isLoadingMore = true
        isLoading = true
        errorMessage = nil
        
        let dispatchGroup = DispatchGroup()
        var newImages: [ImageItem] = []
        var loadErrors: [ImageDownloadError] = []
        
        // Load 5 new images
        for _ in 0..<5 {
            dispatchGroup.enter()
            
            // Generate random image parameters
            let randomID = Int.random(in: 1...1000)
            let randomWidth = Int.random(in: 300...500)
            let randomHeight = Int.random(in: 200...600)
            
            // Create URL for a random image from Picsum Photos
            let imageURL = URL(string: "\(baseURL)\(randomID)/\(randomWidth)/\(randomHeight)")!
            
            // Create the image item with unique ID
            let imageItem = ImageItem(id: UUID().uuidString, url: imageURL, width: randomWidth, height: randomHeight)
            newImages.append(imageItem)
            
            // Check if the image is already in the cache
            if let cachedImage = ImageCache.shared.getImage(for: imageURL) {
                // If it's in the cache, use it immediately
                if let index = newImages.firstIndex(where: { $0.id == imageItem.id }) {
                    newImages[index].image = cachedImage
                }
                dispatchGroup.leave()
            } else {
                // Otherwise download it on a background queue
                DispatchQueue.global(qos: .userInitiated).async {
                    self.downloadImage(for: imageItem) { result in
                        switch result {
                        case .success(let downloadedImage):
                            // Cache the downloaded image
                            ImageCache.shared.setImage(downloadedImage, for: imageURL)
                            
                            // Find the index of this image item
                            if let index = newImages.firstIndex(where: { $0.id == imageItem.id }) {
                                // Update the image on a background thread
                                newImages[index].image = downloadedImage
                            }
                        case .failure(let error):
                            // Record the error
                            loadErrors.append(error)
                            
                            // Remove the failed image from new images
                            if let index = newImages.firstIndex(where: { $0.id == imageItem.id }) {
                                newImages.remove(at: index)
                            }
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        // When all images are downloaded, update the UI on the main queue
        dispatchGroup.notify(queue: .main) {
            // First handle any errors
            if !loadErrors.isEmpty {
                // Just show the first error for simplicity
                self.errorMessage = loadErrors.first?.localizedDescription ?? "Error loading images"
            }
            
            // Only add images that were successfully downloaded
            self.imageItems.append(contentsOf: newImages.filter { $0.image != nil })
            self.isLoading = false
            self.isLoadingMore = false
        }
    }
    
    // Helper method to download an image
    private func downloadImage(for item: ImageItem, completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void) {
        let task = URLSession.shared.dataTask(with: item.url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.invalidImageData))
                return
            }
            
            completion(.success(image))
        }
        task.resume()
    }
    
    // Helper method to retry loading images that failed
    func retryLoadingImages() {
        loadMoreImages()
    }
}
