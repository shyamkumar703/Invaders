// Copyright © TriumphSDK. All rights reserved.

import UIKit

class SignUpIntroItemView: UIView {
    
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

private extension SignUpIntroItemView {
    func setupTitleLabel(with text: String) {
        titleLabel.text = text
        titleLabel.addInterlineSpacing(spacingValue: 3)
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

private extension SignUpIntroItemView {
    func setupIconImageViewConstrains() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 25),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
    
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
