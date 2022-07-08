// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

fileprivate let padding: CGFloat = 10

final class DashboardWinView: DashboardContainerView {

    private let successHaptics = UINotificationFeedbackGenerator()
    
    var viewModel: GameOverWinViewModel? {
        didSet {
            viewModel?.viewDelegate = self
            setupWaitingState()
        }
    }
    
    private var clockView: ClockView = {
        let view = ClockView()
        view.isHidden = true
        return view
    }()

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
        label.font = .rounded(ofSize: 48, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupClockView()
        setupTitleLabel()
        setupAmountLabel()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension DashboardWinView {
    func setupClockView() {
        addSubview(clockView)
        setupClockViewConstrains()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupAmountLabel() {
        addSubview(amountLabel)
        setupAmountLabelConstrains()
    }
    
    func setupAmountLabelAnimation() {
        guard let viewModel = self.viewModel else { return }
        amountLabel.countFromZero(
            to: viewModel.amount,
            duration: viewModel.animationDuration ?? .brisk
        )
        amountLabel.completion = { [weak self] in
            guard let self = self else { return }
            self.amountLabel.text = String(format: "$%.02f", viewModel.amount)
            self.successHaptics.notificationOccurred(.success) // One haptic when the score label comes back!
        }
    }
    
    func setupWaitingState() {
        titleLabel.text = viewModel?.title
        amountLabel.isHidden = true
        clockView.isHidden = false
        clockView.startAnimating()
    }
    
    func setupResultState() {
        titleLabel.text = viewModel?.title
        amountLabel.isHidden = false
        clockView.isHidden = true
        setupAmountLabelAnimation()
    }
}

// MARK: - GameOverWinViewModelViewDelegate

extension DashboardWinView: GameOverWinViewModelViewDelegate {
    func gameOverWinViewShouldUpdate() {
        if viewModel?.isWaitingOpponent == true {
            setupWaitingState()
            return
        }
        setupResultState()
    }
    
    func titleLabelUpdated(newTitle: String) {
        UIView.animate(withDuration: 0.2) {
            self.titleLabel.text = newTitle
        }
    }
}

// MARK: - Constrains

private extension DashboardWinView {
    func setupClockViewConstrains() {
        clockView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clockView.widthAnchor.constraint(equalToConstant: 75),
            clockView.heightAnchor.constraint(equalToConstant: 75),
            clockView.centerXAnchor.constraint(equalTo: centerXAnchor),
            clockView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
        ])
    }

    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
    
    func setupAmountLabelConstrains() {
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            amountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
