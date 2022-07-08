// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class DashboardButton: BaseButton {
    
    private var action: (() -> Void)?
    private lazy var haptics = UIImpactFeedbackGenerator()
    
    var dashboardColor: UIColor? {
        didSet {
            color = dashboardColor
            colorOnPress = dashboardColor
            colorDisabled = dashboardColor
        }
    }
    
    var dashboardTitleColor: UIColor? {
        didSet {
            colorTitle = dashboardTitleColor
            colorTitleDisabled = dashboardTitleColor
        }
    }
    
    var cornerRadius: CGFloat? {
        didSet {
            layer.cornerRadius = cornerRadius ?? 19
        }
    }
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var icon: String? {
        didSet {
            guard let icon = self.icon else { return }
            let image = UIImage(systemName: icon)
            iconImageView.image = image
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCommon()
        setupColors()
        setupNameLabel()
        setupIconImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()

        setupGestureRecognizer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if shouldUseGradient { layer.applyGradient(of: TriumphSDK.colors.TRIUMPH_GRADIENT_COLORS, atAngle: 45) }
    }
}

// MARK: - Setup

private extension DashboardButton {
    func setupCommon() {
        layer.cornerRadius = 19
        layer.masksToBounds = true
    }
    
    func setupColors() {
        color = .tungsten
        colorOnPress = .darkGray
        colorDisabled = .darkGray
        colorTitleDisabled = .grayish
        
        nameLabel.textColor = .white
        iconImageView.tintColor = .white
    }
    
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        setupNameLabelConstrains()
    }
    
    func setupIconImageView() {
        addSubview(iconImageView)
        setupIconImageViewConstrains()
    }
}

// MARK: - Action

extension DashboardButton {
    @objc private func onTap() {
        haptics.impactOccurred()
        action?()
    }
    
    func onPress(action: @escaping () -> Void) {
        self.action = action
    }
}

// MARK: - Constrains

private extension DashboardButton {
    func setupNameLabelConstrains() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    }
    
    func setupIconImageViewConstrains() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
