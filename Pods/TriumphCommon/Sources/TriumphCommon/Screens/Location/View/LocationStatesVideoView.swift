// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation

final class LocationStatesVideoView: UIView {

    private lazy var queuePlayer = AVQueuePlayer()
    private var playerLayer: AVPlayerLayer?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = .zero
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 23, weight: .light)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupVideo()
        setupTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: UIApplication.shared
        )
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
    
    func setupVideo() {

        guard let playerItemStart = AVPlayerItem(named: "StatesVideoStart"),
              let playerItemContinue = AVPlayerItem(named: "StatesVideoContinue") else { return }
        self.queuePlayer = AVQueuePlayer(items: [playerItemStart, playerItemContinue])
   
        playerLayer = AVPlayerLayer(player: queuePlayer)
        guard let playerLayer = self.playerLayer else { return }

        self.layer.addSublayer(playerLayer)
        queuePlayer.play()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEndOfFirst(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    @objc func playerItemDidReachEndOfFirst(notification: Notification) {
        guard let playerItemContinue = AVPlayerItem(named: "StatesVideoContinue") else { return }
        queuePlayer.insert(playerItemContinue, after: self.queuePlayer.items().last)
    }
    
    @objc func didEnterBackground() {
        queuePlayer.pause()
    }
    
    @objc func willEnterForeground() {
        queuePlayer.play()
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

// MARK: - Setup

private extension LocationStatesVideoView {
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
}

// MARK: - Constrains

private extension LocationStatesVideoView {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
    }
}
