// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol TournamentsHistorySectionViewModel: TournamentsSectionViewModel {
    var title: String { get }
    var items: [TournamentsHistoryCellViewModel] { get }
    var date: Date { get }
    
    func prepareViewModel(for index: Int) -> TournamentsHistoryCellViewModel?
    func isLastElement(of index: Int) -> Bool
}

extension TournamentsHistorySectionViewModel {
    func isLastElement(of index: Int) -> Bool {
        index == items.count - 1
    }
}

final class TournamentsHistorySectionViewModelImplementation: TournamentsHistorySectionViewModel {

    private weak var coordinator: TournamentsCoordinator?
    private var dependencies: AllDependencies
    var title: String
    var models: [HistoryModel]?

    init(
        title: String,
        models: [HistoryModel]? = nil,
        coordinator: TournamentsCoordinator?,
        dependencies: AllDependencies
    ) {
        self.title = title
        self.models = models
        self.coordinator = coordinator
        self.dependencies = dependencies
    }

    var items: [TournamentsHistoryCellViewModel] {
        models?
            .sorted { $0.date > $1.date }
            .map { TournamentsHistoryCellViewModelImplementation(model: $0, dependencies: dependencies) }
        ?? []
    }
    
    var date: Date {
        models?.first?.date ?? Date()
    }
    
    func prepareViewModel(for index: Int) -> TournamentsHistoryCellViewModel? {
        items.indices.contains(index) ? items[index] : nil
    }
}
