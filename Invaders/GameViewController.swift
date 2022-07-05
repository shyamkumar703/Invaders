//
//  GameViewController.swift
//  Invaders
//
//  Created by Shyam Kumar on 6/25/22.
//
import AVFoundation
import UIKit
import SpriteKit
import GameplayKit

protocol GameDelegate {
    func gameFinished()
}

class GameViewController: UIViewController {
    let gameView = SKView(frame: UIScreen.main.bounds)
    lazy var queuePlayer = AVQueuePlayer()
    var playerLooper: AVPlayerLooper?
    var playerLayer: AVPlayerLayer?
    
    lazy var actionStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        stack.distribution = .fillEqually
        
        stack.addArrangedSubview(triumphButton)
        stack.addArrangedSubview(practiceButton)
        return stack
    }()
    
    lazy var triumphButton: UIButton = {
        let button = UIButton()
        let attrTitle = NSAttributedString(
            string: "TOURNAMENTS",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont(name: "Public Pixel", size: 30) ?? UIFont.systemFont(ofSize: 30)
            ]
        )
        button.setAttributedTitle(attrTitle, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(tournamentsPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var practiceButton: UIButton = {
        let button = UIButton()
        let attrTitle = NSAttributedString(
            string: "PRACTICE",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont(name: "Public Pixel", size: 24) ?? UIFont.systemFont(ofSize: 30)
            ]
        )
        button.setAttributedTitle(attrTitle, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(practicePresed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideo()
        addVideoObservers()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        queuePlayer.play()
    }
  
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        queuePlayer.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = self.view.frame
    }
    
    func setupView() {
        gameView.alpha = 0
        view.addSubview(actionStackView)
        view.addSubview(gameView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            actionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            actionStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            actionStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8)
        ])
    }
    
    func setupVideo() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
        guard let playerItemStartURL = Bundle.main.url(forResource: "invaders", withExtension: "mp4") else { return }
        let playerItem = AVPlayerItem(url: playerItemStartURL)
        queuePlayer = AVQueuePlayer(items: [playerItem])
        queuePlayer.isMuted = true
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        self.playerLayer = AVPlayerLayer(player: queuePlayer)
        self.playerLayer?.videoGravity = .resizeAspectFill
        guard let playerLayer = self.playerLayer else { return }
        
        self.view.layer.addSublayer(playerLayer)
        self.queuePlayer.play()
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Game lifecycle
extension GameViewController {
    func startGame() {
        let scene = GameScene(size: view.bounds.size, delegate: self)
        gameView.showsFPS = false
        gameView.showsNodeCount = false
        gameView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        queuePlayer.pause()
        UIView.animate(
            withDuration: 1,
            animations: {
                self.triumphButton.alpha = 0
                self.practiceButton.alpha = 0
                self.gameView.alpha = 1
                self.gameView.presentScene(scene)
            },
            completion: { _ in
                self.playerLayer?.removeFromSuperlayer()
            }
        )
    }
}

// MARK: - Handle button actions
extension GameViewController {
    @objc func tournamentsPressed() {
        UIImpactFeedbackGenerator().impactOccurred()
    }
    
    @objc func practicePresed() {
        UIImpactFeedbackGenerator().impactOccurred()
        startGame()
    }
}

// MARK: - Video observers
extension GameViewController {
    func addVideoObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // prevent misc other freezes
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // Responding methods
    @objc func didEnterBackground() {
        queuePlayer.pause()
    }
    
    @objc func willEnterForeground() {
        guard presentedViewController == nil else { return }
        queuePlayer.play()
    }
}

// MARK: - Game Delegate
extension GameViewController: GameDelegate {
    func gameFinished() {
        playerLayer?.frame = self.view.frame
        UIView.animate(
            withDuration: 1,
            animations: {
                self.triumphButton.alpha = 1
                self.practiceButton.alpha = 1
                self.gameView.alpha = 0
                guard let playerLayer = self.playerLayer else { return }
//                self.view.layer.addSublayer(playerLayer)
                self.view.layer.insertSublayer(playerLayer, at: 0)
            },
            completion: { _ in
                self.queuePlayer.play()
                
            }
        )
    }
}
   
