// Copyright © TriumphSDK. All rights reserved.

import Foundation
import UIKit

public protocol BaseLocationViewModelViewDelegate: BaseViewModelViewDelegate {}

public protocol BaseLocationViewModel: StepViewModel {
    
    associatedtype ViewDelegate = BaseLocationViewModelViewDelegate
    
    var viewDelegate: ViewDelegate? { get set }
    var title: NSMutableAttributedString { get }
    var continueButtonTitle: String { get }
    var descriptionText: String { get }
    var shouldShowActionButton: Bool { get }
    
    func didFinish()
}
