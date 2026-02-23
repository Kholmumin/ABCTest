//
//  UIColor+Extensions.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

extension UIColor {
    
    // MARK: - Custom Colors
    
    static let containerBackground = UIColor.gray.withAlphaComponent(0.3)
    
    // MARK: - Chart Colors
    
    enum Chart {
        static let first = UIColor.systemBlue
        static let second = UIColor.systemGreen
        static let third = UIColor.systemOrange
        static let fallback = UIColor.systemGray
    }
    
    // MARK: - Page Control
    
    enum PageControl {
        static let current = UIColor.white
        static let indicator = UIColor.white.withAlphaComponent(0.5)
    }
    
    // MARK: - Activity Indicator
    
    enum ActivityIndicator {
        static let color = UIColor.gray
    }
    
    // MARK: - Floating Button
    
    enum FloatingButton {
        static let background = UIColor.systemBlue
        static let tint = UIColor.white
    }
}
