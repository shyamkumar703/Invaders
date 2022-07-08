// Copyright © TriumphSDK. All rights reserved.

import TriumphCommon
import UIKit

protocol TournamentsMissionsCellViewDelegate: AnyObject {
    func subtitleDidUpdate()
}

protocol TournamentsMissionsCellViewModel: TournamentsCellViewModel {
    var title: String { get }
    var buttonTitle: String { get }
    var token: NSAttributedString { get }
    
    func referralButtonTapped()
    func moreGamesTapped()
}

// MARK: - Implementation
class TournamentsMissionsCellViewModelImplementation: TournamentsMissionsCellViewModel {
    weak var coordinator: TournamentsCoordinator?
    private var dependencies: AllDependencies
    var missionViewModels: [MissionViewModel] = []
    
    var title: String {
        "Missions"
    }
    
    var buttonTitle: String {
        "View"
    }
    
    var token: NSAttributedString {
        let imageAttachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        imageAttachment.image = UIImage(named: "token")?.withTintColor(.lightGreen).withConfiguration(configuration)
        return NSAttributedString(attachment: imageAttachment)
    }
    
    init(
        dependencies: AllDependencies,
        coordinator: TournamentsCoordinator?
    ) {
        self.dependencies = dependencies
        self.coordinator = coordinator
    }
    
    func referralButtonTapped() {
        UIImpactFeedbackGenerator().impactOccurred()
        coordinator?.respondTo(action: .makeReferral, model: nil)
    }
    
    func moreGamesTapped() {
        UIImpactFeedbackGenerator().impactOccurred()
        Task { [weak self] in
            try await self?.dependencies.session.getOtherGames(forceUpdate: true)
        }
        coordinator?.showMissionsSheet()
    }
}
