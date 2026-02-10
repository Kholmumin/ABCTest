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
    private var imageLoadTasks: [ImageLoadTask] = []
    private var containerLeadingConstraints: [NSLayoutConstraint] = []
    private let imageLoader = ImageLoader.shared
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
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .white.withAlphaComponent(0.5)
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

            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    // MARK: - Configuration

    func configure(with imageURLs: [URL]) {
        imageLoadTasks.forEach { $0.cancel() }
        imageLoadTasks.removeAll()

        clearPageViews()

        self.imageURLs = imageURLs

        pageControl.numberOfPages = imageURLs.count
        pageControl.currentPage = 0

        createPageViews(count: imageURLs.count)

        setNeedsLayout()
        layoutIfNeeded()

        loadImages()
    }

    private func clearPageViews() {
        pageContainers.forEach { $0.removeFromSuperview() }
        pageContainers.removeAll()
        imageViews.removeAll()
        activityIndicators.removeAll()
        containerLeadingConstraints.removeAll()
    }

    private func createPageViews(count: Int) {
        for _ in 0..<count {
            let container = UIView()
            container.backgroundColor = .systemGray5
            container.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(container)
            pageContainers.append(container)

            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(imageView)
            imageViews.append(imageView)

            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = .gray
            indicator.hidesWhenStopped = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.startAnimating()
            container.addSubview(indicator)
            activityIndicators.append(indicator)

            let leadingConstraint = container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0)
            containerLeadingConstraints.append(leadingConstraint)

            NSLayoutConstraint.activate([
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
            ])
        }
    }

    private func loadImages() {
        for (index, url) in imageURLs.enumerated() {
            guard index < imageViews.count, index < activityIndicators.count else { continue }

            let imageView = imageViews[index]
            let indicator = activityIndicators[index]

            let task = imageLoader.loadImage(from: url) { [weak imageView, weak indicator] image in
                indicator?.stopAnimating()
                imageView?.image = image
            }
            imageLoadTasks.append(task)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateScrollViewLayout()
    }

    private func updateScrollViewLayout() {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }

        for (index, constraint) in containerLeadingConstraints.enumerated() {
            constraint.constant = CGFloat(index) * pageWidth
        }

        let newContentSize = CGSize(
            width: pageWidth * CGFloat(max(1, imageURLs.count)),
            height: scrollView.bounds.height
        )

        if scrollView.contentSize != newContentSize {
            scrollView.contentSize = newContentSize
        }

        isLayoutReady = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageLoadTasks.forEach { $0.cancel() }
        imageLoadTasks.removeAll()

        clearPageViews()

        imageURLs.removeAll()
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
