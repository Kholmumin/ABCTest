# ABCTest

## Features

- Image carousel with page indicators
- Searchable list of items
- Statistics view
- Modern SwiftUI interface
- Clean architecture with MVVM pattern

## Requirements

- iOS 18.6+
- Xcode 18.0+
- Swift 5.5+

## Project Structure

```
ABCTest/
├── Application/        # App entry point
├── Models/            # Data models
├── Services/          # API clients and image loading
├── UI/
│   ├── Components/    # Reusable UI components
│   ├── View/          # Main views
│   └── AppSwiftUI*    # Dependency injection and navigation
├── ViewModel/         # View models
└── Resources/         # Assets and constants
```

## Getting Started

1. Clone the repository
2. Open `ABCTest.xcodeproj` in Xcode
3. Build and run the project (⌘ + R)

## Architecture

The app uses:
- **SwiftUI** for the user interface
- **MVVM** pattern for separation of concerns
- **Async/await** for asynchronous operations
- **Dependency injection** for testability

## Main Components

- **MainView**: Displays the carousel and searchable list
- **ListItemView**: Individual item cell
- **SearchBar**: Search functionality
- **StatisticsFloatingButton**: Floating action button
- **ImageLoader**: Handles image loading and caching

## License

All rights reserved.
