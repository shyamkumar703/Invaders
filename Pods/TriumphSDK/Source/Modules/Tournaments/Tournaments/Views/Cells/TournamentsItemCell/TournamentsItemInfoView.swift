// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsItemInfoView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .grayish
        label.numberOfLines = 2
        return label
    }()

    func configure(with title: String, subtile: String) {
        titleLabel.text = title
        subTitleLabel.text = subtile
        
        setupTitleLabel()
        setupSubTitleLabel()
    }
}

// MARK: - Setup

private extension TournamentsItemInfoView {
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupSubTitleLabel() {
        addSubview(subTitleLabel)
        subTitleLabel.addInterlineSpacing(spacingValue: 6)
        setupSubTitleLabelConstrains()
    }
}

// MARK: - Constrains

private extension TournamentsItemInfoView {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }
    
    func setupSubTitleLabelConstrains() {
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }
}
