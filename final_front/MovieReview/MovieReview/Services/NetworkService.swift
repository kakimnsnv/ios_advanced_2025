//
//  NetworkService.swift
//  MovieReview
//
//  Created by kakim nyssanov on 03.05.2025.
//

import Foundation

enum NetworkError: Error{
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case unknownError(Error)
}

protocol NetworkServiceProtocol {
// interface
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL = "http://localhost:8080/"
}
