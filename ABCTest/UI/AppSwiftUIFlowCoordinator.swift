import SwiftUI
import Combine

final class AppSwiftUIFlowCoordinator: ObservableObject {
    
    private let dependencyContainer: AppSwiftUIFlowCoordinatorDependencies
    
    @Published var showStatistics = false
    @Published private(set) var statisticsItemCount: Int = 0
    @Published private(set) var statisticsTopCharacters: [(Character, Int)] = []
    
    private lazy var carouselView: CarouselView = {
        let actions = ListViewModelActions(showStatistics: showStatistics(_:_:))
        return dependencyContainer.makeCarouselView(actions: actions)
    }()
    
    init(dependencyContainer: AppSwiftUIFlowCoordinatorDependencies) {
        self.dependencyContainer = dependencyContainer
    }
    
    func makeCarouselView() -> CarouselView {
        return carouselView
    }
    
    func makeStatisticsSheet() -> StatisticsSheet {
        return dependencyContainer.makeStatisticsSheet(
            itemCount: statisticsItemCount,
            topCharacters: statisticsTopCharacters
        )
    }
    
    private func showStatistics(_ itemCount: Int, _ topCharacters: [(Character, Int)]) {
        statisticsItemCount = itemCount
        statisticsTopCharacters = topCharacters
        showStatistics = true
    }
}

