// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation

final class BlitzInfographicView: UIView {
    private lazy var queuePlayer = AVQueuePlayer()
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    
    var viewModel: BlitzInfographicViewModel? {
        didSet {
            viewModel?.viewDelegate = self
            setupListView()
            setupListViewSubviews()
        }
    }
    
    private let barView: UIView = UIView()
    
    private let listView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution  = .fillProportionally
        view.spacing = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCommon()
        setupBarView()
        setupVideoBackground()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.barView.frame
    }
}

// MARK: - Setup

extension BlitzInfographicView {
    func setupCommon() {
        
    }
    
    func setupVideoBackground() {
        guard let playerItem = AVPlayerItem(named: "money", withExtension: "mp4") else { return }
        self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
        self.playerLayer?.videoGravity = .resizeAspectFill
        self.playerLooper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)
        self.queuePlayer.isMuted = true
        self.queuePlayer.play()
        self.queuePlayer.rate = 0.75

        guard let playerLayer = self.playerLayer else { return }
        self.barView.layer.addSublayer(playerLayer)
        queuePlayer.addVideoObservers()
    }

    func setupBarView() {
        addSubview(barView)
        setupBarViewConstrains()
    }
    
    func setupListView() {
        addSubview(listView)
        setupListViewConstrains()
    }
    
    func setupListViewSubviews() {
        viewModel?.items.forEach {
            if $0.score.isEmpty || $0.prize.isEmpty { return }
            let view = BlitzInfographicItemView(viewModel: $0)
            listView.addArrangedSubview(view)
            self.setupListItemConstrains(view, type: $0.type)
        }
    }
}

// MARK: - Constrains

extension BlitzInfographicView {
    func setupBarViewConstrains() {
        barView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            barView.centerXAnchor.constraint(equalTo: centerXAnchor),
            barView.centerYAnchor.constraint(equalTo: centerYAnchor),
            barView.heightAnchor.constraint(equalTo: heightAnchor),
            barView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    func setupListViewConstrains() {
        listView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: topAnchor),
            listView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            listView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            listView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
    
    func setupListItemConstrains(_ item: BlitzInfographicItemView, type: BlitzInfographicItemType) {
        item.translatesAutoresizingMaskIntoConstraints = false
        switch type {
        case .unit:
            item.heightAnchor.constraint(equalToConstant: 30).isActive = true
        case .title:
            item.heightAnchor.constraint(equalToConstant: 70).isActive = true
        case .result:
            item.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
    }
}

// MARK: - BlitzInfographicViewModelViewDelegate

extension BlitzInfographicView: BlitzInfographicViewModelViewDelegate {
    func blitzInfographicViewModelDidUpdate() {
        DispatchQueue.main.async {
            self.listView.removeAllArrangedSubviews()
            self.setupListViewSubviews()
        }
    }
}
