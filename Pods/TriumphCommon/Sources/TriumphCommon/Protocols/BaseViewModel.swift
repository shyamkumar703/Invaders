// Copyright © TriumphSDK. All rights reserved.

import Foundation

// MARK: - Delegate

public protocol BaseViewModelViewDelegate: AnyObject {
    func continueButtonIsEnabled(_ isEnabled: Bool)
    func showLoadingProcess()
    func showLoadingProcess(with message: String)
    func hideLoadingProcess()
    func hideLoadingProcess(isSuccess: Bool)
}

public extension BaseViewModelViewDelegate {
    func continueButtonIsEnabled(_ isEnabled: Bool = false) {}
    func showLoadingProcess() {}
    func showLoadingProcess(with message: String) {}
    func hideLoadingProcess() {}
    func hideLoadingProcess(isSuccess: Bool) {}
}

// MARK: - BaseViewModel

public protocol BaseViewModel: AnyObject {
    associatedtype D = Dependencies
    var dependencies: D { get }

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisapear()
    func viewDidAppear()
    func viewDidDisappear()
    func prepareViewModel()
    func getData()
    
    // Localization
    func localizedString(_ key: String, bundle: Bundle?) -> String
    func localizedString(_ key: String, bundle: Bundle?, arguments: [CVarArg]) -> String
}

public extension BaseViewModel {

    func viewDidLoad() {
        assertionFailure("WARNING: '\(#function) method should be implemented in \(String(describing: type(of: self)))")
    }

    func viewWillAppear() {
        assertionFailure("WARNING: '\(#function) method should be implemented in \(String(describing: type(of: self)))")
    }
    
    func viewWillDisapear() {
        assertionFailure("WARNING: '\(#function) method should be implemented in \(String(describing: type(of: self)))")
    }

    func viewDidAppear() {
        assertionFailure("WARNING: '\(#function) method should be implemented in \(String(describing: type(of: self)))")
    }
    
    func viewDidDisappear() {
        assertionFailure("WARNING: '\(#function) method should be implemented in \(String(describing: type(of: self)))")
    }
    
    func prepareViewModel() {
        assertionFailure("WARNING: '\(#function) method should be implemented in \(String(describing: type(of: self)))")
    }
    
    func getData() {
        assertionFailure("WARNING: '\(#function) method should be implemented in \(String(describing: type(of: self)))")
    }

    func performOnMain(_ block: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }

            block()
        }
    }
}

// MARK: - Localization

public extension BaseViewModel {
    func localizedString(_ key: String, bundle: Bundle? = nil) -> String {
        (dependencies as? HasLocalization)?.localization.localizedString(key, bundle: bundle) ?? key
    }
    
    func localizedString(_ key: String, bundle: Bundle? = nil, arguments: [CVarArg]) -> String {
        (dependencies as? HasLocalization)?.localization.localizedString(key, bundle: bundle, arguments: arguments) ?? key
    }
}
