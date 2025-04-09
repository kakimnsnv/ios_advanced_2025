//
//  CurrentWeatherView.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import SwiftUI

struct CurrentWeatherView: View {
    let data: CurrentWeather

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(data.name ?? "Current Location")
                .font(.title2)
                .bold()

            Text("\(Int(data.main.temp))°C • \(data.weather.first?.main ?? "")")
                .font(.title)
                .bold()

            Text("Feels like \(Int(data.main.feels_like))°C")
                .font(.subheadline)

            Text("Humidity: \(data.main.humidity)%")
                .font(.subheadline)

            Text("Wind: \(data.wind.speed, specifier: "%.1f") m/s")
                .font(.subheadline)
        }
    }
}
