// Copyright © TriumphSDK. All rights reserved.

import Foundation
import UIKit

final class TournamentsWelcomeRewardCell: UICollectionViewCell {
    
    var viewModel: WelcomeRewardCellViewModel? {
        didSet {
            updateView()
        }
    }
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        stack.addArrangedSubview(claimButton)
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 2
        return label
    }()
    
    private let claimButton: RowButton = {
        let button = RowButton()
        return button
    }()
    
    private let haptics = UIImpactFeedbackGenerator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(stack)
        backgroundColor = .lead
        layer.cornerRadius = 10
        contentView.isUserInteractionEnabled = false
    }
    
    func setupConstraints() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            claimButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func updateView() {
        if let viewModel = viewModel {
            titleLabel.text = viewModel.title
            subtitleLabel.text = viewModel.subtitle
            Task { [weak self] in
                let claimButtonTitle = await self?.viewModel?.generateClaimButtonTitle()
                await MainActor.run { [weak self] in self?.claimButton.setAttributedTitle(claimButtonTitle, for: .normal) }
            }
            claimButton.removeTarget(self, action: #selector(claimButtonTapped), for: .touchUpInside)
            claimButton.addTarget(self, action: #selector(claimButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func claimButtonTapped() {
        haptics.impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.stack.alpha = 0
        })
        viewModel?.onClaimTapped()
    }
}
