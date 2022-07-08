// Copyright © TriumphSDK. All rights reserved.
import AVFoundation
import Foundation
import UIKit
import TriumphCommon

class TutorialAsyncVideoViewController: TutorialController {
    
    private lazy var queuePlayer = AVQueuePlayer()
    private var playerLayer: AVPlayerLayer?
    
    var viewModel: TutorialAsyncVideoViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }
    
    lazy var videoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
//    lazy var textStack: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.distribution = .fill
//        stack.axis = .vertical
//        stack.spacing = 32
//
//        stack.addArrangedSubview(titleLabel)
//        stack.addArrangedSubview(nextButton)
//        return stack
//    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 21, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1)
        button.layer.doGlowAnimation(withColor: #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1))
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds
    }
    
    func setupVideo() {
        guard let playerItemStart = AVPlayerItem(named: "fighting1"),
              let playerItemContinue = AVPlayerItem(named: "fighting2") else { return }
        self.queuePlayer = AVQueuePlayer(items: [playerItemStart, playerItemContinue])
   
        playerLayer = AVPlayerLayer(player: queuePlayer)
        guard let playerLayer = self.playerLayer else { return }

        videoView.layer.addSublayer(playerLayer)
        queuePlayer.play()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEndOfFirst(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    @objc func playerItemDidReachEndOfFirst(notification: Notification) {
        guard let playerItemContinue = AVPlayerItem(named: "fighting2") else { return }
        queuePlayer.insert(playerItemContinue, after: self.queuePlayer.items().last)
    }
    
    @objc func didEnterBackground() {
        queuePlayer.pause()
    }
    
    @objc func willEnterForeground() {
        queuePlayer.play()
    }
    
    @objc func nextPage() {
        UIImpactFeedbackGenerator().impactOccurred()
        viewModel?.goToNextPage()
    }
    
    func setupView() {
        if let navigationController = self.navigationController as? BaseNavigationController {
            navigationController.hideRightTopNavButton()
        }
        
        setupVideo()
        view.backgroundColor = .lightDark
        view.addSubview(videoView)
//        view.addSubview(textStack)
        view.addSubview(titleLabel)
        view.addSubview(nextButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            
            videoView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            videoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoView.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 300),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16)
        ])
    }
}

extension TutorialAsyncVideoViewController: TutorialAsyncVideoViewModelViewDelegate {
    func updateView(viewModel: TutorialAsyncVideoViewModel?) {
        DispatchQueue.main.async { [self] in
            guard let viewModel = viewModel,
                  let title = viewModel.title,
                  let buttonTitle = viewModel.buttonTitle else { return }
            titleLabel.text = title
            nextButton.setTitle(buttonTitle, for: .normal)
        }
    }
}
