// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class SupportProfileCell: SupportBaseCell {
    
    var viewModel: SupportCellViewModel? {
        didSet {
            setupLeftImageView()
            setupRightImageView()
            setupTitleLabel()
        }
    }
    
    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkGrayish
        return imageView
    }()
    
    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkGrayish
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = .zero
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
}

// MARK: - Setup

private extension SupportProfileCell {
    func setupTitleLabel() {
        titleLabel.text = viewModel?.title
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }

    func setupLeftImageView() {
        guard let iconName = viewModel?.leftIcon?.rawValue else { return }
        leftImageView.image = UIImage(systemName: iconName)
        addSubview(leftImageView)
        setupLeftImageViewConstrains()
    }
    
    func setupRightImageView() {
        guard let iconName = viewModel?.rightIcon?.rawValue else { return }
        rightImageView.image = UIImage(systemName: iconName)
        addSubview(rightImageView)
        setupRightImageViewConstrains()
    }
}

// MARK: - Constrains

private extension SupportProfileCell {
    func setupLeftImageViewConstrains() {
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            leftImageView.heightAnchor.constraint(equalToConstant: 25),
            leftImageView.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func setupRightImageViewConstrains() {
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rightImageView.heightAnchor.constraint(equalToConstant: 20),
            rightImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
