// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class MatchingViewController<ViewModel: MatchingViewModel>: StepViewController {

    var viewModel: ViewModel
    lazy var playersView = MatchingPlayersView(
        viewModel: viewModel.matchingViewModel
    )
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution  = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    lazy var attentionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupScrollView()
        scrollView.isScrollEnabled = false
        setupPlayersView()
        setupStartButton()
        super.viewDidLoad()
        setupStackView()
        setupAttentionLabelConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .close)
        leftTopBarButtonEnabled(true)
        hideRightTopNavButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}

// MARK: - Setup

private extension MatchingViewController {
    func setupPlayersView() {
        contentView.addSubview(playersView)
        setupPlayersViewConstrains()
    }
    
    func setupStartButton() {
        continueButton.setTitle(viewModel.startButtonTitle, for: .normal)
        continueButton.onPress { [weak self] in
            
            guard let self = self else { return }
            self.viewModel.startButtonPressed()
        }
    }

    func setupStackView() {
        for i in 0..<2 {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 20
            
            let firstView = MatchingConditionView()
            firstView.viewModel = viewModel.matchingConditionViewModels[i * 2]
            stack.addArrangedSubview(firstView)
            
            let secondView = MatchingConditionView()
            secondView.viewModel = viewModel.matchingConditionViewModels[(i * 2) + 1]
            stack.addArrangedSubview(secondView)
            
            stackView.addArrangedSubview(stack)
        }

        contentView.addSubview(stackView)
        setupStackViewConstrains()
    }
    
    func setupAttentionLabelConstraints() {
        view.addSubview(attentionLabel)
        NSLayoutConstraint.activate([
            attentionLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            attentionLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            attentionLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
    }
}

// MARK: - Constrains

private extension MatchingViewController {
    func setupConstrains(for itemView: UIView) {
        itemView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        itemView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupPlayersViewConstrains() {
        playersView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playersView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 90),
            playersView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playersView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playersView.heightAnchor.constraint(equalToConstant: 106)
        ])
    }
    
    func setupStackViewConstrains() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: playersView.bottomAnchor, constant: 60),
            stackView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -60),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
        ])
    }
}
