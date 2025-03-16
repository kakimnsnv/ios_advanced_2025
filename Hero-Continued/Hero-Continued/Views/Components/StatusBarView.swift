//
//  StatusBarView.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import SwiftUI

struct StatusBarView: View {
    let value: Int
    let label: String
    let color: Color
    @State private var animatedHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(width: 30)
                
                Rectangle()
                    .fill(color)
                    .frame(width: 30, height: animatedHeight)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(label)
                
                .font(.caption)
                .fontWeight(.bold)
            
            Text("\(value)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedHeight = CGFloat(value) / 100 * 120
            }
        }
    }
}
