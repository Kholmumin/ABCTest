//
//  TaskApp.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

@main
struct TaskApp: App {
    let diContainer = AppSwiftUIDIContainer()

    var body: some Scene {
        WindowGroup {
             AppSwiftUIRootView(diContainer: diContainer)
        }
    }
}
