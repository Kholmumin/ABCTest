//
//  ListViewModel.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import Foundation
import Combine

struct ListViewModelActions {
    //USED FOR ROUTING
}

protocol ListViewModelOutput {
    var searchText: String { get }
    var filteredItems: [Item] { get }
    var carouselImageURLs: [URL] { get }
    var topCharactersFromFiltered: [(Character, Int)] { get }
}

protocol ListViewModelInput {
    func topCharacters(limit: Int, from items: [Item]) -> [(Character, Int)]
}

typealias ListViewModelType = ListViewModelInput & ListViewModelOutput

final class ListViewModel: ObservableObject, ListViewModelType {
    
    // MARK: - INIT
    
    init(items: [Item] = StaticModels.shared.sampleItems) {
        self.allItems = items
    }

    // MARK: - PROPERTIES
    
    @Published var searchText: String = ""
    private let allItems: [Item]

    var filteredItems: [Item] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return allItems
        }
        return allItems.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.description.localizedCaseInsensitiveContains(query)
        }
    }

    var carouselImageURLs: [URL] {
        allItems.prefix(5).compactMap(\.image)
    }

    var topCharactersFromFiltered: [(Character, Int)] {
        topCharacters(limit: 3, from: filteredItems)
    }
    
    // MARK: - METHODS
    
    func topCharacters(limit: Int = 3, from items: [Item]) -> [(Character, Int)] {
        items
            .map { ($0.title + $0.description).lowercased() }
            .joined()
            .filter(\.isLetter)
            .reduce(into: [:]) { counts, char in
                counts[char, default: 0] += 1
            }
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
}
