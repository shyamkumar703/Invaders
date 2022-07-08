// Copyright © TriumphSDK. All rights reserved.
import AVKit
import UIKit

protocol VideoWithTitleViewDelegate: AnyObject {
    func respondToTap()
}

class VideoWithTitleView: UIView {
    
    private var waitingVideoView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .lightSilver
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(respondToTap))
    }()
    
    private lazy var queuePlayer = AVQueuePlayer()
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    
    weak var delegate: VideoWithTitleViewDelegate?
    
    init(title: String, delegate: VideoWithTitleViewDelegate) {
        super.init(frame: .zero)
        
        setupIconImageView()
        setupTitleLabel(with: title)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = waitingVideoView.bounds
    }
    
    @objc func respondToTap() {
        delegate?.respondToTap()
    }
}

// MARK: - Setup Views

private extension VideoWithTitleView {
    func setupTitleLabel(with text: String) {
        titleLabel.text = text
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupIconImageView() {
        guard let playerItem = AVPlayerItem(named: "looping", withExtension: ".mp4") else { return }
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: self.queuePlayer)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.isMuted = true
        queuePlayer.play()
        
        guard let playerLayer = self.playerLayer else { return }
        playerLayer.masksToBounds = true
        playerLayer.cornerRadius = 10
        waitingVideoView.layer.addSublayer(playerLayer)
        
        waitingVideoView.addGestureRecognizer(tapGestureRecognizer)
        addSubview(waitingVideoView)
        setupWaitingVideoViewConstraints()
    }
}

// MARK: - Constrains

private extension VideoWithTitleView {
    func setupWaitingVideoViewConstraints() {
        waitingVideoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingVideoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            waitingVideoView.widthAnchor.constraint(equalToConstant: 120),
            waitingVideoView.heightAnchor.constraint(equalToConstant: 120),
            waitingVideoView.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        ])
    }
    
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: waitingVideoView.bottomAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
