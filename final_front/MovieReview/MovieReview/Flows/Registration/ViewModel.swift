//
//  ViewModel.swift
//  MovieReview
//
//  Created by kakim nyssanov on 03.05.2025.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    private let networkService: NetworkServiceProtocol
    private let router: RouterProtocol
    
//    @Published chto to chto to
    
    init(networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.networkService = networkService
        self.router = router
    }
    
    // Drugie methody sudya piwete 
}
