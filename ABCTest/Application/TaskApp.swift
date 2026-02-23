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
