//
//  ImageItemView.swift
//  PinterestGallery
//
//  Created by kakim nyssanov on 01.04.2025.
//

import SwiftUI

struct ImageItemView: View {
    let imageItem: ImageItem
    @State private var isLoaded = false
    
    var body: some View {
        Group {
            if let image = imageItem.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isLoaded = true
                        }
                    }
                    .opacity(isLoaded ? 1.0 : 0.0)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .frame(minHeight: 150)
        .cornerRadius(8)
        .clipped()
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
