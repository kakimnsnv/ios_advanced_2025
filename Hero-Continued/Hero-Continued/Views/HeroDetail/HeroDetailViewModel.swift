//
//  HeroDetailViewModel.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import Foundation

class HeroDetailViewModel: ObservableObject {
    @Published var hero: Superhero
    @Published var selectedTab: Int = 0
    
    private let router: RouterProtocol
    
    init(hero: Superhero, router: RouterProtocol) {
        self.hero = hero
        self.router = router
    }
    
    func goBack() {
        router.popToRoot()
    }
}
