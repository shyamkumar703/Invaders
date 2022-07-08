// Copyright © TriumphSDK. All rights reserved.

import UIKit

open class BasePrimaryButton: BaseButton {
    private var originalTitle: String?
    
    public private(set) var isLoading: Bool = false
    
    public lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        
        setupColors()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        setupPadding()
    }
}

// MARK: - Setup

private extension BasePrimaryButton {
    func setupColors() {
        // TODO: Color Shoud be configurable
        color = color ?? .orandish
        // TODO: Color Shoud be configurable
        colorOnPress = (isEnabledState ? colorOnPress ?? .darkOrandish : colorDisabled ?? .gray).withAlphaComponent(0.8)
        colorDisabled = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        colorTitle = .white
        colorTitleDisabled = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    func setupPadding() {
        contentEdgeInsets.left = 20
        contentEdgeInsets.right = 20
    }
}

public extension BasePrimaryButton {
    func showLoading() {
        originalTitle = self.titleLabel?.text
        setTitle("", for: .normal)
        setupActivityIndicator()
        isUserInteractionEnabled = false
        isLoading = true
    }
    
    func hideLoading() {
        setTitle(originalTitle, for: .normal)
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        isUserInteractionEnabled = true
        isLoading = false
    }
}

// MARK: - Activity Indicator

private extension BasePrimaryButton {
    func setupActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        setupActivityIndicatorConstraints()
    }
    
    func setupActivityIndicatorConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
