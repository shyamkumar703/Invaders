// Copyright © TriumphSDK. All rights reserved.

import UIKit

fileprivate let iconSize: CGFloat = 50

final class TournamentsGameHeader: UICollectionReusableView {

    private let gameTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .darkGray
        return label
    }()
    
    private let gameIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGameIcon()
        // setupGameTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension TournamentsGameHeader {
    func setupGameIcon() {
        if let imageName = TriumphSDK.gameAppIcon {
            gameIconImageView.image = UIImage(imageLiteralResourceName: imageName)
        } else if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
             let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
             let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
             let icon = iconFiles.last {
            
            gameIconImageView.image = UIImage(imageLiteralResourceName: icon)
            
        } else {
            gameIconImageView.image = UIImage(named: "logo")
        }
        
        addSubview(gameIconImageView)
        setupGameIconConstrains()
    }
    
    func setupGameTitleLabel() {
        gameTitleLabel.text = TriumphSDK.gameTitle
        addSubview(gameTitleLabel)
        setupGameTitleLabelConstrains()
    }
}

// MARK: - Constrains

private extension TournamentsGameHeader {
    func setupGameIconConstrains() {
        gameIconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameIconImageView.widthAnchor.constraint(equalToConstant: 203),
            gameIconImageView.heightAnchor.constraint(equalToConstant: 35),
            gameIconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            gameIconImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func setupGameTitleLabelConstrains() {
        gameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 21),
            gameTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
