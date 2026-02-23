import SwiftUI

struct AppSwiftUIRootView: View {
    
    @StateObject private var coordinator: AppSwiftUIFlowCoordinator
    
    init(dependencyContainer: AppSwiftUIFlowCoordinatorDependencies) {
        _coordinator = StateObject(wrappedValue: AppSwiftUIFlowCoordinator(dependencyContainer: dependencyContainer))
    }
    
    var body: some View {
        coordinator.makeCarouselView()
            .sheet(isPresented: $coordinator.showStatistics) {
                StatisticsSheet(
                    itemCount: coordinator.statisticsItemCount,
                    topCharacters: coordinator.statisticsTopCharacters
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
    }
}

#Preview {
    AppSwiftUIRootView(dependencyContainer: AppSwiftUIDependencyContainer())
}

