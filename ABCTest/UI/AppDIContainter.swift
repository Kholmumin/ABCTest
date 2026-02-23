import Foundation

final class AppDIContainter: AppFlowCoordinatorDependencies {
    
    // MARK: - Shared Services
    
    private lazy var imageLoader: ImageLoadingService = {
        ImageLoader()
    }()
    
    private lazy var apiClient: ItemAPIClient = {
        MockItemAPIClient(delay: 0.5, shouldSimulateError: false)
    }()
    
    // MARK: - Factory Methods
    
    func makeMainCollectionView(actions: ListViewModelActions) -> MainCollectionViewController {
        let viewModel = ListViewModel(apiClient: apiClient, actions: actions)
        let viewController = MainCollectionViewController(viewModel: viewModel, imageLoader: imageLoader)
        return viewController
    }
    
    func makeStatisticViewController(_ itemCount: Int, _ topCharacters: [(Character, Int)]) -> StatisticsViewController {
        let controller = StatisticsViewController.create(itemCount: itemCount, topCharacters: topCharacters)
        return controller
    }
}
