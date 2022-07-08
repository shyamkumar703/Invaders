// Copyright © TriumphSDK. All rights reserved.

import UIKit

fileprivate let padding: CGFloat = 10

final class DashboardAccountView: DashboardContainerView {

    var viewModel: DashboardAccountViewModel? {
        didSet {
            setupViewModel()
        }
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .grayish
        label.numberOfLines = 1
        return label
    }()
    
    private var depositButton = DashboardButton()
    private var cashOutButton = DashboardButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupTitleLabel()
        setupSubtitleLabel()
        setupDepositButton()
        setpuCashOutButton()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension DashboardAccountView {
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        setupSubtitleLabelConstrains()
    }
    
    func setupDepositButton() {
        addSubview(depositButton)
        setupDepositButtonConstrains()
    }
    
    func setpuCashOutButton() {
        addSubview(cashOutButton)
        setupCachOutButtonConstrains()
    }
}

// MARK: - Setup ViewModel

private extension DashboardAccountView {
    func setupViewModel() {
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.subtitle
        
        setupViewModelDepositButton()
        setupViewModelCashOutButton()
    }
    
    func setupViewModelDepositButton() {
        depositButton.name = viewModel?.depositButtonContent.title
        depositButton.icon = viewModel?.depositButtonContent.icon
        depositButton.onPress { [weak self] in
            self?.viewModel?.depositButtonPress()
        }
    }
    
    func setupViewModelCashOutButton() {
        cashOutButton.name = viewModel?.cashOutButtonContent.title
        cashOutButton.icon = viewModel?.cashOutButtonContent.icon
        cashOutButton.onPress { [weak self] in
            self?.viewModel?.cashOutButtonPress()
        }
    }
}

// MARK: - Constrains

private extension DashboardAccountView {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
    
    func setupSubtitleLabelConstrains() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
    
    func setupDepositButtonConstrains() {
        depositButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // FIXME: - top anchor shouldnt be hardcoded.
            // this whole buttons block has to be centered between title and the bottom of the container
            depositButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            depositButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            depositButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            depositButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    func setupCachOutButtonConstrains() {
        cashOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cashOutButton.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 10),
            cashOutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            cashOutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            cashOutButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
}
