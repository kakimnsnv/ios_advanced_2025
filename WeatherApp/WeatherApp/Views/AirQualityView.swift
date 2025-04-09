//
//  AirQualityView.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import SwiftUI

struct AirQualityView: View {
    let data: AirQualityResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Air Quality")
                .font(.headline)

            if let aqi = data.list.first {
                Text("AQI Index: \(aqi.main.aqi)")
                    .font(.subheadline)

                Text("PM2.5: \(aqi.components.pm2_5, specifier: "%.1f") μg/m³")
                    .font(.subheadline)

                Text("PM10: \(aqi.components.pm10, specifier: "%.1f") μg/m³")
                    .font(.subheadline)
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
            }
        }
    }
}
