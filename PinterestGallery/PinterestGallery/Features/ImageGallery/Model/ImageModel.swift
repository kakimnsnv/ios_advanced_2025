//
//  ImageModel.swift
//  PinterestGallery
//
//  Created by kakim nyssanov on 01.04.2025.
//

import Foundation
import SwiftUI

struct ImageItem: Identifiable {
    let id: String
    let url: URL
    var image: UIImage?
    let width: Int
    let height: Int
    
    init(id: String, url: URL, width: Int, height: Int) {
        self.id = id
        self.url = url
        self.width = width
        self.height = height
    }
}
