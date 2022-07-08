// Copyright © TriumphSDK. All rights reserved.

import UIKit

public protocol BaseController: AnyObject {
    var view: UIView! { get set }
    var progressView: ProgressHUD { get set }
    var navigationController: UINavigationController? { get }
    var navigationItem: UINavigationItem { get }
    var isKeyboardingForceKeep: Bool { get set }
    
    func baseDidLoad()
    func baseWillAppear()
    func baseDidLayoutSubviews()
    
    func startActivityIndicator(with message: String?)
    func stopActivityIndicator(with success: Bool)
}

// MARK: - Lifecycle

extension BaseController {
    public func baseDidLoad() {
        
    }

    public func baseWillAppear() {
        
    }
    
    public func baseDidLayoutSubviews() {
        progressView.center = view.center
    }
}

// MARK: - Setup Progress View

public extension BaseController {
    func startActivityIndicator(with message: String? = nil) {
        Task { @MainActor [weak self] in
            self?.view.addSubview(progressView)
            self?.progressView.start(message)
            if self?.isKeyboardingForceKeep == false {
                self?.view.isUserInteractionEnabled = false
            }
        }
    }
    
    func stopActivityIndicator(with success: Bool = false) {
        Task { @MainActor [weak self] in
            if success {
                self?.progressView.stopWithSuccess { [weak self] in
                    self?.progressView.removeFromSuperview()
                }
            } else {
                self?.progressView.stop()
                self?.progressView.removeFromSuperview()
            }
            if self?.isKeyboardingForceKeep == false {
                self?.view.isUserInteractionEnabled = true
            }
        }
    }
}
