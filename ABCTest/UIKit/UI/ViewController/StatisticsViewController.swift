//
//  StatisticsViewController.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//


import UIKit

final class StatisticsViewController: UIViewController {

    private let itemCount: Int
    private let topCharacters: [(Character, Int)]
    
    static func create(
        itemCount: Int,
        topCharacters: [(Character, Int)]
    ) -> StatisticsViewController {
        return StatisticsViewController(
            itemCount: itemCount,
            topCharacters: topCharacters
        )
    }

    init(itemCount: Int, topCharacters: [(Character, Int)]) {
        self.itemCount = itemCount
        self.topCharacters = topCharacters
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildUI()
    }

    private func buildUI() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Statistics"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(titleLabel)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill

        // Row: List 1 — item count
        let countRow = statRow(
            icon: "list.bullet",
            title: "List 1",
            value: "\(itemCount) items"
        )
        countRow.backgroundColor = UIColor.systemGray6
        countRow.layer.cornerRadius = 12
        countRow.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        countRow.isLayoutMarginsRelativeArrangement = true
        stack.addArrangedSubview(countRow)

        // Top 3 characters
        let charsTitle = UILabel()
        charsTitle.text = "Top 3 Characters"
        charsTitle.font = .systemFont(ofSize: 17, weight: .semibold)
        stack.addArrangedSubview(charsTitle)

        let maxCount = topCharacters.first?.1 ?? 1
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange]
        for (index, entry) in topCharacters.enumerated() {
            let row = characterRow(
                rank: index + 1,
                character: entry.0,
                count: entry.1,
                maxCount: maxCount,
                color: index < colors.count ? colors[index] : .systemGray
            )
            stack.addArrangedSubview(row)
        }

        let charsContainer = UIStackView(arrangedSubviews: [stack])
        charsContainer.translatesAutoresizingMaskIntoConstraints = false
        charsContainer.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        charsContainer.isLayoutMarginsRelativeArrangement = true
        charsContainer.backgroundColor = UIColor.systemGray6
        charsContainer.layer.cornerRadius = 12
        view.addSubview(charsContainer)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            charsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            charsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            charsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func statRow(icon: String, title: String, value: String) -> UIStackView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15)
        valueLabel.textColor = .secondaryLabel
        let row = UIStackView(arrangedSubviews: [iconView, titleLabel, UIView(), valueLabel])
        row.axis = .horizontal
        row.spacing = 8
        iconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return row
    }


private func characterRow(rank: Int, character: Character, count: Int, maxCount: Int, color: UIColor) -> UIStackView {
        let rankLabel = UILabel()
        rankLabel.text = "\(rank)."
        rankLabel.font = .systemFont(ofSize: 15)
        rankLabel.textColor = .secondaryLabel
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        let charLabel = UILabel()
        charLabel.text = String(character)
        charLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        charLabel.textColor = color
        charLabel.setContentHuggingPriority(.required, for: .horizontal)
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.progress = maxCount > 0 ? Float(count) / Float(maxCount) : 0
        progress.tintColor = color
        progress.trackTintColor = color.withAlphaComponent(0.2)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.heightAnchor.constraint(equalToConstant: 8).isActive = true
        progress.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let countLabel = UILabel()
        countLabel.text = "= \(count)"
        countLabel.font = .systemFont(ofSize: 15, weight: .medium)
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [rankLabel, charLabel, progress, countLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }
}
