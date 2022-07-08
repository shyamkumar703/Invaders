// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol StepViewModel: BaseViewModel {
    var continueButtonTitle: String { get }
    
    func continueButtonPressed()
    func didFinish()
}

public extension StepViewModel {
    func didFinish() {}
}
