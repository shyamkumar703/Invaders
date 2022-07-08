// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation
import TriumphCommon

protocol CountdownViewControllerDelegate: AnyObject {
    func countdownDidStart()
    func countdownAboutToFinish()
    func countdownDidFinish()
}

final class CountdownViewController: UIViewController {

    private var playerLayer: AVPlayerLayer?
    
    weak var delegate: CountdownViewControllerDelegate?
    private var notificationGenerator = UINotificationFeedbackGenerator()
    private var impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private var countdown = 3
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTransition()
        setupVideo()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
        playerLayer?.frame = self.view.frame
    }
}

// MARK: - Setup

private extension CountdownViewController {
    func setupTransition() {
        let transition: CATransition = CATransition()
        transition.duration = 1.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        transition.type = .fade
        navigationController?.view.layer.add(transition, forKey: nil)
        
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.hideTopNavBarView()
    }
    
    func setupVideo() {
        guard let player = AVPlayer(named: "CountingVideo") else { return }
        player.play()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        guard let playerLayer = self.playerLayer else { return }
        view.layer.addSublayer(playerLayer)
    }
}

// MARK: - Counting

private extension CountdownViewController {
    func startAnimation() {
        guard self.timer == nil else { return }
        delegate?.countdownDidStart()
        self.timer = Timer.scheduledTimer(
            timeInterval: 1.3,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
        guard let timer = self.timer else { return }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func updateCounter() {
        switch countdown {
        case 1:
            delegate?.countdownAboutToFinish()
            fallthrough
        case 3, 2:
            counterDidUpdate()
            countdown -= 1
        default:
            timer?.invalidate()
            timer = nil
            delegate?.countdownDidFinish()
            notificationGenerator.notificationOccurred(.success)
        }
    }
    
    func counterDidUpdate() {
        impactGenerator.impactOccurred()
    }
}
