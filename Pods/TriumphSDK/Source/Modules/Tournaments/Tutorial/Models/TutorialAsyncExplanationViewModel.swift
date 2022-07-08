//
//  TutorialAsyncExplanationViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit

protocol TutorialAsyncExplanationViewModelViewDelegate: AnyObject {
    func updateView(viewModel: TutorialAsyncExplanationViewModel)
}

protocol TutorialAsyncExplanationViewModel: AnyObject {
    var title: String? { get }
    var buttonTitle: String? { get }
    var image: String? { get }
    var viewDelegate: TutorialAsyncExplanationViewModelViewDelegate? { get set }
    
    func goToNextPage()
}

class TutorialAsyncExplanationViewModelImplementation: TutorialAsyncExplanationViewModel {
    var title: String?
    var buttonTitle: String?
    var image: String?
    weak var viewDelegate: TutorialAsyncExplanationViewModelViewDelegate? {
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
        title = "Identical randomness\n100% skill"
        image = "async"
        buttonTitle = "Bet 🙄"
        viewDelegate?.updateView(viewModel: self)
    }
    
    func goToNextPage() {
        Task {
            do {
                await coordinator.navigationController?.popViewController(animated: true)
                dependencies.localStorage.add(value: true, forKey: .hasCompletedTutorial)
                try await dependencies.session.updateUserTutorialStatus()
            } catch {
                dependencies.logger.log(error.localizedDescription, .error)
            }
        }
    }
}
