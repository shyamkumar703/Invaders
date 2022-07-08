//
//  MissionsViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/17/22.
//

import Foundation
import TriumphCommon

protocol MissionsViewControllerViewDelegate: AnyObject {
    func reloadTableView(sections: IndexSet)
}

protocol MissionsViewModel: AnyObject {
    var dependencies: AllDependencies { get }
    var coordinator: TournamentsCoordinator { get }
    var missions: [MissionModel] { get }
    var otherGames: [OtherGamesCollectionViewModel] { get }
    var viewDelegate: MissionsViewControllerViewDelegate? { get set }
    
    func retrieveMissionsAndGames() async
    func respondToTap(model: OtherGamesCollectionViewModel)
    func respondToTap(action: MissionAction, model: MissionModel?)
}

class MissionsViewModelImplementation: MissionsViewModel {
    var dependencies: AllDependencies
    var coordinator: TournamentsCoordinator
    weak var viewDelegate: MissionsViewControllerViewDelegate?
    
    var missions: [MissionModel] {
        didSet {
            viewDelegate?.reloadTableView(sections: IndexSet(1..<2))
        }
    }
    
    var otherGames: [OtherGamesCollectionViewModel] {
        didSet {
            viewDelegate?.reloadTableView(sections: IndexSet(0..<1))
        }
    }
    
    init(dependencies: AllDependencies, coordinator: TournamentsCoordinator) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        self.missions = []
        self.otherGames = []
        Task { [weak self] in
            await self?.retrieveMissionsAndGames()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(retrieveOtherGames),
            name: .didRetrieveOtherGames,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didRetrieveOtherGames, object: nil)
    }
    
    /// Retrieves the user's available missions 
    func retrieveMissionsAndGames() async {
        let missions = await dependencies.session.missions
        self.missions = missions.filter({
            $0.isCompleted == false &&
            $0.completedFor[dependencies.appInfo.id] == nil &&
            $0.unlockedFor[dependencies.appInfo.id] != nil
        }).sorted(by: { $0.displayOrder < $1.displayOrder })
        self.otherGames = await dependencies.session.otherGames
            .filter { $0.appStoreURL != nil && $0.image != nil }
            .map({ OtherGamesCollectionViewModel(
                otherGame: $0,
                dependencies: dependencies
            )
        })
    }
    
    func respondToTap(model: OtherGamesCollectionViewModel) {
        if model.otherGame.gameId != dependencies.appInfo.id {
            if let urlScheme = model.otherGame.urlScheme, let url = URL(string: "\(urlScheme)://") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    return
                }
            }
            
            guard let appStoreURL = model.otherGame.appStoreURL else { return }
            coordinator.openAppStoreURL(rawURL: appStoreURL)
        }
    }
    
    func respondToTap(action: MissionAction, model: MissionModel?) {
        coordinator.respondTo(action: action, model: model)
    }
    
    @objc func retrieveOtherGames() {
        Task { @MainActor [weak self] in
            if let dependencies = self?.dependencies,
               self?.otherGames.isEmpty == true {
                self?.otherGames = await dependencies.session.otherGames
                    .filter({ $0.image != nil && $0.appStoreURL != nil })
                    .map({ OtherGamesCollectionViewModel(
                        otherGame: $0,
                        dependencies: dependencies
                    )
                })
                .sorted(by: { $0.otherGame.isCompleted && !$1.otherGame.isCompleted })
            }
        }
    }
}
