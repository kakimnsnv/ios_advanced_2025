//
//  HeroListViewModel.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import Foundation
import Combine

enum ViewState {
    case loading
    case loaded
    case error(String)
}

class HeroListViewModel: ObservableObject {
    private let networkService: NetworkServiceProtocol
    private let router: RouterProtocol
    
    @Published var heroes: [Superhero] = []
    @Published var filteredHeroes: [Superhero] = []
    @Published var searchText: String = ""
    @Published var viewState: ViewState = .loading
    
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.networkService = networkService
        self.router = router
        
        // Set up search filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] searchText in
                guard let self = self, !searchText.isEmpty else {
                    return self?.heroes ?? []
                }
                
                return self.heroes.filter { hero in
                    hero.name.lowercased().contains(searchText.lowercased()) ||
                    hero.biography.fullName.lowercased().contains(searchText.lowercased())
                }
            }
            .assign(to: &$filteredHeroes)
    }
    
    func fetchHeroes() async {
        await MainActor.run {
            self.viewState = .loading
        }
        
        do {
            let fetchedHeroes = try await networkService.fetchAllHeroes()
            
            await MainActor.run {
                self.heroes = fetchedHeroes
                self.filteredHeroes = fetchedHeroes
                self.viewState = .loaded
            }
        } catch let error as NetworkError {
            await MainActor.run {
                self.viewState = .error(error.message)
            }
        } catch {
            await MainActor.run {
                self.viewState = .error("An unknown error occurred")
            }
        }
    }
    
    func showHeroDetail(hero: Superhero) {
        searchText = ""
        router.showHeroDetail(hero: hero)
    }
}
