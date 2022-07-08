//
//  TutorialGetStartedViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit

protocol TutorialGetStartedViewModelViewDelegate: AnyObject {
    func updateView(viewModel: TutorialGetStartedViewModel?)
}

protocol TutorialGetStartedViewModel: AnyObject {
    var title: String? { get }
    var buttonTitle: String? { get }
    var image: String? { get }
    var viewDelegate: TutorialGetStartedViewModelViewDelegate? { get set }
    
    func goToNextPage()
    func runConfetti()
}

class TutorialGetStartedViewModelImplementation: TutorialGetStartedViewModel {
    var title: String?
    var buttonTitle: String?
    var image: String?
    weak var viewDelegate: TutorialGetStartedViewModelViewDelegate? {
        didSet {
            setup()
        }
    }
    
    var dependencies: AllDependencies
    var coordinator: TournamentsCoordinator
    var pageController: UIPageViewController
    
    init(dependencies: AllDependencies, coordinator: TournamentsCoordinator, pageController: UIPageViewController) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        self.pageController = pageController
    }
    
    func setup() {
        Task { [weak self] in
            if let name = await self?.dependencies.sharedSession.userPublicInfo?.name?.split(separator: " ").first {
                self?.title = "Hey \(name), here's $1.50 just for signing up"
            } else {
                self?.title = "Hey, here's $1.50 just for signing up"
            }
            self?.buttonTitle = "Woohoo!"
            self?.image = "getStarted"
            self?.viewDelegate?.updateView(viewModel: self)
        }
    }
    
    func goToNextPage() {
        pageController.goToNextPage()
    }
    
    func runConfetti() {
        coordinator.runConfettiWithAction {}
    }
}
