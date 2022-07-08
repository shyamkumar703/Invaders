//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit

fileprivate let iconSize: CGFloat = 35

final class SupportHeaderCell: UITableViewCell {
    
    var viewModel: SupportCellViewModel? {
        didSet {
            setupIcon()
            setupTitle()
        }
    }
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightSilver
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = .zero
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 21, weight: .regular)
        return label
    }()
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCommon()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCommon()
    }
}

// MARK: - Setup

private extension SupportHeaderCell {
    func setupCommon() {
        selectionStyle = .none
        backgroundColor = .clear
    }

    func setupIcon() {
        guard let iconName = viewModel?.leftIcon else { return }
        iconImageView.image = UIImage(systemName: iconName.rawValue)
        addSubview(iconImageView)
        setupIconConstrains()
    }
    
    func setupTitle() {
        titleLabel.text = viewModel?.title
        addSubview(titleLabel)
        setupTitleConstrains()
    }
}

// MARK: - Constrains

private extension SupportHeaderCell {
    func setupIconConstrains() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        ])
    }
    
    func setupTitleConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10)
        ])
    }
}
