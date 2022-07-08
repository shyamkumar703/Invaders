// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class LocationHeaderView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "location.fill")
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightSilver
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 123, width: UIScreen.main.bounds.size.width - 40, height: 60))
        label.textColor = .white
        label.numberOfLines = .zero
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 23, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLocationIconImageView()
        setupTitleLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)
    }

    private func setupLocationIconImageView() {
        addSubview(iconImageView)
        setupLocationIconImageViewConstrains()
    }
    
    func setTitle(_ title: NSAttributedString?) {
        titleLabel.attributedText = title
    }
}

// MARK: - Constrains

private extension LocationHeaderView {
    func setupLocationIconImageViewConstrains() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 70)
        ])
    }
}
