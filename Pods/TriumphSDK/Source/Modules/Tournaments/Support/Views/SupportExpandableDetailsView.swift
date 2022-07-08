// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class SupportExpandableDetailsView: UIView {

    let detailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayish
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(detailsText: String?) {
        detailsLabel.text = detailsText
    }
}

// MARK: - Setup

private extension SupportExpandableDetailsView {
    func setupCommon() {
        setupDetailsView()
    }
    
    func setupDetailsView() {
        addSubview(detailsLabel)
        setupDetailsViewConstrains()
    }
}

// MARK: - Constrains

private extension SupportExpandableDetailsView {
    func setupDetailsViewConstrains() {
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            detailsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: topAnchor),
            detailsLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
