//
//  AppSwiftUIFlowCoordinator.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI
import Combine

final class AppSwiftUIFlowCoordinator: ObservableObject {
    
    private let diContainer: AppSwiftUIFlowCoordinatorDependencies
    
    @Published var showStatistics = false
    @Published private(set) var statisticsItemCount: Int = 0
    @Published private(set) var statisticsTopCharacters: [(Character, Int)] = []
    
    init(diContainer: AppSwiftUIFlowCoordinatorDependencies) {
        self.diContainer = diContainer
    }
    
    func makeCarouselView() -> CarouselView {
        let actions = ListViewModelActions(showStatistics: showStatistics(_:_:))
        return diContainer.makeCarouselView(actions: actions)
    }
    
    func makeStatisticsSheet() -> StatisticsSheet {
        return diContainer.makeStatisticsSheet(
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

