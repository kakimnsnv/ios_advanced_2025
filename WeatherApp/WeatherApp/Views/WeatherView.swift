//
//  WeatherView.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    SectionView(state: viewModel.currentWeatherState) {
                        CurrentWeatherView(data: viewModel.currentWeather!)
                    }

                    SectionView(state: viewModel.forecastState) {
                        ForecastView(data: viewModel.forecast!)
                    }

                    SectionView(state: viewModel.airQualityState) {
                        AirQualityView(data: viewModel.airQuality!)
                    }
                }
                .padding()
            }
            .navigationTitle("Weather")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.fetchWeatherData()
            }
        }
    }
}
