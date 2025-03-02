//
//  ImageLoaderDelegate.swift
//  AS2C
//
//  Created by kakim nyssanov on 20.02.2025.
//


import SwiftUI
import Combine

/// Protocol for image loader delegate
protocol ImageLoaderDelegate: AnyObject {
    /// Called when an image is successfully loaded
    /// - Parameters:
    ///   - loader: The image loader that loaded the image
    ///   - image: The loaded UIImage
    func imageLoader(_ loader: ImageLoader, didLoad image: UIImage)
    
    /// Called when image loading fails
    /// - Parameters:
    ///   - loader: The image loader that failed
    ///   - error: The error that occurred
    func imageLoader(_ loader: ImageLoader, didFailWith error: Error)
}

/// Custom errors for image loading
enum ImageLoadingError: Error {
    case invalidURL
    case networkError
    case invalidImageData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid image URL"
        case .networkError: return "Network error while loading image"
        case .invalidImageData: return "Cannot create image from received data"
        }
    }
}

/// Handles image loading from remote URLs
class ImageLoader: ObservableObject {
    /// Published property to notify observers when an image is loaded
    @Published var image: UIImage?
    
    /// Published property to track loading state
    @Published var isLoading = false
    
    /// Published property to store any loading error
    @Published var error: Error?
    
    /// Delegate to receive image loading events
    /// Weak reference to prevent retain cycles between ImageLoader and its delegate
    weak var delegate: ImageLoaderDelegate?
    
    /// Closure called when image loading completes
    /// Using a closure provides a flexible alternative to the delegate pattern
    var completionHandler: ((UIImage?) -> Void)?
    
    /// URLSession for network requests
    private let urlSession = URLSession.shared
    
    /// Cancellable storage for active requests
    private var cancellables = Set<AnyCancellable>()
    
    /// Loads an image from the specified URL
    /// - Parameter url: The URL of the image to load
    func loadImage(url: URL) {
        isLoading = true
        error = nil
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadedImage in
                // Using weak self to prevent retain cycle
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let image = downloadedImage {
                    self.image = image
                    self.delegate?.imageLoader(self, didLoad: image)
                    self.completionHandler?(image)
                } else {
                    let error = ImageLoadingError.invalidImageData
                    self.error = error
                    self.delegate?.imageLoader(self, didFailWith: error)
                    self.completionHandler?(nil)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Loads an image from a string URL
    /// - Parameter urlString: String representation of the image URL
    /// - Returns: A publisher that emits the loaded image or an error
    func loadImage(urlString: String) -> AnyPublisher<UIImage?, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: ImageLoadingError.invalidURL).eraseToAnyPublisher()
        }
        
        isLoading = true
        error = nil
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw ImageLoadingError.networkError
                }
                
                guard let image = UIImage(data: data) else {
                    throw ImageLoadingError.invalidImageData
                }
                
                return image
            }
            .map { Optional($0) }
            .handleEvents(receiveOutput: { [weak self] image in
                guard let self = self, let image = image else { return }
                self.image = image
                self.delegate?.imageLoader(self, didLoad: image)
                self.completionHandler?(image)
            }, receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.error = error
                    self.delegate?.imageLoader(self, didFailWith: error)
                    self.completionHandler?(nil)
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Cancels all active image loading tasks
    func cancelLoading() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        isLoading = false
    }
}
