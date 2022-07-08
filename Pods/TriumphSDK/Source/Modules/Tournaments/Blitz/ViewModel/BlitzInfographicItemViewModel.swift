// Copyright © TriumphSDK. All rights reserved.

import Foundation

protocol BlitzInfographicItemViewModel {
    var score: String { get }
    var prize: String { get }
    var type: BlitzInfographicItemType { get }
}

// MARK: - Impl.

final class BlitzInfographicItemViewModelImplementation: BlitzInfographicItemViewModel {
    
    private var dependencies: AllDependencies
    private var model: BlitzInfographicItemModel
    
    init(model: BlitzInfographicItemModel, dependencies: AllDependencies) {
        self.model = model
        self.dependencies = dependencies
    }
    
    var score: String {
        model.score
    }
    
    var prize: String {
        model.prize
    }
    
    var type: BlitzInfographicItemType {
        model.type
    }
}
