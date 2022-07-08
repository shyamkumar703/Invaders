//
//  TutorialViewControllerViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/23/22.
//

import Foundation
import UIKit

enum TutorialPage {
    case getStarted
    case asyncVideo
    case asyncExplanation
    case babyCell
}

class TutorialViewControllerViewModel: NSObject {
    var pages: [TutorialPage] = [.getStarted, .asyncVideo, .asyncExplanation]
    var dependencies: AllDependencies
    var coordinator: TournamentsCoordinator
    var pageController: UIPageViewController
    
    var currentIndex = 0
    
    var currentVCStartTime = Date()
    
    init(dependencies: AllDependencies, coordinator: TournamentsCoordinator, controller: UIPageViewController) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        self.pageController = controller
    }
    
    func getInitialVC() -> UIViewController {
        let initialVC = TutorialGetStartedViewController()
        let viewModel = TutorialGetStartedViewModelImplementation(
            dependencies: dependencies,
            coordinator: coordinator,
            pageController: pageController
        )
        initialVC.viewModel = viewModel
        return initialVC
    }
    
    func getAsyncVideoVC() -> UIViewController {
        let vc = TutorialAsyncVideoViewController()
        let viewModel = TutorialAsyncVideoViewModelImplementation(
            dependencies: dependencies,
            coordinator: coordinator,
            pageController: pageController
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func getAsyncExplanationVC() -> UIViewController {
        let vc = TutorialAsyncExplanationViewController()
        let viewModel = TutorialAsyncExplanationViewModelImplementation(
            dependencies: dependencies,
            coordinator: coordinator,
            pageController: pageController
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func getBabyCellVC() -> UIViewController {
        let vc = TutorialBabyEntryViewController()
        let viewModel = TutorialBabyEntryViewModelImplementation(
            dependencies: dependencies,
            coordinator: coordinator,
            pageController: pageController
        )
        vc.viewModel = viewModel
        return vc
    }
}

extension TutorialViewControllerViewModel: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 { return nil }
        let newPage = pages[currentIndex - 1]
        
        switch newPage {
        case .getStarted:
            return getInitialVC()
        case .asyncVideo:
            return getAsyncVideoVC()
        case .asyncExplanation:
            return getAsyncExplanationVC()
        case .babyCell:
            return getBabyCellVC()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex == pages.count - 1 { return nil }
        let newPage = pages[currentIndex + 1]
        
        switch newPage {
        case .getStarted:
            return getInitialVC()
        case .asyncVideo:
            return getAsyncVideoVC()
        case .asyncExplanation:
            return getAsyncExplanationVC()
        case .babyCell:
            return getBabyCellVC()
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let vc = pendingViewControllers.first else {
            currentIndex = 0
            return
        }
        if vc as? TutorialGetStartedViewController != nil {
            logPageChangeEvent(from: pages[currentIndex], to: pages[0])
            currentIndex = 0
        } else if vc as? TutorialAsyncVideoViewController != nil {
            logPageChangeEvent(from: pages[currentIndex], to: pages[1])
            currentIndex = 1
        } else if vc as? TutorialAsyncExplanationViewController != nil {
            logPageChangeEvent(from: pages[currentIndex], to: pages[2])
            currentIndex = 2
        } else {
            logPageChangeEvent(from: pages[currentIndex], to: pages[3])
            currentIndex = 3
        }
    }
}

// MARK: - Analytics
extension TutorialViewControllerViewModel {
    
    func logGoToNextPage() {
        if currentIndex >= pages.count - 1 {
            logPageChangeEvent(from: pages[currentIndex], to: nil)
        } else {
            logPageChangeEvent(from: pages[currentIndex], to: pages[currentIndex + 1])
        }
    }
    
    func logPageChangeEvent(from: TutorialPage, to: TutorialPage?) {
        dependencies.analytics.logEvent(
            LoggingEvent(
                eventFor(tutorialPage: from),
                parameters: [
                    "movingToPage": eventFor(tutorialPage: to).rawValue,
                    "timeOnPage": Date().timeIntervalSince(currentVCStartTime)
                ]
            )
        )
        
        currentVCStartTime = Date()
    }
    
    func eventFor(tutorialPage: TutorialPage?) -> Event {
        switch tutorialPage {
        case .getStarted:
            return .tutorialScreen1
        case .asyncVideo:
            return .tutorialScreen2
        case .asyncExplanation:
            return .tutorialScreen3
        case .babyCell:
            return .tutorialScreen4
        default:
            return .babyGame
        }
    }
}
