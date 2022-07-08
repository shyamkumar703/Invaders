// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol BaseAlertFabric {
    func showAlert(_ alertModel: AlertModel, completion: (() -> Void)?)
    func showAlert(_ alertModel: ActionAlertModel, completion: (() -> Void)?)
    func showAlert(_ alertModel: TextFieldAlertModel, completion: ((String?) -> Void)?)
    func dismissAlert(completion: (() -> Void)?)
}

public protocol AlertFabricDelegate: BaseAlertFabric, Coordinator {}

public protocol AlertFabric: BaseAlertFabric {
    var dependencies: HasLocalization { get }
    
    var delegate: AlertFabricDelegate? { get set }
}

public extension AlertFabric {
    func showAlert(_ alertModel: AlertModel, completion: (() -> Void)? = nil) {
        delegate?.showAlert(alertModel, completion: completion)
    }
    
    func showAlert(_ alertModel: ActionAlertModel, completion: (() -> Void)? = nil) {
        delegate?.showAlert(alertModel, completion: completion)
    }
    
    func showAlert(_ alertModel: TextFieldAlertModel, completion: ((String?) -> Void)?) {
        delegate?.showAlert(alertModel, completion: completion)
    }
    
    func dismissAlert(completion: (() -> Void)? = nil) {
        delegate?.dismissAlert(completion: completion)
    }
}

// MARK: - Alert Fabric Impl.

final class AlertFabricService: AlertFabric {
    
    var dependencies: HasLocalization
    weak var delegate: AlertFabricDelegate?
    
    init(dependecies: Dependencies) {
        self.dependencies = dependecies
    }
}
