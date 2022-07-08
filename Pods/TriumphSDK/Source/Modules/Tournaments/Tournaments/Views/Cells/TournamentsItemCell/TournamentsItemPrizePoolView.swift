// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsItemPrizePoolView: UIView {
    private var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.rounded(ofSize: 34, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: String, title: String) {
        setupValueLabel(value)
        setupTitleLabel(title)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.applyGradient(of: TriumphSDK.colors.TRIUMPH_GRADIENT_COLORS, atAngle: -45)
    }
}

// MARK: - Setup

private extension TournamentsItemPrizePoolView {
    func setupCommon() {
        layer.cornerRadius = 10
    }

    func setupValueLabel(_ value: String) {
        valueLabel.text = value
        addSubview(valueLabel)
        setupValueLabelConstrains()
    }
    
    func setupTitleLabel(_ title: String) {
        titleLabel.text = title
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
}

// MARK: - Constrains

private extension TournamentsItemPrizePoolView {
    func setupValueLabelConstrains() {
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18)
        ])
    }
    
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 0)
        ])
    }
}
