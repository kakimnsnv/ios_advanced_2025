//
//  ImageLoader.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI
import Combine

/// An image loader that asynchronously loads images from a URL and caches them.
class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    private let url: URL?
    private var cancellable: AnyCancellable?
    
    /// A shared cache for downloaded images.
    static let imageCache = NSCache<NSURL, UIImage>()
    
    init(url: URL?) {
        self.url = url
        loadImage()
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    /// Loads the image from the URL, utilizing the cache if available.
    /// The escaping closure used in the Combine sink allows asynchronous callbacks.
    func loadImage() {
        guard let url = url else { return }
        if let cachedImage = ImageLoader.imageCache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadedImage in
                if let downloadedImage = downloadedImage {
                    ImageLoader.imageCache.setObject(downloadedImage, forKey: url as NSURL)
                }
                self?.image = downloadedImage
            }
    }
}
