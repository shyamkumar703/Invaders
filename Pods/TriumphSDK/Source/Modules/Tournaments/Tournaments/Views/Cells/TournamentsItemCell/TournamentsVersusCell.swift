// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsVersusCell: UICollectionViewCell {
    
    private let haptics = UIImpactFeedbackGenerator()

    var viewModel: TournamentsVersusViewModel? {
        didSet {
            viewModel?.cellViewDelegate = self
            setupEmojiView()
            setupItemStack()
            setupTokensLabel()
        }
    }
    
    private var backView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 0.0
        view.layer.cornerRadius = 10
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Apple Color Emoji", size: 48)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var itemViewStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        
        stack.addArrangedSubview(infoViewStack)
        stack.addArrangedSubview(playButtonView)
        return stack
    }()
    
    private lazy var infoViewStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing  = 4
        stack.addArrangedSubview(tournamentNameLabel)
        stack.addArrangedSubview(tournamentPrizeLabel)
        return stack
    }()
    
    private lazy var tournamentNameLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(ofSize: 16, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var tournamentPrizeLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var playButtonView: UIView = {
        let outerView = UIView()
        return outerView
    }()
    
    private lazy var tokensLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .grayish
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var playButton: RowButton = {
        let button = RowButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TournamentsVersusCell: TournamentsVersusCellViewDelegate {
    func updatePriceAndTokens() {
        tokensLabel.attributedText = viewModel?.maxTokensTitle
        playButton.title = viewModel?.entryTitle
    }
}

// MARK: - Setup

private extension TournamentsVersusCell {
    
    func setupBackgroundView() {
        addSubview(backView)
        setupBackgroundViewConstrains()
    }
    
    func setupEmojiView() {
        // set text
        emojiLabel.text = viewModel?.emoji
        // add constraints
        addSubview(emojiLabel)
        setupEmojiViewConstraints()
    }
    
    func setupTokensLabel() {
        tokensLabel.attributedText = viewModel?.maxTokensTitle
        addSubview(tokensLabel)
        setupTokensLabelConstraints()
    }
    
    func setupItemStack() {
        // set text
        tournamentNameLabel.text = viewModel?.versusTitle
        tournamentPrizeLabel.text = "Win \(viewModel?.prizePoolValue ?? "")"
        // add constraints
        setupPlayButtonView()
        addSubview(itemViewStack)
        setupItemStackConstraints()
    }
    
    func setupPlayButtonView() {
        
        playButton.title = viewModel?.entryTitle
        
        if #available(iOS 15.0, *) {
            playButton.configuration = .plain()
            playButton.configuration?.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 12,
                bottom: 0,
                trailing: 12
            )
        } else {
            // Fallback on earlier versions
            playButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 12)
            playButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 12)
        }
        
        playButtonView.addSubview(playButton)
        setupPlayButtonViewConstraints()
    }
    
    @objc func playButtonPressed() {
        haptics.impactOccurred()
        viewModel?.playPressed()
    }
}

// MARK: - Constrains

private extension TournamentsVersusCell {
    func setupBackgroundViewConstrains() {
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupEmojiViewConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        ])
    }
    
    func setupItemStackConstraints() {
        NSLayoutConstraint.activate([
            itemViewStack.topAnchor.constraint(equalTo: emojiLabel.topAnchor, constant: 8),
            itemViewStack.leftAnchor.constraint(equalTo: emojiLabel.rightAnchor, constant: 8),
            itemViewStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            itemViewStack.bottomAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: -8)
        ])
    }
    
    func setupPlayButtonViewConstraints() {
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: playButtonView.topAnchor, constant: 4),
            playButton.leftAnchor.constraint(equalTo: playButtonView.leftAnchor),
            playButton.rightAnchor.constraint(equalTo: playButtonView.rightAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupTokensLabelConstraints() {
        NSLayoutConstraint.activate([
            tokensLabel.centerXAnchor.constraint(equalTo: playButton.centerXAnchor),
            tokensLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 4)
        ])
    }
}
