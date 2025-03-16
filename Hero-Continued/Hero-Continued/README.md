# SuperHero App

A clean, modern iOS application that displays superhero information using the Superhero API.

## Architecture

This project follows the MVVM + Router architecture pattern:

- **Model**: Data models for the superhero entities
- **View**: SwiftUI views embedded in UIKit navigation structure
- **ViewModel**: Logic for data handling and transformation
- **Router**: Navigation management

## Project Structure

- **Models/**
  - `Superhero.swift`: Data models for heroes and their properties
- **Views/**
  - `HeroListView.swift`: Main list view displaying all heroes
  - `HeroDetailView.swift`: Detailed view for individual heroes
  - Supporting views for reusable UI components
- **ViewModels/**
  - `HeroListViewModel.swift`: Logic for hero list display and search
  - `HeroDetailViewModel.swift`: Logic for hero details display
- **Services/**
  - `NetworkService.swift`: API communication layer
- **Router/**
  - `Router.swift`: Navigation management
- **Application/**
  - `AppDelegate.swift`: Application lifecycle
  - `SceneDelegate.swift`: Scene configuration

## Features

- View a list of all superheroes with basic information
- Search heroes by name or full name
- View detailed information for each hero including:
  - Power stats visualization
  - Biography details
  - Appearance details
  - Connection information
- Clean UI with transitions and animations
- Error handling and loading states

## Technical Implementation

- Swift and SwiftUI for the UI
- UIKit NavigationController for routing
- MVVM architecture for clean separation of concerns
- Asynchronous network calls using Swift concurrency (async/await)
- Proper error handling with custom error types
- Memory management with weak references where appropriate
- Combine framework for reactive programming (search filtering)

## Setup Instructions

1. Clone the repository
2. Open the project in Xcode 13.0 or later
3. Build and run on iOS 15.0 or later

## Architecture Decisions

### MVVM + Router
- **ViewModel**: Acts as an intermediary between the Model and View, handling business logic, data transformation, and state management
- **Router**: Manages navigation flow, decoupling navigation logic from views
- This separation allows for better testing, reusability, and maintenance

### SwiftUI in UIKit Navigation
- SwiftUI provides modern UI development capabilities
- UIKit navigation controller provides established navigation patterns and control
- The combination leverages the strengths of both frameworks

### Network Service
- Dedicated service layer for API communication
- Error handling centralized in one place
- Easily testable with protocol-based design

## Future Improvements

- Implement caching for better offline experience
- Add favorites functionality
- Create custom transitions between views
- Implement unit and UI tests
