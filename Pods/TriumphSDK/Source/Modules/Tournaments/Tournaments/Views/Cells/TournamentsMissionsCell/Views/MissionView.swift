// Copyright © TriumphSDK. All rights reserved.

import Foundation
import UIKit

class MissionView: UIView {
    
    var viewModel: MissionViewModel? {
        didSet {
            updateView()
        }
    }
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Apple Color Emoji", size: 40)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var outerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 8
        
        stack.addArrangedSubview(missionInformationStack)
        stack.addArrangedSubview(claimIncentiveButtonView)
        return stack
    }()
    
    private lazy var missionInformationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        
        stack.addArrangedSubview(missionTitleLabel)
        stack.addArrangedSubview(missionDescriptionLabel)
        return stack
    }()
    
    private lazy var missionTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private lazy var missionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayish
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var claimIncentiveButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var claimIncentiveButton: RowButton = {
        let button = RowButton()
        button.addTarget(self, action: #selector(respondToTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
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
}

extension MissionView {
    func setupView() {
        setupClaimIncentiveButton()
        addSubview(emojiLabel)
        addSubview(outerStack)
    }
    
    func setupConstraints() {
        setupEmojiLabelConstraints()
        setupOuterStackConstraints()
    }
    
    func setupClaimIncentiveButton() {
        if #available(iOS 15.0, *) {
            claimIncentiveButton.configuration = .plain()
            claimIncentiveButton.configuration?.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 20,
                bottom: 0,
                trailing: 20
            )
        } else {
            // Fallback on earlier versions
            claimIncentiveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            claimIncentiveButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        claimIncentiveButtonView.addSubview(claimIncentiveButton)
    }
    
    func setupEmojiLabelConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiLabel.leftAnchor.constraint(equalTo: leftAnchor)
        ])
    }
    
    func setupOuterStackConstraints() {
        setupClaimIncentiveButtonConstraints()
        NSLayoutConstraint.activate([
            outerStack.leftAnchor.constraint(equalTo: emojiLabel.rightAnchor, constant: 12),
            outerStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            outerStack.bottomAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            outerStack.topAnchor.constraint(equalTo: emojiLabel.topAnchor)
        ])
    }
    
    func setupClaimIncentiveButtonConstraints() {
        NSLayoutConstraint.activate([
            claimIncentiveButton.leftAnchor.constraint(equalTo: claimIncentiveButtonView.leftAnchor),
            claimIncentiveButton.rightAnchor.constraint(equalTo: claimIncentiveButtonView.rightAnchor),
            claimIncentiveButton.centerYAnchor.constraint(equalTo: claimIncentiveButtonView.centerYAnchor),
            claimIncentiveButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func updateView() {
        emojiLabel.text = viewModel?.emoji
        missionTitleLabel.text = viewModel?.title
        missionDescriptionLabel.text = viewModel?.description
        claimIncentiveButton.setFlexibleTitle(viewModel?.generateRewardTitle())
        claimIncentiveButton.isHidden = false
    }
    
    func fallBackToLocked() {
        
    }
    
    @objc func respondToTap() {
        guard let model = viewModel?.model else { return }
        haptics.impactOccurred()
        viewModel?.delegate?.respondToTap(action: viewModel?.missionAction ?? .description, model: model)
    }
}
