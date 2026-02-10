//
//  SearchHeaderReusableView.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

final class SearchHeaderReusableView: UICollectionReusableView {

    let searchHeaderView = SearchHeaderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        searchHeaderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchHeaderView)
        backgroundColor = .clear
        NSLayoutConstraint.activate([
            searchHeaderView.topAnchor.constraint(equalTo: topAnchor),
            searchHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchHeaderView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
