//
//  WeatherAPIManager.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import Foundation

enum WeatherAPIError: Error {
    case invalidURL
    case requestFailed
    case decodingError
}

struct WeatherAPIManager {
    static let shared = WeatherAPIManager()
    private init() {}

    private let apiKey = "7937f95ad3f673af17ff91e451298e4c"
    private let baseURL = "https://api.openweathermap.org/data/2.5"

    func fetch<T: Decodable>(_ endpoint: String, parameters: [String: String]) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)
        var queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        queryItems.append(URLQueryItem(name: "units", value: "metric"))
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw WeatherAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw WeatherAPIError.requestFailed
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw WeatherAPIError.decodingError
        }
    }
}
