// Copyright © TriumphSDK. All rights reserved.

import UIKit

class IconWithTitleView: UIView {
    
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightSilver
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .lightSilver
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(icon: String, title: String) {
        super.init(frame: .zero)
        
        setupIconImageView(with: icon)
        setupTitleLabel(with: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Views

private extension IconWithTitleView {
    func setupTitleLabel(with text: String) {
        titleLabel.text = text
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupIconImageView(with name: String) {
        iconImageView.image = UIImage(systemName: name)
        addSubview(iconImageView)
        setupIconImageViewConstrains()
    }
}

// MARK: - Constrains

private extension IconWithTitleView {
    func setupIconImageViewConstrains() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 35),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        ])
    }
    
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
