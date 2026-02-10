//
//  AppDIContainter.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import Foundation

final class AppDIContainter: AppFlowCoordinatorDependencies {
    
    func makeMainCollectionView(actions: ListViewModelActions) -> MainCollectionViewController {
        let viewModel = ListViewModel(actions: actions)
        let viewController = MainCollectionViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeStatisticViewController(_ itemCount: Int, _ topCharacters: [(Character, Int)]) -> StatisticsViewController {
        let controller = StatisticsViewController.create(itemCount: itemCount, topCharacters: topCharacters)
        return controller
    }
}
