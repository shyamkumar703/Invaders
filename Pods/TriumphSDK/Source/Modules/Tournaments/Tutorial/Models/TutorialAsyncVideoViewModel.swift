//
//  TutorialAsyncVideoViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit

protocol TutorialAsyncVideoViewModelViewDelegate: AnyObject {
    func updateView(viewModel: TutorialAsyncVideoViewModel?)
}

protocol TutorialAsyncVideoViewModel: AnyObject {
    var title: String? { get }
    var buttonTitle: String? { get }
    var viewDelegate: TutorialAsyncVideoViewModelViewDelegate? { get set }
    
    func goToNextPage()
}

class TutorialAsyncVideoViewModelImplementation: TutorialAsyncVideoViewModel {
    var title: String?
    var buttonTitle: String?
    weak var viewDelegate: TutorialAsyncVideoViewModelViewDelegate? {
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
        title = "Always play real opponents"
        buttonTitle = "I'm Ready!"
        viewDelegate?.updateView(viewModel: self)
    }
    
    func goToNextPage() {
        pageController.goToNextPage()
    }
}
