//
//  ForecastView.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import SwiftUI

struct ForecastView: View {
    let data: ForecastResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("5-Day Forecast")
                .font(.headline)

            ForEach(data.list.prefix(5), id: \.dt) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.dt_txt ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("\(Int(item.main.temp))°C • \(item.weather.first?.main ?? "")")
                        .font(.body)
                }
                Divider()
            }
        }
    }
}
