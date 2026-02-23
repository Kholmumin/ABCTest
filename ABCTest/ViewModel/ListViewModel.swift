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

@MainActor
final class ListViewModel: ObservableObject, ListViewModelType {
    
    // MARK: - Properties
    
    private let actions: ListViewModelActions
    private let apiClient: ItemAPIClient
    
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published private var allItems: [Item] = []
    
    // MARK: - Initialization
    
    init(apiClient: ItemAPIClient, actions: ListViewModelActions) {
        self.apiClient = apiClient
        self.actions = actions
    }

    // MARK: - Computed Properties

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
        allItems.prefix(AppConstants.Configuration.carouselImageCount).compactMap(\.image)
    }

    var topCharactersFromFiltered: [(Character, Int)] {
        topCharacters(limit: AppConstants.Configuration.topCharactersLimit, from: filteredItems)
    }
    
    // MARK: - Methods
    
    func loadItems() async {
        isLoading = true
        do {
            allItems = try await apiClient.fetchItems()
        } catch {
            allItems = []
        }
        isLoading = false
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
