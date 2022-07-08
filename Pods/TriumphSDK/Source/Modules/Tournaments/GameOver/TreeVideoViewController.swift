// Copyright © TriumphSDK. All rights reserved.
import AVFoundation
import UIKit
import Foundation

class TreeVideoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showTreeVideo()
    }
    
    func setupView() {
        view.backgroundColor = .black
    }
    
    func setupConstraints() {}
}

extension TreeVideoViewController {
    func showTreeVideo() {
        guard let playerItem = AVPlayerItem(named: "tree") else { return }
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        player.play()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnded),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    @objc func videoDidEnded() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
}
