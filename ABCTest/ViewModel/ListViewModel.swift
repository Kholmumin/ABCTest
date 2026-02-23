//
//  ListViewModel.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import Foundation
import Combine

struct ListViewModelActions {
    let showStatistics: (_ itemCount: Int, _ topCharacters: [(Character, Int)]) -> Void
}

protocol ListViewModelOutput {
    var searchText: String { get }
    var filteredItems: [Item] { get }
    var carouselImageURLs: [URL] { get }
    var topCharactersFromFiltered: [(Character, Int)] { get }
    var isLoading: Bool { get }
}

protocol ListViewModelInput {
    func topCharacters(limit: Int, from items: [Item]) -> [(Character, Int)]
    func didTapFloatingButton()
    func loadItems() async
}

typealias ListViewModelType = ListViewModelInput & ListViewModelOutput

final class ListViewModel: ObservableObject, ListViewModelType {
    
    private let actions: ListViewModelActions
    private let apiClient: ItemAPIClient
    
    // MARK: - INIT
    
    init(apiClient: ItemAPIClient, actions: ListViewModelActions) {
        self.apiClient = apiClient
        self.actions = actions
    }

    // MARK: - PROPERTIES
    
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published private var allItems: [Item] = []

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
    
    @MainActor
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            allItems = try await apiClient.fetchItems()
        } catch {
            // Handle error - could be propagated to the view
            print("Error loading items: \(error)")
            allItems = []
        }
    }
    
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
    
    func didTapFloatingButton() {
        actions.showStatistics(filteredItems.count, topCharactersFromFiltered)
    }
}
