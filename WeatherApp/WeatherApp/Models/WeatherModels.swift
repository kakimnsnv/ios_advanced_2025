//
//  WeatherModels.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import Foundation

struct CurrentWeather: Decodable {
    let name: String?
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Main: Decodable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct Weather: Decodable {
    let main: String
    let description: String
    let icon: String
}

struct Wind: Decodable {
    let speed: Double
}

struct ForecastResponse: Decodable {
    let list: [ForecastItem]
}

struct ForecastItem: Decodable {
    let dt: TimeInterval
    let main: Main
    let weather: [Weather]
    let dt_txt: String?
}

struct AirQualityResponse: Decodable {
    let list: [AirQualityData]
}

struct AirQualityData: Decodable {
    let main: AQIMain
    let components: AQIComponents
}

struct AQIMain: Decodable {
    let aqi: Int
}

struct AQIComponents: Decodable {
    let pm2_5: Double
    let pm10: Double
}

