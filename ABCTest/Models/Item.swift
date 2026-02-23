//
//  Item.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import Foundation

nonisolated struct Item: Hashable, Sendable {
    let id: String = UUID().uuidString
    let image: URL?
    let title: String
    let description: String
}
