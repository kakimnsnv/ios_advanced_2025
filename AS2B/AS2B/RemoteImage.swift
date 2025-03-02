//
//  RemoteImage.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

struct RemoteImage: View {
    @ObservedObject var imageLoader: ImageLoader
    var placeholder: Image

    init(url: URL?, placeholder: Image = Image(systemName: "photo")) {
        self.placeholder = placeholder
        self.imageLoader = ImageLoader(url: url)
    }
    
    var body: some View {
        Group {
            if let uiImage = imageLoader.image {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                placeholder
                    .resizable()
            }
        }
    }
}
