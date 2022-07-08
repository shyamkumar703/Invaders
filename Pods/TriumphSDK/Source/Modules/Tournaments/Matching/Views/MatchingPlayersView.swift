// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation
import TriumphCommon

final class MatchingPlayersView: UIView {

    let haptic = UIImpactFeedbackGenerator(style: .heavy)
    private var animationTimer: Timer?
    private var hapticTimer: FlexibleTimer?

    private var userAvatarView = AvatarView()
    private var opponentAvatarView = AvatarView(withPlayer: AVPlayer(named: "matching", withExtension: "mp4"))
    
    private let vsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 40)
        return label
    }()
    
    var viewModel: MatchingPlayersViewModel
    
    init(viewModel: MatchingPlayersViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupCommon()
        setupUserAvatarView()
        setupOpponentAvatarView()
        setupVsLabel()
        setupContent()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopHaptic),
            name: .stopMatchingHaptics,
            object: nil
        )
    }
    
    deinit {
//        animationTimer?.invalidate()
//        hapticTimer?.invalidate()
        NotificationCenter.default.removeObserver(
            self,
            name: .stopMatchingHaptics,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stopAvatarsChanging() {
        animationTimer?.invalidate()
        animationTimer = nil
        // setupOpponentAvatarViewModel()
    }
    
    func setupFinalAvatar() {
        if let url = viewModel.opponentImageUrl {
            opponentAvatarView.userpicUrl = url
        } else {
            opponentAvatarView.userpicImage = UIImage(named: "default-avatar")
        }
    }
    
    @objc func stopHaptic() {
        animationTimer?.invalidate()
        hapticTimer?.invalidate()
    }
}

// MARK: - Setup

private extension MatchingPlayersView {
    func setupCommon() {
        backgroundColor = .black
    }
    
    func setupContent() {
        Task { [weak self] in
            self?.userAvatarView.title = self?.viewModel.userNameTitle
            self?.userAvatarView.userpicUrl = await self?.viewModel.userpicUrl
            self?.vsLabel.text =   self?.viewModel.vsTitle
            await MainActor.run { [weak self] in
                self?.runOpponentMatchingAnimation()
            }
        }
    }
    
    func setupUserAvatarView() {
        addSubview(userAvatarView)
        setupUserAvatarViewConstrains()
    }
    
    func setupOpponentAvatarView() {
        addSubview(opponentAvatarView)
        setupOpponentAvatarViewConstrains()
    }
    
    func setupVsLabel() {
        addSubview(vsLabel)
        setupVsLabelConstrains()
    }
}

// MARK: - Animations

private extension MatchingPlayersView {
    private func runOpponentMatchingAnimation() {
        animationTimer = Timer.scheduledTimer(
            timeInterval: 8.5,
            target: self,
            selector: #selector(imageUpdate),
            userInfo: nil,
            repeats: true
        )
        hapticTimer = FlexibleTimer(
            RepeatingTimerElement(interval: 0.1, numberOfRepeats: 35, onFire: fireHaptic),
            RepeatingTimerElement(interval: 0.2, numberOfRepeats: 10, onFire: fireHaptic),
            RepeatingTimerElement(interval: 0.5, numberOfRepeats: 4, onFire: fireHaptic)
        )
        self.opponentAvatarView.title = "Matching..."
    }
    
    @objc func fireHaptic() {
        haptic.impactOccurred()
    }
    
    @objc func imageUpdate() {
        self.animationTimer?.invalidate()
        self.hapticTimer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupOpponentAvatarViewModel()
        }
    }
    
    func setupOpponentAvatarViewModel() {
        opponentAvatarView.title = viewModel.opponentNameTitle.isEmpty ?
                                      "enemy\(Int.random(in: 100...9999))" :
                                      self.viewModel.opponentNameTitle
        setupFinalAvatar()
    }
}

// MARK: - Constrains

private extension MatchingPlayersView {
    func setupAvatarViewConstrains(_ view: inout AvatarView) {
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 80),
            view.heightAnchor.constraint(equalToConstant: 106)
        ])
    }
    
    func setupUserAvatarViewConstrains() {
        userAvatarView.translatesAutoresizingMaskIntoConstraints = false
        setupAvatarViewConstrains(&userAvatarView)
        userAvatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
    }
    
    func setupOpponentAvatarViewConstrains() {
        opponentAvatarView.translatesAutoresizingMaskIntoConstraints = false
        setupAvatarViewConstrains(&opponentAvatarView)
        opponentAvatarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
    }
    
    func setupVsLabelConstrains() {
        vsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            vsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
