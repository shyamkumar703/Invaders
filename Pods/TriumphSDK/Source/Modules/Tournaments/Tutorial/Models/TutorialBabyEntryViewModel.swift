//
//  TutorialBabyEntryViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit

protocol TutorialBabyEntryViewModelViewDelegate: AnyObject {
    func updateView(viewModel: TutorialBabyEntryViewModel)
    func startLoad()
    func finishLoad()
}

protocol TutorialBabyEntryViewModel: AnyObject, BabyCellDelegate {
    var title: String? { get }
    var image: String? { get }
    var viewDelegate: TutorialBabyEntryViewModelViewDelegate? { get set }
    
    func goToNextPage()
}

class TutorialBabyEntryViewModelImplementation: TutorialBabyEntryViewModel, BabyCellDelegate {
    var title: String?
    var buttonTitle: String?
    var image: String?
    weak var viewDelegate: TutorialBabyEntryViewModelViewDelegate? {
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
        self.title = "Use \(60.formatCurrency()) of your bonus to enter your first game"
        self.image = "profile"
        self.viewDelegate?.updateView(viewModel: self)
    }
    
    func goToNextPage() {
        pageController.goToNextPage()
    }
    
    func playTapped() {
        Task { [weak self] in
            do {
                self?.viewDelegate?.startLoad()
                self?.dependencies.localStorage.add(value: true, forKey: .hasCompletedTutorial)
                try await self?.dependencies.session.updateUserTutorialStatus()
                let tournamentDefinitions = await self?.dependencies.session.presets.tournamentDefinitions
                if let model = tournamentDefinitions?.filter({
                    guard let entryPrice = $0.entryPrice else { return false }
                    return entryPrice < 1.50 && entryPrice != 0
                }).first {
                    coordinator.playDidPress(tournamentType: .versus, tournament: model, blitz: nil)
                }
            } catch {
                dependencies.logger.log(error.localizedDescription, .error)
            }
        }
    }
}
