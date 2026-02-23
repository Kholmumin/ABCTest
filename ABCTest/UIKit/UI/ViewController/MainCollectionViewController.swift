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
        case carousel(index: Int, urls: [URL])
        case list(Item)
    }

    private static let listHeaderElementKind = "list-search-header"
    private static let carouselFooterElementKind = "carousel-footer"
    
    // Track current page for carousel
    private var currentCarouselPage = 0

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

        collectionView.delegate = self

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
        let carouselCellRegistration = UICollectionView.CellRegistration<CarouselCollectionCell, URL> { [weak self] cell, indexPath, imageURL in
            guard let self = self else { return }
            cell.configure(with: imageURL, imageLoader: self.imageLoader)
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
        
        let carouselFooterRegistration = UICollectionView.SupplementaryRegistration<CarouselFooterReusableView>(
            elementKind: Self.carouselFooterElementKind
        ) { [weak self] footerView, _, _ in
            guard let self = self else { return }
            let imageCount = self.viewModel.carouselImageURLs.count
            footerView.configure(numberOfPages: imageCount, currentPage: self.currentCarouselPage)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, CollectionItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .carousel(let index, let urls):
                // Show the image at the specific index
                return collectionView.dequeueConfiguredReusableCell(
                    using: carouselCellRegistration,
                    for: indexPath,
                    item: urls[index]
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
            guard let self = self else { return nil }
            
            if kind == Self.carouselFooterElementKind && Section(rawValue: indexPath.section) == .carousel {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: carouselFooterRegistration,
                    for: indexPath
                )
            } else if kind == Self.listHeaderElementKind && Section(rawValue: indexPath.section) == .list {
                // Only show search header when data is loaded
                if self.viewModel.isLoading {
                    return nil
                }
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: searchHeaderRegistration,
                    for: indexPath
                )
            }
            
            return nil
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
        // Create one cell per image for horizontal scrolling with unique indices
        let carouselItems = viewModel.carouselImageURLs.enumerated().map { index, _ in 
            CollectionItem.carousel(index: index, urls: viewModel.carouselImageURLs)
        }
        snapshot.appendItems(carouselItems, toSection: .carousel)

        snapshot.appendSections([.list])
        snapshot.appendItems(viewModel.filteredItems.map { .list($0) }, toSection: .list)

        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}


// MARK: - UICollectionViewDelegate

extension MainCollectionViewController: UICollectionViewDelegate {
    private func updatePageControl() {
        // Ensure section exists before accessing supplementary view
        guard collectionView.numberOfSections > Section.carousel.rawValue else { return }
        
        // Find and update the footer view with current page
        if let footerView = collectionView.supplementaryView(
            forElementKind: Self.carouselFooterElementKind,
            at: IndexPath(item: 0, section: Section.carousel.rawValue)
        ) as? CarouselFooterReusableView {
            footerView.pageControl.currentPage = currentCarouselPage
        }
    }
}

// MARK: - LAYOUT

extension MainCollectionViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .carousel:
                return self?.createCarouselSection()
            case .list:
                return Self.createListSection()
            }
        }
        return layout
    }

    private func createCarouselSection() -> NSCollectionLayoutSection {
        // Item - each item takes full width without spacing
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Remove leading and trailing insets
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        // Group - horizontal scrolling
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(LayoutConstants.Size.carouselHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // Section with horizontal scrolling
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        // Add bottom padding for the page control
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
        
        // Track horizontal scrolling for page control updates
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, scrollOffset, layoutEnvironment in
            guard let self = self else { return }
            let containerWidth = layoutEnvironment.container.contentSize.width
            guard containerWidth > 0 else { return }
            
            let currentPage = Int(round(scrollOffset.x / containerWidth))
            if self.currentCarouselPage != currentPage {
                self.currentCarouselPage = currentPage
                self.updatePageControl()
            }
        }
        
        // Add footer for page control
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(30)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: MainCollectionViewController.carouselFooterElementKind,
            alignment: .bottom
        )
        footer.zIndex = 2
        section.boundarySupplementaryItems = [footer]

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
