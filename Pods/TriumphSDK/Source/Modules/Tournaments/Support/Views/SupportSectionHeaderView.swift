// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class SuppoortSectionHeaderView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = .zero
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.darkGrayish, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        return button
    }()
    
    private var viewModel: SupportSectionHeaderViewModel
    
    init(viewModel: SupportSectionHeaderViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupCommon()
        setupTitleLabel()
        setupButton()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension SuppoortSectionHeaderView {
    func setupCommon() {
        backgroundColor = .black
    }

    func setupTitleLabel() {
        titleLabel.text = viewModel.title
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupButton() {
        button.setAttributedTitle(prepareButtonTitle(), for: .normal)
        addSubview(button)
        setupButtonConstrains()
    }
    
    func prepareButtonTitle() -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: viewModel.buttonIcon.rawValue)?
            .withTintColor(.darkGrayish)
        imageAttachment.setImageHeight(height: 13)
        
        let fullString = NSMutableAttributedString(string: viewModel.buttonTitle)
        fullString.append(NSAttributedString(attachment: imageAttachment))
        let range = fullString.mutableString.range(of: viewModel.buttonTitle)
        fullString.addAttributes([.baselineOffset: 2], range: range)
        
        return fullString
    }
    
    @objc private func buttonTap() {
        let haptics = UIImpactFeedbackGenerator()
        haptics.impactOccurred()
        viewModel.buttonPressed()
    }
}

// MARK: - Constrains

extension SuppoortSectionHeaderView {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3)
        ])
    }
    
    func setupButtonConstrains() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
