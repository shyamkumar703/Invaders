// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol TournamentsVersusSectionViewModelDelegate: AnyObject {
    func tournamentVersusDepositAmountWithAuth(amount: Double)
}

protocol TournamentsVersusSectionViewModelViewDelegate: BaseViewModelViewDelegate {}

protocol TournamentsVersusSectionViewModel: TournamentsSectionViewModel {
    var delegate: TournamentsVersusSectionViewModelDelegate? { get set }
    var items: [TournamentsVersusViewModel] { get }
    
    func prepareViewModel(for index: Int) -> TournamentsVersusViewModel?
}

final class TournamentsVersusSectionViewModelImplementation: TournamentsVersusSectionViewModel {
    
    weak var delegate: TournamentsVersusSectionViewModelDelegate?
    weak var viewDelegate: TournamentsVersusSectionViewModelViewDelegate?
    private var dependencies: AllDependencies
    private weak var coordinator: TournamentsCoordinator?

    init(dependencies: AllDependencies, coordinator: TournamentsCoordinator?) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tournamentsUpdated),
            name: .tournamentDefinitionsUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tournamentDefinitionsUpdated, object: nil)
    }

    private var tournaments: [TournamentModel] = Dummy.Tournaments.tournaments
    
    var items: [TournamentsVersusViewModel] {
        tournaments.map {
            let item = TournamentsVersusViewModelImplementation(
                tournamentModel: $0,
                dependencies: dependencies,
                viewDelegate: viewDelegate
            )
            item.delegate = self
            return item
        }
    }
    
    func prepareViewModel(for index: Int) -> TournamentsVersusViewModel? {
        return items.indices.contains(index) ? items[index] : nil
    }
    
    @objc func tournamentsUpdated() {
        Task { [weak self] in
            self?.tournaments = await self?.dependencies.session.presets.tournamentDefinitions ?? []
        }
    }
}

// MARK: - TournamentsItemViewModelDelegate

extension TournamentsVersusSectionViewModelImplementation: TournamentsVersusViewModelDelegate {
    func tournamentsItemPlayDidPress(_ tournament: TournamentModel) {
        coordinator?.playDidPress(tournamentType: .versus, tournament: tournament, blitz: nil)
    }

    func depositAmountWithAuthentication(amount: Double) {
        delegate?.tournamentVersusDepositAmountWithAuth(amount: amount)
    }
}
