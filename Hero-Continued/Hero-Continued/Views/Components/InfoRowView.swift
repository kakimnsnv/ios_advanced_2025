//
//  InfoRowView.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import SwiftUI

struct InfoRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
            
            Divider()
                .padding(.top, 4)
        }
    }
}
