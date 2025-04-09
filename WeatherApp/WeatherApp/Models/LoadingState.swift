//
//  LoadingState.swift
//  WeatherApp
//
//  Created by kakim nyssanov on 09.04.2025.
//

import Foundation

enum LoadingState {
    case idle
    case loading
    case success
    case failure(String)
}

