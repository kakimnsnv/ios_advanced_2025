//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//
import Foundation
import SwiftUI

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: ForecastResponse?
    @Published var airQuality: AirQualityResponse?

    @Published var currentWeatherState: LoadingState = .idle
    @Published var forecastState: LoadingState = .idle
    @Published var airQualityState: LoadingState = .idle

    private let weatherService: WeatherServiceProtocol
    private let latitude: Double
    private let longitude: Double

    init(
        weatherService: WeatherServiceProtocol = WeatherService(),
        latitude: Double = 51.1694,
        longitude: Double = 71.4491
    ) {
        self.weatherService = weatherService
        self.latitude = latitude
        self.longitude = longitude
    }

    func fetchWeatherData() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadCurrentWeather() }
                group.addTask { await self.loadForecast() }
                group.addTask { await self.loadAirQuality() }
            }
        }
    }

    private func loadCurrentWeather() async {
        currentWeatherState = .loading
        do {
            let result = try await weatherService.getCurrentWeather(lat: latitude, lon: longitude)
            currentWeather = result
            currentWeatherState = .success
        } catch {
            currentWeatherState = .failure(error.localizedDescription)
        }
    }

    private func loadForecast() async {
        forecastState = .loading
        do {
            let result = try await weatherService.getForecast(lat: latitude, lon: longitude)
            forecast = result
            forecastState = .success
        } catch {
            forecastState = .failure(error.localizedDescription)
        }
    }

    private func loadAirQuality() async {
        airQualityState = .loading
        do {
            let result = try await weatherService.getAirQuality(lat: latitude, lon: longitude)
            airQuality = result
            airQualityState = .success
        } catch {
            airQualityState = .failure(error.localizedDescription)
        }
    }

    func refresh() {
        fetchWeatherData()
    }
}
