//
//  SearchHeaderView.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

final class SearchHeaderView: UIView {

    // MARK: - Callback

    var onSearchTextChange: ((String) -> Void)?

    // MARK: - UI

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = LayoutConstants.CornerRadius.large
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let magnifyingGlassImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: ImageConstants.SFSymbol.magnifyingGlass))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = TextConstants.Search.placeholder
        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: ImageConstants.SFSymbol.xmarkCircleFill), for: .normal)
        button.tintColor = .secondaryLabel
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(magnifyingGlassImageView)
        containerView.addSubview(textField)
        containerView.addSubview(clearButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: LayoutConstants.Spacing.standard),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstants.Spacing.standard),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LayoutConstants.Spacing.standard),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -LayoutConstants.Spacing.standard),
            containerView.heightAnchor.constraint(equalToConstant: LayoutConstants.Size.searchBarHeight),

            magnifyingGlassImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: LayoutConstants.Spacing.standard),
            magnifyingGlassImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            magnifyingGlassImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.Size.iconSmall),
            magnifyingGlassImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.Size.iconSmall),

            textField.leadingAnchor.constraint(equalTo: magnifyingGlassImageView.trailingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -LayoutConstants.Spacing.medium),

            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -LayoutConstants.Spacing.standard),
            clearButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: LayoutConstants.Size.iconMedium),
            clearButton.heightAnchor.constraint(equalToConstant: LayoutConstants.Size.iconMedium)
        ])

        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    }

    // MARK: - Public

    func setSearchText(_ text: String) {
        if textField.text != text {
            textField.text = text
        }
        updateClearButtonVisibility()
    }

    // MARK: - Actions

    @objc private func textDidChange() {
        let text = textField.text ?? ""
        updateClearButtonVisibility()
        onSearchTextChange?(text)
    }

    @objc private func clearTapped() {
        textField.text = ""
        updateClearButtonVisibility()
        onSearchTextChange?("")
    }

    private func updateClearButtonVisibility() {
        clearButton.isHidden = (textField.text ?? "").isEmpty
    }
}
