// Copyright © TriumphSDK. All rights reserved.

import Foundation

protocol TournamentsBlitzCellViewModelDelegate: AnyObject {
    func tournamentsBlitzCellDidEnter()
}

protocol TournamentsBlitzCellViewModel: TournamentsCellViewModel {
    var delegate: TournamentsBlitzCellViewModelDelegate? { get set }
    var title: String { get }
    var subtitle: String { get }
    var enterButtonTitle: String { get }
    
    func enterButtonPressed()
}

// MARK: - Impl.

final class TournamentsBlitzCellViewModelImplementation: TournamentsBlitzCellViewModel {

    weak var delegate: TournamentsBlitzCellViewModelDelegate?
    private var dependencies: AllDependencies
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
    }
    
    var title: String {
        "Blitz Mode"
    }
    
    var subtitle: String {
        "Rapid fire games with real time prizes"
    }
    
    var enterButtonTitle: String {
        "View"
    }
    
    func enterButtonPressed() {
        delegate?.tournamentsBlitzCellDidEnter()
    }
}

// MARK: - Localization

extension TournamentsBlitzCellViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
