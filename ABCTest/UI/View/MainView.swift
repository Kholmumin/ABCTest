import SwiftUI

struct CarouselView: View {

    @ObservedObject private var viewModel: ListViewModel

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            TabView {
                                ForEach(viewModel.carouselImageURLs, id: \.self) { url in
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(height: AppConstants.Layout.carouselImageHeight)
                                }
                            }
                            .frame(height: AppConstants.Layout.carouselHeight)
                            .tabViewStyle(.page)
                            .indexViewStyle(.page)
                            
                            Section {
                                ForEach(viewModel.filteredItems, id: \.self) { item in
                                    ListItemView(item: item)
                                        .padding(.horizontal, AppConstants.Layout.defaultPadding)
                                }
                            } header: {
                                VStack(spacing: 0) {
                                    SearchBar(searchText: $viewModel.searchText)
                                }
                                .padding()
                            }
                        }
                    }
                    
                    StatisticsFloatingButton(action: { viewModel.didTapFloatingButton() })
                }
            }
            .navigationTitle(AppConstants.Text.carouselTitle)
            .task {
                await viewModel.loadItems()
            }
        }
    }
}

#Preview {
    let viewModel = ListViewModel(apiClient: MockItemAPIClient(), actions: ListViewModelActions { _, _ in })
    CarouselView(viewModel: viewModel)
}
