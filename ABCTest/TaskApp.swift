//
//  TaskApp.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

@main
struct TaskApp: App {
    let dependencyContainer = AppSwiftUIDependencyContainer()

    var body: some Scene {
        WindowGroup {
            AppSwiftUIRootView(dependencyContainer: dependencyContainer)
        }
    }
}
