//
//  MainView.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

struct CarouselView: View {
    
    @StateObject private var viewModel = ListViewModel(actions: ListViewModelActions { itemCount, topCharacters in
        
    })
    @State private var showStatistics = false
    
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
                StatisticsFloatingButton(action: { showStatistics = true })
            }
            .navigationTitle("Carousel")
            .sheet(isPresented: $showStatistics) {
                StatisticsSheet(
                    itemCount: viewModel.filteredItems.count,
                    topCharacters: viewModel.topCharactersFromFiltered
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    CarouselView()
}
