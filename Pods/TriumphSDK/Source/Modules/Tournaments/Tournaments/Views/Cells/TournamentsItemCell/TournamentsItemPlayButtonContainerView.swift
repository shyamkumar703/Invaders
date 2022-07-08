// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsItemPlayButtonContainerView: UIView {
    
    private var action: (() -> Void)?
    // var disabled = false
    
    lazy var playButton: TournamentsItemPlayButton = {
        let button = TournamentsItemPlayButton(type: .system)
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupPlayButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onPress(action: @escaping () -> Void) {
        self.action = action
    }
}

// MARK: - Setup

private extension TournamentsItemPlayButtonContainerView {
    @objc func playButtonTapped(_ sender: UIButton) {
        // if !disabled { action?() }
        action?()
    }
    
    func setupPlayButton() {
        addSubview(playButton)
        setupPlayButtonConstrains()
    }
}

// MARK: - Constrains

private extension TournamentsItemPlayButtonContainerView {
    func setupPlayButtonConstrains() {
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 57),
            playButton.heightAnchor.constraint(equalToConstant: 57)
        ])
    }
}
