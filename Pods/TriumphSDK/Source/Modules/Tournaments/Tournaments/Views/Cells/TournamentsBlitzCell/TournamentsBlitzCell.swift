// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation

final class TournamentsBlitzCell: UICollectionViewCell {

    var viewModel: TournamentsBlitzCellViewModel? {
        didSet {
            setupViewModel()
            setupApearance()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = .zero
        label.font = .rounded(ofSize: 32, weight: .semibold)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private var enterButton: TournamentsBlitzCellButton = {
        let button = TournamentsBlitzCellButton(type: .system)
        return button
    }()
    
    private lazy var queuePlayer = AVQueuePlayer()
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width, height: self.bounds.height)
    }

    @objc private func enterButtonTap() {
        viewModel?.enterButtonPressed()
    }
}

// MARK: - Setup

private extension TournamentsBlitzCell {
    func setupViewModel() {
        titleLabel.text = viewModel?.title
        
        subTitleLabel.text = viewModel?.subtitle
        subTitleLabel.addCharacterSpacing(kernValue: -0.3)
        
        enterButton.title = viewModel?.enterButtonTitle
    }
    
    func setupCommon() {
        layer.cornerRadius = 10
        layer.applyGradient(of: TriumphSDK.colors.TRIUMPH_GRADIENT_COLORS, atAngle: 45)
    }
    
    func setupApearance() {
        enterButton.layer.doGlowAnimation(withColor: .white, from: 1, to: 2)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupSubTitleLabel() {
        addSubview(subTitleLabel)
        setupSubTitleLabelConstrains()
    }
    
    func setupEnterButton() {
        addSubview(enterButton)
        enterButton.addTarget(self, action: #selector(enterButtonTap), for: .touchUpInside)
        setupEnterButtonConstrains()
    }
    
    func setupUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let playerItem = AVPlayerItem(named: "blitzMode", withExtension: "mp4") else { return }
            self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
            self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
            self.playerLayer?.videoGravity = .resizeAspectFill
            self.playerLooper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)
            self.queuePlayer.isMuted = true
            self.queuePlayer.play()
            
            guard let playerLayer = self.playerLayer else { return }
            playerLayer.masksToBounds = true
            playerLayer.cornerRadius = 10
            self.layer.addSublayer(playerLayer)
            
            self.setupEnterButton()
            self.queuePlayer.addVideoObservers()
        }
    }
}

// MARK: - Constrains

private extension TournamentsBlitzCell {
    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupSubTitleLabelConstrains() {
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    func setupEnterButtonConstrains() {
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            enterButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            enterButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            enterButton.widthAnchor.constraint(equalToConstant: 120),
            enterButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
