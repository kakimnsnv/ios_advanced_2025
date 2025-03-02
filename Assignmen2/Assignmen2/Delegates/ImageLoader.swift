//
//  ImageLoader.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

protocol ImageLoaderDelegate: AnyObject {
    func imageLoader(_ loader: ImageLoader, didLoad image: UIImage)
    func imageLoader(_ loader: ImageLoader, didFailWith error: Error)
}

class ImageLoader: ObservableObject{
    weak var delegate: ImageLoaderDelegate?
    
    private var cache = NSCache<NSString, UIImage>() // In-memory cache

    func loadImage(url: URL) {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            delegate?.imageLoader(self, didLoad: cachedImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.imageLoader(self, didFailWith: error)
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.cache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    self.delegate?.imageLoader(self, didLoad: image)
                }
            } else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "ImageLoader", code: 500, userInfo: nil)
                    self.delegate?.imageLoader(self, didFailWith: error)
                }
            }
        }
        task.resume()
    }
    
//    func loadImage(url: URL) {
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
//            guard let self = self else { return }
//
//            if let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//                guard let data = data, self != nil else { return }
//                DispatchQueue.main.async {
//                    self.delegate?.imageLoader(self, didLoad: UIImage(data: data))
//                }
//            }else {
//                let error = NSError(domain: "ImageLoaderDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
//                DispatchQueue.main.async {
//                    self.delegate?.imageLoader(self, didFailWith: error)
//                }
//            }
//            
//        }
//    }
}

