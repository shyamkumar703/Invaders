// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class LocationCollectionViewCell: UICollectionViewCell {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightSilver
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 21, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func configure(with title: String?) {
        titleLabel.text = title
    }
}

// MARK: - Constrains

private extension LocationCollectionViewCell {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
