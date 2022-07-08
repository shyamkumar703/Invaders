// Copyright © TriumphSDK. All rights reserved.

import UIKit

fileprivate let padding: CGFloat = 10

@MainActor
final class DashboardHotStreakView: DashboardContainerView {
    
    var title: String? {
        didSet {
            infoButton.alpha = 1
            titleLabel.text = title
        }
    }
    

    var hotstreak: [Bool]? {
        didSet {
            updateStreakView()
        }
    }

    private lazy var haptics = UIImpactFeedbackGenerator()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "info.circle")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.isUserInteractionEnabled = false
        button.alpha = 0
        return button
    }()
    
    private lazy var streakView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
        setupStreakView()
        setupInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func infoButtonTap() {
        haptics.impactOccurred()
        NotificationCenter.default.post(name: .hotstreakInfoButton, object: nil)
    }
}

// MARK: - Setup

extension DashboardHotStreakView {
    func setupHeader() {
        addSubview(titleLabel)
        addSubview(infoButton)

        setupTitleLabelConstrains()
        setupInfoButtonConstrains()
    }
    
    func setupStreakView() {
        [Bool](repeatElement(false, count: Constants.HOT_STREAK_COUNT)).forEach { _ in
            let circleView = StreakCirecleView()
            circleView.isHighlighted = false
            streakView.addArrangedSubview(circleView)
        }

        addSubview(streakView)
        setupStreakViewConstrains()
    }

    func updateStreakView() {
        Task { @MainActor [weak self] in
            if streakView.subviews.isEmpty { return }
            let streak = hotstreak
            streak?.enumerated().forEach {
                if let circleView = self?.streakView.subviews[$0] as? StreakCirecleView {
                    if $1 {
                        if circleView.isHighlighted == false {
            
                            UIView.transition(
                                with: circleView,
                                duration: 0.33,
                                options: [.curveEaseOut],
                                animations: { circleView.isHighlighted = true }
                            )
                        }
                    } else {  
                        let isHighlighted = $1
                        UIView.transition(
                            with: circleView,
                            duration: 0.33,
                            options: [.curveEaseOut],
                            animations: { circleView.isHighlighted = isHighlighted }
                        )
                    }
                }
            }
        }

    }
    
    func setupInteraction() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoButtonTap)))
        self.isUserInteractionEnabled = true
    }
}

// MARK: - Constants

extension DashboardHotStreakView {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: infoButton.leadingAnchor, constant: -padding)
        ])
    }
    
    func setupInfoButtonConstrains() {
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoButton.widthAnchor.constraint(equalToConstant: 20),
            infoButton.heightAnchor.constraint(equalToConstant: 20),
            infoButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            infoButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6)
        ])
    }
    
    func setupStreakViewConstrains() {
        streakView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            streakView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            streakView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            streakView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -padding),
            streakView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(padding + 2)),
            streakView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    func setupStreakCircleViewConstrains(for view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 22),
            view.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}

