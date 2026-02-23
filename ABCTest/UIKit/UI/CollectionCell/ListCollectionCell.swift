//
//  ListCollectionCell.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

final class ListCollectionCell: UICollectionViewCell {

    // MARK: - Properties

    private var imageLoadTask: Task<Void, Never>?
    private var imageLoader: ImageLoadingService?

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = LayoutConstants.CornerRadius.small
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = LayoutConstants.CornerRadius.small
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = LayoutConstants.Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        contentView.addSubview(containerView)
        containerView.addSubview(itemImageView)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(textStackView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.Spacing.standard),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.Spacing.standard),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.Spacing.standard),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LayoutConstants.Spacing.standard),
            containerView.heightAnchor.constraint(equalToConstant: LayoutConstants.Size.containerHeight),

            itemImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: LayoutConstants.Spacing.standard),
            itemImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.Size.imageSize),
            itemImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.Size.imageSize),

            activityIndicator.centerXAnchor.constraint(equalTo: itemImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: itemImageView.centerYAnchor),

            textStackView.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: LayoutConstants.Spacing.medium),
            textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -LayoutConstants.Spacing.standard),
            textStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }


    func configure(with item: Item, imageLoader: ImageLoadingService) {
        self.imageLoader = imageLoader
        titleLabel.text = item.title
        descriptionLabel.text = item.description

        itemImageView.image = nil

        if let imageURL = item.image {
            activityIndicator.startAnimating()

            imageLoadTask = Task { [weak self] in
                guard let self = self else { return }
                
                do {
                    let image = try await imageLoader.loadImage(from: imageURL)
                    await MainActor.run {
                        self.itemImageView.image = image
                        self.activityIndicator.stopAnimating()
                    }
                } catch {
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageLoader = nil

        itemImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        activityIndicator.stopAnimating()
    }
}
