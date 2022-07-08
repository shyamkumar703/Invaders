// Copyright © TriumphSDK. All rights reserved.

import UIKit

open class ProgressHUD: UIVisualEffectView {
    
    private var title: String?
    private let width: CGFloat = 120.0
    private let height: CGFloat = 120.0
    private lazy var activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    private lazy var label: UILabel = UILabel()
    private let blurEffect = UIBlurEffect(style: .dark)
    private var vibrancyView: UIVisualEffectView?
    private lazy var imageView = UIImageView(image: UIImage(icon: .checkmarkLarge))
    
    public init() {
        super.init(effect: blurEffect)
        stop()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
        setupContainerShape()
    }
    
    private func setupOnSuperView() {
        if let superview = self.superview {
            frame = CGRect(x: 0, y: 0, width: width, height: height)
            center = superview.center
            vibrancyView?.frame = bounds
        }
    }
    
    private func setupContainerShape() {
        layer.masksToBounds = true
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    private func setupActivityIndicator() {
        activityIndictor.color = .white
        activityIndictor.hidesWhenStopped = true
        contentView.addSubview(activityIndictor)
        if title != nil {
            let activityIndicatorSize = activityIndictor.frame.size.width
            activityIndictor.frame = CGRect(
                x: (width - activityIndicatorSize) / 2,
                y: 26,
                width: activityIndicatorSize,
                height: activityIndicatorSize
            )
        } else {
            activityIndictor.center = contentView.center
        }
    }

    private func setupLabel() {
        label.text = title
        label.textAlignment = NSTextAlignment.center
        label.frame = CGRect( x: 10, y: 28, width: width - 20, height: height)
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        contentView.addSubview(label)
    }
    
    private func setupImage() {
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .lightGray
        imageView.frame.size.width = 48
        imageView.frame.size.height = 48
        contentView.addSubview(imageView)
        if title != nil {
            imageView.frame.origin.x = (width - 48) / 2
            imageView.frame.origin.y = 18
        } else {
            imageView.center = contentView.center
        }
    }
    
    private func reloadLabel(with title: String? = nil) {
        if title == nil {
            self.title = nil
            if label.isDescendant(of: self.contentView) {
                label.removeFromSuperview()
            }
        } else {
            self.title = title
            if !label.isDescendant(of: self.contentView) {
                label.removeFromSuperview()
            }
            setupLabel()
        }
    }

    public func start(_ title: String? = nil) {
        self.title = title
        setupActivityIndicator()
        setupLabel()
        isHidden = false
        activityIndictor.startAnimating()
        
    }

    public func stop() {
        activityIndictor.stopAnimating()
        isHidden = true
    }
    
    public func stopWithSuccess(_ title: String? = nil, completion: @escaping () -> Void) {
        reloadLabel(with: title)
        activityIndictor.stopAnimating()
        imageView.isHidden = false
        setupImage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.stop()
            self.imageView.removeFromSuperview()
            self.activityIndictor.isHidden = false
            self.activityIndictor.startAnimating()
            completion()
        }
    }
}
