// Copyright © TriumphSDK. All rights reserved.

import Foundation

final class SupportPrimaryCell: SupportBaseCell {
    
    var viewModel: SupportCellViewModel? {
        didSet {
            setupLeftImageView()
            setupRightImageView()
            setupTitleLabel()
            setupSubTitleLabel()
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
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGrayish
        label.numberOfLines = .zero
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
}

// MARK: - Setup

private extension SupportPrimaryCell {
    func setupTitleLabel() {
        titleLabel.text = viewModel?.title
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupSubTitleLabel() {
        subTitleLabel.text = viewModel?.subTitle
        addSubview(subTitleLabel)
        setupSubTitleLabelConstrains()
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

private extension SupportPrimaryCell {
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
            titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupSubTitleLabelConstrains() {
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: centerYAnchor),
            subTitleLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 16),
            subTitleLabel.heightAnchor.constraint(equalToConstant: 23)
        ])
    }
}
