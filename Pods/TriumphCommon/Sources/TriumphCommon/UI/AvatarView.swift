// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation
import SDWebImage

open class AvatarView: UIView {
    
    private var action: (() -> Void)?

    private lazy var userpicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tungsten
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(onTapImageView)
        )
        imageView.addGestureRecognizer(tapRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    public lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 1
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        return label
    }()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var subTitle: String? {
        didSet {
            subTitleLabel.text = subTitle
        }
    }
    
    public var userpicUrl: URL? {
        didSet {
            userpicImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
            userpicImageView.sd_setImage(
                with: userpicUrl,
                placeholderImage: UIImage(named: "default-avatar"),
                options: [.delayPlaceholder]
            )
            DispatchQueue.main.async { [weak self] in
                guard self?.player != nil else { return }
                UIView.animate(withDuration: 0.2, animations: {
                    self?.playerLayer?.opacity = 0
                    self?.playerLayer?.removeFromSuperlayer()
                })
            }
        }
    }
    
    public var userpicImage: UIImage? {
        didSet {
            if let image = userpicImage {
                setupWithImage(image)
            }
        }
    }

    public var userpicSize: CGFloat

    public init(size: CGFloat = 90, withPlayer player: AVPlayer? = nil) {
        
        self.userpicSize = size
        self.player = player
        super.init(frame: .zero)
        
        setupCommon()
        setupUserpicImageView()
        setupUserNameLabel()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTapImageView() {
        action?()
    }
        
    public func onPress(action: @escaping () -> Void) {
        self.action = action
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = userpicImageView.bounds
    }
}

// MARK: - Setup

private extension AvatarView {
    func setupWithImage(_ image: UIImage) {
         playerLayer?.removeFromSuperlayer()
         userpicImageView.image = image
    }

    func setupCommon() {

    }
    
    func setupUserpicImageView() {
        userpicImageView.layer.cornerRadius = CGFloat(userpicSize / 2)
        addSubview(userpicImageView)
        setupUserpicImageViewConstrains()

        if self.player != nil {
            setupVideo()
        }
    }
    
    func setupVideo() {
        guard let player = self.player else { return }
        playerLayer = AVPlayerLayer(player: player)
        self.playerLayer?.videoGravity = .resizeAspectFill
        player.isMuted = true
        player.play()
        
        guard let playerLayer = self.playerLayer else { return }
        playerLayer.masksToBounds = true
        userpicImageView.layer.addSublayer(playerLayer)
    }

    func setupUserNameLabel() {
        addSubview(titleLabel)
        setupUserNameLabelConstrains()
    }
    
    func setupSubTitleLabel() {
        addSubview(subTitleLabel)
        setupSubTitleLabelConstrains()
    }
}

// MARK: - Constrains

private extension AvatarView {
    func setupUserpicImageViewConstrains() {
        userpicImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userpicImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            userpicImageView.topAnchor.constraint(equalTo: topAnchor),
            userpicImageView.widthAnchor.constraint(equalToConstant: userpicSize),
            userpicImageView.heightAnchor.constraint(equalToConstant: userpicSize)
        ])
    }
    
    func setupUserNameLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: userpicImageView.bottomAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupSubTitleLabelConstrains() {
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
}
