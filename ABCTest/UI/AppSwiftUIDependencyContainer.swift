import SwiftUI

protocol AppSwiftUIFlowCoordinatorDependencies {
    func makeCarouselView(actions: ListViewModelActions) -> CarouselView
    func makeStatisticsSheet(itemCount: Int, topCharacters: [(Character, Int)]) -> StatisticsSheet
}

final class AppSwiftUIDependencyContainer: AppSwiftUIFlowCoordinatorDependencies {
    
    // MARK: - Properties
    
    private let apiClient: ItemAPIClient
    private let imageLoader: ImageLoading
    
    // MARK: - Initialization
    
    init(
        apiClient: ItemAPIClient = MockItemAPIClient(),
        imageLoader: ImageLoading = ImageLoader.shared
    ) {
        self.apiClient = apiClient
        self.imageLoader = imageLoader
    }
    
    // MARK: - Factory Methods
    
    func makeCarouselView(actions: ListViewModelActions) -> CarouselView {
        let viewModel = ListViewModel(apiClient: apiClient, actions: actions)
        return CarouselView(viewModel: viewModel)
    }
    
    func makeStatisticsSheet(itemCount: Int, topCharacters: [(Character, Int)]) -> StatisticsSheet {
        return StatisticsSheet(itemCount: itemCount, topCharacters: topCharacters)
    }
}
