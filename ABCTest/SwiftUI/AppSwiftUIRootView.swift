//
//  AppSwiftUIRootView.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

struct AppSwiftUIRootView: View {
    
    @StateObject private var coordinator: AppSwiftUIFlowCoordinator
    
    init(dependencyContainer: AppSwiftUIFlowCoordinatorDependencies) {
        _coordinator = StateObject(wrappedValue: AppSwiftUIFlowCoordinator(dependencyContainer: dependencyContainer))
    }
    
    var body: some View {
        coordinator.makeCarouselView()
            .sheet(isPresented: $coordinator.showStatistics) {
                coordinator.makeStatisticsSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
    }
}

#Preview {
    AppSwiftUIRootView(dependencyContainer: AppSwiftUIDependencyContainer())
}

