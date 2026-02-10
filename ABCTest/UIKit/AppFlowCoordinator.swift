//
//  AppFlowCoordinator.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

protocol AppFlowCoordinatorDependencies {
    func makeMainCollectionView(actions: ListViewModelActions) -> MainCollectionViewController
    func makeStatisticViewController(_ itemCount: Int, _ topCharacters: [(Character, Int)]) -> StatisticsViewController
}


final class AppFlowCoordinator {
    private let diContainer: AppFlowCoordinatorDependencies
    private let navigationController: UINavigationController
    
    init(diContainer: AppFlowCoordinatorDependencies, navigationController: UINavigationController) {
        self.diContainer = diContainer
        self.navigationController = navigationController
    }
    
    func start() {
        let actions = ListViewModelActions(showStatistics: showStatistics(_:_:))
        let mainController = diContainer.makeMainCollectionView(actions: actions)
        navigationController.viewControllers = [mainController]
    }
    
    func showStatistics(_ itemCount: Int, _ topCharacters: [(Character, Int)]) {
        let statisticsVC = diContainer.makeStatisticViewController(itemCount, topCharacters)

        statisticsVC.modalPresentationStyle = .pageSheet
        if let sheet = statisticsVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.topViewController?
            .present(statisticsVC, animated: true)
    }
}
