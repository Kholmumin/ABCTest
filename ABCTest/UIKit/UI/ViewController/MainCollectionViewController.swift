//
//  MainCollectionView.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import Combine
import UIKit

final class MainCollectionViewController: UIViewController {
    
    // MARK: - UI Properties
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private lazy var floatingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: ImageConstants.SFSymbol.chartBarFill)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.FloatingButton.tint
        button.backgroundColor = UIColor.FloatingButton.background
        button.translatesAutoresizingMaskIntoConstraints = false
      
        button.layer.cornerRadius = LayoutConstants.CornerRadius.medium
        button.clipsToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = LayoutConstants.Shadow.opacity
        button.layer.shadowRadius = LayoutConstants.Shadow.radius
        button.layer.shadowOffset = LayoutConstants.Shadow.offset
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        return button
    }()

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
    private let viewModel: ListViewModel
    private let imageLoader: ImageLoadingService
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ListViewModel, imageLoader: ImageLoadingService) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        bindSearchToFilter()
        
        Task {
            await viewModel.loadItems()
            applySnapshot()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .white
        title = TextConstants.NavigationTitle.carousel
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubview(collectionView)
        view.addSubview(floatingButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            floatingButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Size.floatingButtonSize),
            floatingButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Size.floatingButtonSize),
            floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstants.Spacing.large),
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.Spacing.large)
        ])
        
        // Add tap gesture to dismiss keyboard when tapping on collection view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func floatingButtonTapped() {
        viewModel.didTapFloatingButton()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Data Source

    private func configureDataSource() {
        let carouselCellRegistration = UICollectionView.CellRegistration<CarouselCollectionCell, [URL]> { [weak self] cell, indexPath, imageURLs in
            guard let self = self else { return }
            cell.configure(with: imageURLs, imageLoader: self.imageLoader)
        }

        let listCellRegistration = UICollectionView.CellRegistration<ListCollectionCell, Item> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.configure(with: item, imageLoader: self.imageLoader)
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

        dataSource = UICollectionViewDiffableDataSource<Section, CollectionItem>(collectionView: collectionView) { collectionView, indexPath, item in
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
            guard let self = self, kind == Self.listHeaderElementKind,
                  Section(rawValue: indexPath.section) == .list else {
                return nil
            }
            // Only show search header when data is loaded
            if self.viewModel.isLoading {
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
                self?.updateListSection()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
    }
    
    private func updateListSection() {
        var snapshot = dataSource.snapshot()
        
        // Only update the list section items without recreating the entire snapshot
        if snapshot.sectionIdentifiers.contains(.list) {
            let currentListItems = snapshot.itemIdentifiers(inSection: .list)
            snapshot.deleteItems(currentListItems)
            snapshot.appendItems(viewModel.filteredItems.map { .list($0) }, toSection: .list)
            
            // Apply without animation to prevent header recreation and keyboard dismissal
            dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionItem>()

        snapshot.appendSections([.carousel])
        snapshot.appendItems([.carousel(viewModel.carouselImageURLs)], toSection: .carousel)

        snapshot.appendSections([.list])
        snapshot.appendItems(viewModel.filteredItems.map { .list($0) }, toSection: .list)

        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}


// MARK: - LAYOUT

extension MainCollectionViewController {
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
            heightDimension: .absolute(LayoutConstants.Size.carouselHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: LayoutConstants.Spacing.standard, trailing: 0)

        return section
    }

    private static func createListSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(LayoutConstants.Size.listItemEstimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(LayoutConstants.Size.listItemEstimatedHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        // Section with pinned search header
        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(LayoutConstants.Size.searchBarHeight + LayoutConstants.Spacing.standard * 2)
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
}
