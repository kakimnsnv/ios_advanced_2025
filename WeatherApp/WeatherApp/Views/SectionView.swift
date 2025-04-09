//
//  SectionView.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import SwiftUI

struct SectionView<Content: View>: View {
    let state: LoadingState
    let content: () -> Content

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        case .failure(let message):
            Text("Error: \(message)")
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        case .success:
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
