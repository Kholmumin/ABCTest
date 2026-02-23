//
//  AppConstants.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import Foundation

public enum AppConstants {
    
    // MARK: - Layout Constants
    
    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let largeCornerRadius: CGFloat = 20
        static let extraLargeCornerRadius: CGFloat = 30
        static let defaultPadding: CGFloat = 16
        static let largePadding: CGFloat = 20
        static let smallSpacing: CGFloat = 12
        static let mediumSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 20
        static let floatingButtonSize: CGFloat = 56
        static let imageSize: CGFloat = 100
        static let listItemHeight: CGFloat = 120
        static let carouselHeight: CGFloat = 240
        static let carouselImageHeight: CGFloat = 220
        static let searchBarHeight: CGFloat = 25
    }
    
    // MARK: - Configuration
    
    enum Configuration {
        static let maxConcurrentOperations: Int = 4
        static let cacheCountLimit: Int = 100
        static let cacheSizeLimit: Int = 50 * 1024 * 1024
        static let requestTimeout: TimeInterval = 30
        static let resourceTimeout: TimeInterval = 60
        static let carouselImageCount: Int = 5
        static let topCharactersLimit: Int = 3
    }
    
    // MARK: - Text
    
    enum Text {
        static let carouselTitle = "Carousel"
        static let statisticsTitle = "Statistics"
        static let searchPlaceholder = "Search"
        static let listTitle = "List 1"
        static let itemsFormat = "%d items"
        static let topCharactersTitle = "Top 3 Characters"
    }
    
    // MARK: - System Images
    
    enum SystemImage {
        static let magnifyingGlass = "magnifyingglass"
        static let xMarkCircleFill = "xmark.circle.fill"
        static let chartBarFill = "chart.bar.fill"
        static let listBullet = "list.bullet"
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let shadowOpacity: CGFloat = 0.3
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetX: CGFloat = 0
        static let shadowOffsetY: CGFloat = 2
        static let backgroundOpacity: CGFloat = 0.3
    }
    
    // MARK: - Font Sizes
    
    enum FontSize {
        static let searchIcon: CGFloat = 18
        static let clearButton: CGFloat = 16
        static let searchField: CGFloat = 16
    }
}
