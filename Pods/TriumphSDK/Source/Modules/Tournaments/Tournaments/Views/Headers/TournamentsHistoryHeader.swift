// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentHistoryHeader: UICollectionReusableView {

    var text: String? {
        didSet {
            titleLabel.text = text
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .grayish
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension TournamentHistoryHeader {
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
}

// MARK: - Constrains

private extension TournamentHistoryHeader {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30)
        ])
    }
}
