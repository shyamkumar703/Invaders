//
//  UIPageViewController.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit

extension UIPageViewController {

    func goToNextPage() {
        if let curr = self as? TutorialPageViewController {
            guard let currentViewController = curr.viewControllers?.first else { return }
            guard let nextViewController = curr.dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
            curr.viewModel?.logGoToNextPage()
            curr.viewModel?.currentIndex += 1
            curr.view.isUserInteractionEnabled = false
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}
