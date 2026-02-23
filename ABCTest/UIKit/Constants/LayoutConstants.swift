//
//  LayoutConstants.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

enum LayoutConstants {
    
    // MARK: - Spacing
    
    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let standard: CGFloat = 16
        static let large: CGFloat = 20
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 20
        static let medium: CGFloat = 28
        static let large: CGFloat = 30
    }
    
    // MARK: - Sizes
    
    enum Size {
        static let iconSmall: CGFloat = 20
        static let iconMedium: CGFloat = 24
        static let iconLarge: CGFloat = 28
        static let floatingButtonSize: CGFloat = 56
        static let imageSize: CGFloat = 100
        static let containerHeight: CGFloat = 120
        static let searchBarHeight: CGFloat = 60
        static let carouselHeight: CGFloat = 240
        static let listItemEstimatedHeight: CGFloat = 152
    }
    
    // MARK: - Shadow
    
    enum Shadow {
        static let opacity: Float = 0.3
        static let radius: CGFloat = 4
        static let offset: CGSize = CGSize(width: 0, height: 2)
    }
}
