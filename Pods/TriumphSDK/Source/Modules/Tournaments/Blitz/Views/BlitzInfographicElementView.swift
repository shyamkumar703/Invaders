// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class BlitzInfographicElementView: UIView {
    
    enum BlitzInfographicColumn {
        case left, right
    }
    
    enum BlitzInfographicElementType {
        case unit, title
        case withTriangle(BlitzInfographicColumn)
    }
    
    var title: String?
    var type: BlitzInfographicElementType?

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    init(title: String, type: BlitzInfographicElementType) {
        self.title = title
        self.type = type
        super.init(frame: .zero)
        
        setupTitleLabel()
        setupConstrains()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension BlitzInfographicElementView {
    func setupCommon() {
        
    }
    
    func setupTitleLabel() {
        titleLabel.text = title
        addSubview(titleLabel)
        
        switch type {
        case .unit:
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            titleLabel.textColor = .grayish
        case .withTriangle(let column):
            titleLabel.font = .rounded(ofSize: 17, weight: .semibold)
            switch column {
            case .left:
                titleLabel.textColor = .white
            case .right:
                titleLabel.textColor = .green
            }
        case .title:
            titleLabel.font = .rounded(ofSize: 24, weight: .semibold)
            titleLabel.textColor = .white
        default: break
        }
    }
}

// MARK: - Constrains

private extension BlitzInfographicElementView {
    func setupConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        setupTitleLabelConstrains()
    }
    
    func setupTitleLabelConstrains() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
