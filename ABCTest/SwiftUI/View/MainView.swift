//
//  MainView.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

struct CarouselView: View {

    @ObservedObject private var viewModel: ListViewModel

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
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
                                .frame(height: 220)
                            }
                        }
                        .frame(height: 240)
                        .tabViewStyle(.page)
                        .indexViewStyle(.page)
                        Section {
                            ForEach(viewModel.filteredItems, id: \.self) { item in
                                ListItemView(item: item)
                                    .padding(.horizontal, 16)
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
            .navigationTitle("Carousel")
        }
    }
}

#Preview {
    let viewModel = ListViewModel(actions: ListViewModelActions { _, _ in })
    CarouselView(viewModel: viewModel)
}
