//
//  WeatherService.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import Foundation

protocol WeatherServiceProtocol {
    func getCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeather
    func getForecast(lat: Double, lon: Double) async throws -> ForecastResponse
    func getAirQuality(lat: Double, lon: Double) async throws -> AirQualityResponse
}

struct WeatherService: WeatherServiceProtocol {
    func getCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeather {
        try await WeatherAPIManager.shared.fetch("/weather", parameters: [
            "lat": "\(lat)",
            "lon": "\(lon)"
        ])
    }

    func getForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        try await WeatherAPIManager.shared.fetch("/forecast", parameters: [
            "lat": "\(lat)",
            "lon": "\(lon)"
        ])
    }

    func getAirQuality(lat: Double, lon: Double) async throws -> AirQualityResponse {
        try await WeatherAPIManager.shared.fetch("/air_pollution", parameters: [
            "lat": "\(lat)",
            "lon": "\(lon)"
        ])
    }
}
