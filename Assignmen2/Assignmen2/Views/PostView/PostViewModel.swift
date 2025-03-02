//
//  PostViewModel.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

class PostViewModel: ObservableObject, ImageLoaderDelegate {
    @Published var image: UIImage?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var imageLoader = ImageLoader()

    init() {
        imageLoader.delegate = self
    }

    func loadImage(urlString: String) {
        self.isLoading = true
        if let url = URL(string: urlString) {
            imageLoader.loadImage(url: url)
        }
    }

    // MARK: - ImageLoaderDelegate Methods
    func imageLoader(_ loader: ImageLoader, didLoad image: UIImage) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.image = image
        }
    }

    func imageLoader(_ loader: ImageLoader, didFailWith error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}
