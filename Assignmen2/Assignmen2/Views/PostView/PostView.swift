//
//  PostView.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button("Load Image") {
                viewModel.loadImage(urlString: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png")
//                viewModel.loadImage(urlString: "https://www.shutterstock.com/image-illustration/pune-india-february-19-2024-600nw-2427127541.jpg")
            }
        }
    }
}

#Preview{
    PostView()
}
