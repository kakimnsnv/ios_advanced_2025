//
//  ImageCache.swift
//  PinterestGallery
//
//  Created by kakim nyssanov on 01.04.2025.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let lock = NSLock()
    
    private init() {
        // Set cache limits (adjust as needed)
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func getImage(for url: URL) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        
        let key = url.absoluteString as NSString
        return cache.object(forKey: key)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        
        let key = url.absoluteString as NSString
        cache.setObject(image, forKey: key, cost: image.jpegData(compressionQuality: 1.0)?.count ?? 0)
    }
    
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeAllObjects()
    }
}
