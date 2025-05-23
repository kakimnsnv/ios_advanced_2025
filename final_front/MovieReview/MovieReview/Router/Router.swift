//
//  Router.swift
//  Hero-Continued
//
//  Created by kakim nyssanov on 16.03.2025.
//

import UIKit
import SwiftUI

protocol RouterProtocol {
    func start()
    func popToRoot()
}

class Router: RouterProtocol {
    private let navigationController: UINavigationController
    private let networkService: NetworkServiceProtocol
    
    init(navigationController: UINavigationController, networkService: NetworkServiceProtocol) {
        self.navigationController = navigationController
        self.networkService = networkService
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = .systemYellow
    }
    
    func start() {
        let viewModel = RegistrationViewModel(networkService: networkService, router: self)
        let view = RegistrationView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Easy Movie"
        navigationController.setViewControllers([hostingController], animated: false)
    }
    
//    func showHeroDetail(hero: Superhero) {
//        let detailViewModel = HeroDetailViewModel(hero: hero, router: self)
//        let detailView = HeroDetailView(viewModel: detailViewModel)
//        let hostingController = UIHostingController(rootView: detailView)
//        hostingController.title = hero.name
//        navigationController.pushViewController(hostingController, animated: true)
//    }
    
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
