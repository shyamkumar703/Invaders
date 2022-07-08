// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class GameOverResultItemView: UIView {

    private var avatarView: AvatarView = {
        let view = AvatarView(size: 50)
        view.userpicSize = 40
        return view
    }()

    private var barView = UIView()
    private var columnView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private lazy var scoreLabel: AnimatedLabel = {
        let label = AnimatedLabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.countingMethod = .easeOut
        label.decimalPoints = viewModel?.scoreType ?? .zero
        return label
    }()

    private var opponentWaitingView: VideoWithTitleView?
    private var columnHeightConstraint: NSLayoutConstraint?

    private var viewModel: GameOverResultItemViewModel?
    var animationDuration: AnimationDuration?
    
    init(_ viewModel: GameOverResultItemViewModel?) {
        
        self.viewModel = viewModel
        super.init(frame: .zero)

        self.viewModel?.viewDelegate = self
        setupViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        animateScoreLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        animateColumnHeight()
    }
}

// MARK: - Setup

private extension GameOverResultItemView {
    func setupViews() {
        guard viewModel != nil, viewModel?.isWaitingOpponent != true else {
            setupOpponentWaitingView()
            return
        }
        
        setupAvatarView()
        setupBarView()
        setupColumnView()
        setupScoreLabel()
    }
    
    func setupOpponentWaitingView() {
        if viewModel?.isWaitingForOpponentToFinishPlaying == true {
            opponentWaitingView = VideoWithTitleView(
                title: "Opponent is\nplaying",
                delegate: self
            )
        } else {
            opponentWaitingView = VideoWithTitleView(
                title: "Searching for\nOpponent",
                delegate: self
            )
        }
        guard let view = opponentWaitingView else { return }
        addSubview(view)
        setupOpponentWaitingViewConstrains()
    }

    func setupAvatarView() {
        avatarView.title = viewModel?.username
        avatarView.userpicUrl = viewModel?.userpic
        addSubview(avatarView)
        setupAvatarViewConstrains()
    }
    
    func setupBarView() {
        addSubview(barView)
        setupBarViewConstrains()
    }
    
    func setupScoreLabel() {
        addSubview(scoreLabel)
        setupScoreLabelConstrains()
    }
    
    func setupColumnView() {
        columnView.backgroundColor = viewModel?.isLooser == true
        ? .tungsten
        : TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR
        barView.addSubview(columnView)
        setupColumnViewConstrains()
    }
}

// MARK: - Animation

private extension GameOverResultItemView {
    func animateColumnHeight() {
        guard let viewModel = self.viewModel, viewModel.score != 0 else { return }
        let height = barView.bounds.height * CGFloat(viewModel.barHeight)
        self.layoutIfNeeded()
        
        columnHeightConstraint?.constant = height

        UIView.animate(
            withDuration: animationDuration?.value ?? 2,
            delay: 0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self = self else { return }
            self.barView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    func animateScoreLabel() {
        guard let viewModel = self.viewModel else { return }
        self.scoreLabel.countFromZero(
            to: Float(viewModel.score),
            duration: animationDuration ?? .brisk
        )
    }
}

// MARK: - Constants

private extension GameOverResultItemView {
    func setupOpponentWaitingViewConstrains() {
        opponentWaitingView?.translatesAutoresizingMaskIntoConstraints = false
        guard let view = opponentWaitingView else { return }
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupAvatarViewConstrains() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupBarViewConstrains() {
        barView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            barView.bottomAnchor.constraint(equalTo: avatarView.topAnchor, constant: -20),
            barView.centerXAnchor.constraint(equalTo: centerXAnchor),
            barView.widthAnchor.constraint(equalToConstant: 100)
            
        ])
    }
    
    func setupColumnViewConstrains() {
        columnView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            columnView.bottomAnchor.constraint(equalTo: barView.bottomAnchor),
            columnView.centerXAnchor.constraint(equalTo: centerXAnchor),
            columnView.widthAnchor.constraint(equalToConstant: 60)
        ])

        self.columnHeightConstraint = NSLayoutConstraint(
            item: self.columnView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 0
        )

        guard let heightConstraint = self.columnHeightConstraint else { return }
        barView.addConstraint(heightConstraint)
    }
    
    func setupScoreLabelConstrains() {
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreLabel.bottomAnchor.constraint(equalTo: columnView.topAnchor, constant: -10),
            scoreLabel.centerXAnchor.constraint(equalTo: columnView.centerXAnchor)
        ])
    }
}

// MARK: - GameOverResultItemViewDelegate

extension GameOverResultItemView: GameOverResultItemViewDelegate {
    func gameOverResultItemUpdated(userpic: URL?) {
        avatarView.userpicUrl = userpic
    }
}

// MARK: VideoWithTitleViewDelegate
extension GameOverResultItemView: VideoWithTitleViewDelegate {
    func respondToTap() {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred()
        NotificationCenter.default.post(name: .showAsyncExplanation, object: nil)
    }
}
