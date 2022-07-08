// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

fileprivate let padding: CGFloat = 10

final class DashboardBalanceView: DashboardContainerView {
    
    private let successHaptics = UINotificationFeedbackGenerator()
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var amount: Double? {
        didSet {
            handleBalanceIncrease()
        }
    }
    
    var additionalInfo: FlexibleString? {
        didSet {
            descriptionLabel.setText(additionalInfo)
        }
    }

    func handleBalanceIncrease() {
        if let amount = amount {
            self.amountLabel.text = "$" + String(format: "%.2f", amount)
        }
        
    }
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private var amountLabel: AnimatedLabel = {
        
        let label = AnimatedLabel()
        label.customFormatBlock = {
            return "$%.02f"
        }
        label.font = .rounded(ofSize: 32, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        label.countingMethod = .easeOut
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .lightGreen
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTitleLabel()
        setupAmountLabel()
        setupDescriptionLabel()
    }
        
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension DashboardBalanceView {
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupAmountLabel() {
        addSubview(amountLabel)
        setupAmountLabelConstrains()
    }
    
    func setupDescriptionLabel() {
        addSubview(descriptionLabel)
        setupDescriptionLabelConstrains()
    }
}

// MARK: - Constrains

private extension DashboardBalanceView {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupAmountLabelConstrains() {
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            amountLabel.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -padding),
            amountLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupDescriptionLabelConstrains() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            descriptionLabel.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -padding),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
