// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentHistoryCell: UICollectionViewCell {

    private var haptics = UIImpactFeedbackGenerator()
    
    var viewModel: TournamentsHistoryCellViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
            setupState()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let resultTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .lightGreen
        label.textAlignment = .right
        return label
    }()
    
    private let resultDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .right
        label.textColor = .grayish
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resultTitleLabel.removeFromSuperview()
        resultDescriptionLabel.removeFromSuperview()
    }
}

// MARK: - Tap Gestures

extension TournamentHistoryCell {
    @objc private func onTap() {
        haptics.impactOccurred()
    }
}

// MARK: - Setup

private extension TournamentHistoryCell {

    func setupState() {
        switch viewModel?.state {
        case .waiting:
            setupResultDescriptionLabel(isResultState: false)
        case .result:
            setupResultTitleLabel()
            setupResultDescriptionLabel(isResultState: true)
        default:
            return
        }
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupResultTitleLabel() {
        resultTitleLabel.setText(viewModel?.resultTitle)
        if viewModel?.gameType == .blitz {
            resultTitleLabel.textColor = .lightGreen
        } else {
            switch viewModel?.resultStatus {
            case .won: resultTitleLabel.textColor = .lightGreen
            case .lost: resultTitleLabel.textColor = .lostRed
            default: resultTitleLabel.textColor = .grayish
            }
        }
     
        addSubview(resultTitleLabel)
        setupResultTitleLabelConstraint()
    }
    
    func setupResultDescriptionLabel(isResultState: Bool = false) {
        resultDescriptionLabel.text = viewModel?.resultDescription
        addSubview(resultDescriptionLabel)
        setupResultDescriptionLabelConstraint(isResultState: isResultState)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
}

private extension TournamentHistoryCell {
    
}

// MARK: - Constrains

private extension TournamentHistoryCell {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
    }
    
    func setupResultTitleLabelConstraint() {
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        resultTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18).isActive = true
    }
    
    func setupResultDescriptionLabelConstraint(isResultState: Bool = false) {
        resultDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        resultDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        if isResultState == true {
            resultDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18).isActive = true
        } else {
            resultDescriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
}
