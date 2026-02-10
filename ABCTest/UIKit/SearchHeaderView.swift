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
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let magnifyingGlassImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search"
        tf.font = .systemFont(ofSize: 16)
        tf.borderStyle = .none
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let clearButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .secondaryLabel
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
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
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 60),

            magnifyingGlassImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            magnifyingGlassImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            magnifyingGlassImageView.widthAnchor.constraint(equalToConstant: 20),
            magnifyingGlassImageView.heightAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: magnifyingGlassImageView.trailingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),

            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            clearButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24)
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
