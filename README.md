# ABCTest

## Features

- **Image Carousel**: Horizontal scrolling carousel displaying the first 5 items with page control
- **Searchable List**: Filterable list of items with search functionality
- **Statistics View**: View statistics showing filtered item count and top 3 most frequent characters
- **Image Caching**: Efficient image loading with caching mechanism

## Architecture

The project follows a clean architecture pattern with MVVM:

- **Models**: Data structures (Item)
- **Views**: UIKit views and view controllers
- **ViewModels**: Business logic and state management
- **Services**: API client and image loading service
- **Coordinator**: App flow coordination with dependency injection

## Project Structure

```
ABCTest/
├── Application/           # App and Scene delegates
├── Models/                # Data models
├── Presentation/
│   ├── Constants/         # UI constants and extensions
│   ├── Views/             # View components and controllers
│   │   ├── CollectionCell/
│   │   ├── View/
│   │   └── ViewController/
│   ├── AppDIContainer.swift
│   └── AppFlowCoordinator.swift
├── Services/              # API and image loading services
├── ViewModel/             # View models
└── Resource/              # Assets and storyboards
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `ABCTest.xcodeproj` in Xcode
3. Build and run

## Usage

- **Browse Items**: Scroll through the carousel and list of items
- **Search**: Use the search bar to filter items by title or description
- **View Statistics**: Tap the floating chart button to see statistics about filtered items

## Key Technologies

- UIKit
- UICollectionView with Compositional Layout
- Diffable Data Source
- Combine framework
- Async/Await
- Dependency Injection
