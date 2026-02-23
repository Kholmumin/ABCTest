//
//  CarouselCollectionCell.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

final class CarouselCollectionCell: UICollectionViewCell {

    // MARK: - Properties

    private var imageLoadTask: Task<Void, Never>?
    private var imageLoader: ImageLoadingService?

    // MARK: - UI Components

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray6
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.ActivityIndicator.color
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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

        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(with imageURL: URL, imageLoader: ImageLoadingService) {
        self.imageLoader = imageLoader
        imageLoadTask?.cancel()

        // Set placeholder image
        let placeholderConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        imageView.image = UIImage(systemName: ImageConstants.SFSymbol.photoPlaceholder, withConfiguration: placeholderConfig)
        imageView.tintColor = .systemGray3
        activityIndicator.startAnimating()

        // Load actual image
        imageLoadTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let image = try await imageLoader.loadImage(from: imageURL)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    UIView.transition(with: self.imageView,
                                    duration: 0.2,
                                    options: .transitionCrossDissolve) {
                        self.imageView.contentMode = .scaleAspectFill
                        self.imageView.tintColor = nil
                        self.imageView.image = image
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    // Keep placeholder on error
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageLoader = nil
        imageView.image = nil
        activityIndicator.stopAnimating()
    }
}

