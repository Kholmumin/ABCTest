//
//  CarouselCollectionCell.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

final class CarouselCollectionCell: UICollectionViewCell {

    // MARK: - Properties

    private var imageURLs: [URL] = []
    private var pageContainers: [UIView] = []
    private var imageViews: [UIImageView] = []
    private var activityIndicators: [UIActivityIndicatorView] = []
    private var imageLoadTasks: [Task<Void, Never>] = []
    private var imageLoader: ImageLoadingService?
    private var isLayoutReady = false

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        return scrollView
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.PageControl.current
        pageControl.pageIndicatorTintColor = UIColor.PageControl.indicator
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.backgroundColor = .clear

        contentView.addSubview(scrollView)
        contentView.addSubview(pageControl)

        scrollView.delegate = self

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LayoutConstants.Spacing.medium),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: LayoutConstants.Size.iconLarge)
        ])
    }

    // MARK: - Configuration

    func configure(with imageURLs: [URL], imageLoader: ImageLoadingService) {
        self.imageLoader = imageLoader
        imageLoadTasks.forEach { $0.cancel() }
        imageLoadTasks.removeAll()

        clearPageViews()

        self.imageURLs = imageURLs

        pageControl.numberOfPages = imageURLs.count
        pageControl.currentPage = 0

        createPageViews(count: imageURLs.count)

        // Reset scroll view state completely
        scrollView.contentOffset = .zero
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        
        // Force layout immediately to ensure scroll view is ready
        setNeedsLayout()
        layoutIfNeeded()

        loadImages()
    }

    private func clearPageViews() {
        pageContainers.forEach { $0.removeFromSuperview() }
        pageContainers.removeAll()
        imageViews.removeAll()
        activityIndicators.removeAll()
    }

    private func createPageViews(count: Int) {
        for index in 0..<count {
            let container = UIView()
            container.backgroundColor = .systemGray6
            container.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(container)
            pageContainers.append(container)

            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = .systemGray6
            // Set placeholder image immediately
            let placeholderConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
            imageView.image = UIImage(systemName: ImageConstants.SFSymbol.photoPlaceholder, withConfiguration: placeholderConfig)
            imageView.tintColor = .systemGray3
            container.addSubview(imageView)
            imageViews.append(imageView)

            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = UIColor.ActivityIndicator.color
            indicator.hidesWhenStopped = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.startAnimating()
            container.addSubview(indicator)
            activityIndicators.append(indicator)

            // Constrain to previous container or scroll view
            let leadingConstraint: NSLayoutConstraint
            if index == 0 {
                leadingConstraint = container.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor)
            } else {
                leadingConstraint = container.leadingAnchor.constraint(equalTo: pageContainers[index - 1].trailingAnchor)
            }

            var constraints = [
                container.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                container.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                container.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                container.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
                leadingConstraint,

                imageView.topAnchor.constraint(equalTo: container.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ]
            
            // Anchor the last container to the trailing edge to establish content size
            if index == count - 1 {
                constraints.append(container.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor))
            }

            NSLayoutConstraint.activate(constraints)
        }
    }

    private func loadImages() {
        guard let imageLoader = imageLoader else { return }
        
        for (index, url) in imageURLs.enumerated() {
            guard index < imageViews.count, index < activityIndicators.count else { continue }

            let imageView = imageViews[index]
            let indicator = activityIndicators[index]

            let task = Task { [weak imageView, weak indicator] in
                do {
                    let image = try await imageLoader.loadImage(from: url)
                    await MainActor.run {
                        indicator?.stopAnimating()
                        // Smoothly replace placeholder with actual image
                        UIView.transition(with: imageView ?? UIView(),
                                        duration: 0.2,
                                        options: .transitionCrossDissolve) {
                            imageView?.contentMode = .scaleAspectFill
                            imageView?.tintColor = nil
                            imageView?.image = image
                        }
                    }
                } catch {
                    await MainActor.run {
                        indicator?.stopAnimating()
                        // Keep placeholder on error
                    }
                }
            }
            imageLoadTasks.append(task)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateScrollViewLayout()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Re-enable scrolling when cell moves to window (becomes visible)
        if window != nil {
            scrollView.isScrollEnabled = true
            scrollView.isPagingEnabled = true
        }
    }

    private func updateScrollViewLayout() {
        let pageWidth = scrollView.bounds.width
        let pageHeight = scrollView.bounds.height
        
        guard pageWidth > 0, pageHeight > 0 else { return }

        // Content size is now automatically determined by Auto Layout constraints
        // so we don't need to set it manually
        
        // Ensure scroll view is properly configured for paging
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true

        isLayoutReady = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageLoadTasks.forEach { $0.cancel() }
        imageLoadTasks.removeAll()

        clearPageViews()

        imageURLs.removeAll()
        imageLoader = nil
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        scrollView.contentOffset = .zero
        scrollView.contentSize = .zero
        isLayoutReady = false
    }
}

// MARK: - UIScrollViewDelegate

extension CarouselCollectionCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = max(0, min(currentPage, imageURLs.count - 1))
    }
}
