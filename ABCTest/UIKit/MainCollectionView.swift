//
//  MainCollectionView.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import Combine
import UIKit

final class MainCollectionView: UIViewController {

    // MARK: - Section Types

    enum Section: Int, CaseIterable {
        case carousel
        case list
    }

    nonisolated enum CollectionItem: Hashable, Sendable {
        case carousel([URL])
        case list(Item)
    }

    private static let listHeaderElementKind = "list-search-header"

    // MARK: - Properties

    private var dataSource: UICollectionViewDiffableDataSource<Section, CollectionItem>!
    private let viewModel = ListViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .systemBackground
        return collection
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        bindSearchToFilter()
        applySnapshot()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .white
        title = "Carousel"

        view.addSubview(collection)

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Compositional Layout

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .carousel:
                return Self.createCarouselSection()
            case .list:
                return Self.createListSection()
            }
        }
        return layout
    }

    private static func createCarouselSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(240)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)

        return section
    }

    private static func createListSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(152)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(152)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        // Section with pinned search header
        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: Self.listHeaderElementKind,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [header]

        return section
    }

    // MARK: - Data Source

    private func configureDataSource() {
        // Register cells
        let carouselCellRegistration = UICollectionView.CellRegistration<CarouselCollectionCell, [URL]> { cell, indexPath, imageURLs in
            cell.configure(with: imageURLs)
        }

        let listCellRegistration = UICollectionView.CellRegistration<ListCollectionCell, Item> { cell, indexPath, item in
            cell.configure(with: item)
        }

        let searchHeaderRegistration = UICollectionView.SupplementaryRegistration<SearchHeaderReusableView>(
            elementKind: Self.listHeaderElementKind
        ) { [weak self] headerView, _, _ in
            guard let self else { return }
            headerView.searchHeaderView.setSearchText(self.viewModel.searchText)
            headerView.searchHeaderView.onSearchTextChange = { [weak self] text in
                self?.viewModel.searchText = text
            }
        }

        // Configure data source (type-safe: no AnyHashable casting)
        dataSource = UICollectionViewDiffableDataSource<Section, CollectionItem>(collectionView: collection) { collectionView, indexPath, item in
            switch item {
            case .carousel(let imageURLs):
                return collectionView.dequeueConfiguredReusableCell(
                    using: carouselCellRegistration,
                    for: indexPath,
                    item: imageURLs
                )
            case .list(let listItem):
                return collectionView.dequeueConfiguredReusableCell(
                    using: listCellRegistration,
                    for: indexPath,
                    item: listItem
                )
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let _ =  self, kind == Self.listHeaderElementKind,
                  Section(rawValue: indexPath.section) == .list else {
                return nil
            }
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: searchHeaderRegistration,
                for: indexPath
            )
        }
    }

    private func bindSearchToFilter() {
        viewModel.$searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionItem>()

        snapshot.appendSections([.carousel])
        snapshot.appendItems([.carousel(viewModel.carouselImageURLs)], toSection: .carousel)

        snapshot.appendSections([.list])
        snapshot.appendItems(viewModel.filteredItems.map { .list($0) }, toSection: .list)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
