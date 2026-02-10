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
    private var imageViews: [UIImageView] = []
    private var loadingTasks: [URLSessionDataTask] = []

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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
        // Cancel any ongoing image loading tasks
        loadingTasks.forEach { $0.cancel() }
        loadingTasks.removeAll()

        // Clear existing image views
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()

        self.imageURLs = imageURLs

        // Configure page control
        pageControl.numberOfPages = imageURLs.count
        pageControl.currentPage = 0

        // Create image views for each URL
        for (index, url) in imageURLs.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .systemGray6
            imageView.translatesAutoresizingMaskIntoConstraints = false

            scrollView.addSubview(imageView)
            imageViews.append(imageView)

            // Layout image view
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(index) * contentView.bounds.width)
            ])

            // Load image
            loadImage(from: url, into: imageView)
        }

        // Set scroll view content size
        scrollView.contentSize = CGSize(
            width: contentView.bounds.width * CGFloat(imageURLs.count),
            height: contentView.bounds.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Cancel any ongoing image loading tasks
        loadingTasks.forEach { $0.cancel() }
        loadingTasks.removeAll()

        // Clear existing image views
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()

        imageURLs.removeAll()
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        scrollView.contentOffset = .zero
    }

    // MARK: - Helper Methods

    private func loadImage(from url: URL, into imageView: UIImageView) {
        let task = URLSession.shared.dataTask(with: url) { [weak imageView] data, response, error in
            guard let imageView = imageView,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                return
            }

            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task.resume()
        loadingTasks.append(task)
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
