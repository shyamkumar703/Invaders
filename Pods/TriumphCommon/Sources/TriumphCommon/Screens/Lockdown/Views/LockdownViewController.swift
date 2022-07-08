// Copyright © TriumphSDK. All rights reserved.

import Foundation
import UIKit
import AVFoundation

public class LockdownViewController: BaseViewController {
    
    public var viewModel: LockdownViewModel? {
        didSet {
            Task { [weak self] in
                let shouldShowLockdownButton = await self?.viewModel?.shouldShowLockdownButton ?? false
                await MainActor.run { [weak self] in
                    self?.updateButton.isHidden = !shouldShowLockdownButton
                    self?.updateButton.setTitle(viewModel?.updateButtonTitle, for: .normal)
                }
            }
        }
    }
    
    private lazy var lockdownMessageLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var queuePlayer = AVQueuePlayer()
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    
    private lazy var videoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var updateButton: PrimaryButton = {
        let button = PrimaryButton()
        button.isGlowingEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoView()
        setupConstrains()

        Task { [weak self] in
            let message = await self?.viewModel?.message
            await MainActor.run { [weak self] in self?.lockdownMessageLabel.text = message }
        }

        updateButton.onPress { [weak self] in
            self?.viewModel?.updateButtonTapped()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .close)
        hideRightTopNavButton()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideRightTopNavButton()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = CGRect(origin: .zero, size: videoView.bounds.size)
    }
}

// MARK: - Setup Views

extension LockdownViewController {
    func setupVideoView() {
        guard let playerItem = AVPlayerItem(commonNamed: "lockdown", withExtension: "mp4") else { return }
        self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
        self.playerLayer?.videoGravity = .resizeAspectFill
        self.playerLooper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)
        self.queuePlayer.isMuted = true
        self.queuePlayer.play()

        guard let playerLayer = self.playerLayer else { return }
        videoView.layer.addSublayer(playerLayer)
        queuePlayer.addVideoObservers()
    }
    
    func setupConstrains() {
        view.addSubview(lockdownMessageLabel)
        lockdownMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        lockdownMessageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        lockdownMessageLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        lockdownMessageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true

        view.addSubview(videoView)
        videoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        videoView.topAnchor.constraint(equalTo: lockdownMessageLabel.bottomAnchor).isActive = true
        videoView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        videoView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        view.addSubview(updateButton)
        updateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        updateButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        updateButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
}
