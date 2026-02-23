//
//  AppSwiftUIDependencyContainer.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

protocol AppSwiftUIFlowCoordinatorDependencies {
    func makeCarouselView(actions: ListViewModelActions) -> CarouselView
    func makeStatisticsSheet(itemCount: Int, topCharacters: [(Character, Int)]) -> StatisticsSheet
}

final class AppSwiftUIDependencyContainer: AppSwiftUIFlowCoordinatorDependencies {
    
    func makeCarouselView(actions: ListViewModelActions) -> CarouselView {
        let viewModel = ListViewModel(actions: actions)
        return CarouselView(viewModel: viewModel)
    }
    
    func makeStatisticsSheet(itemCount: Int, topCharacters: [(Character, Int)]) -> StatisticsSheet {
        return StatisticsSheet(itemCount: itemCount, topCharacters: topCharacters)
    }
}

