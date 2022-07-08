// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class SupportExpandableHeaderView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkGrayish
        imageView.image = UIImage(systemName: BaseIcon.arrowRight.rawValue)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupRightImageView()
        setupTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isExpaned: Bool) {
        titleLabel.text = title
        update(with: isExpaned ? .open : .close)
    }
}

// MARK: - Setup

private extension SupportExpandableHeaderView {
    func setupRightImageView() {
        addSubview(rightImageView)
        setupRightImageViewConstrains()
    }

    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
}

// MARK: - Arrow rotation

extension SupportExpandableHeaderView {
    
    func update(with state: SupportExpandableCellState) {
        var rotationAngle: CGFloat
        switch state {
        case .open:
            rotationAngle = CGFloat.pi * 0.5
        case .close:
            rotationAngle = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.rightImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
}

// MARK: - Constrains

private extension SupportExpandableHeaderView {
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
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 78)
        ])
    }
}
