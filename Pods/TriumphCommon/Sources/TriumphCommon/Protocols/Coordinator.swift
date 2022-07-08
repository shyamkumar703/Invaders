//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit
import StoreKit

public protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var navigationController: BaseNavigationController? { get }
    var childCoordinators: [Coordinator] { get }

    func start()
    func didFinish()
}

public extension Coordinator {
    func didFinish() {
        navigationController?.popViewController(animated: true)
    }
    
    func performOnMain(_ block: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            block()
        }
    }
}

// MARK: - Open App Store

public extension Coordinator {
    func openAppStoreURL(url: String, urlScheme: String? = nil) {
        guard let urlScheme = urlScheme,
              let urlFromScheme = URL(string: "\(urlScheme)://") else {
            openAppStoreURL(url)
            return
        }

        if UIApplication.shared.canOpenURL(urlFromScheme) {
            UIApplication.shared.open(urlFromScheme)
        } else {
            openAppStoreURL(url)
        }
    }
    
    func openAppStoreURL(_ url: String) {
        let viewController = SKStoreProductViewController()
        viewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: url])
        navigationController?.present(viewController, animated: true)
    }
}
