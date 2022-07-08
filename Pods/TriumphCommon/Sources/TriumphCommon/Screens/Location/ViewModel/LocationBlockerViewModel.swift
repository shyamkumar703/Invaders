// Copyright © TriumphSDK. All rights reserved.

import Foundation
import UIKit

public protocol LocationBlockerViewModelDelegate: BaseLocationViewModelViewDelegate {}

public class LocationBlockerViewModel: BaseLocationViewModel {

    public weak var viewDelegate: LocationBlockerViewModelDelegate?

    public var dependencies: Dependencies
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public var title: NSMutableAttributedString {
        if !dependencies.location.isValidToContinue {
            let attributedString = NSMutableAttributedString(string: "Triumph needs\nyour location")
            attributedString.setColorFor(
                text: localizedString("location_lbl_title_part_orange"),
                color: TriumphCommon.colors.TRIUMPH_PRIMARY_COLOR,
                font: UIFont.boldSystemFont(ofSize: 23)
            )
            return attributedString
        } else if !dependencies.cheatingPreventionService.passedCheatingDetection() {
            let attributedString = NSMutableAttributedString(string: "Please disable your VPN")
            attributedString.setColorFor(
                text: localizedString("location_lbl_title_part_orange"),
                color: TriumphCommon.colors.TRIUMPH_PRIMARY_COLOR,
                font: UIFont.boldSystemFont(ofSize: 23)
            )
            return attributedString
        } else {
            let attributedString = NSMutableAttributedString(string: "Triumph doesn't\noperate in your location")
            attributedString.setColorFor(
                text: localizedString("location_lbl_title_part_orange"),
                color: TriumphCommon.colors.TRIUMPH_PRIMARY_COLOR,
                font: UIFont.boldSystemFont(ofSize: 23)
            )
            return attributedString
        }
    }
    
    public var continueButtonTitle: String {
        "Settings"
    }
    
    public var shouldShowActionButton: Bool {
        !dependencies.location.isValidToContinue || dependencies.cheatingPreventionService.passedCheatingDetection()
    }
    
    public var descriptionText: String {
        if !dependencies.location.isValidToContinue {
            return "Allow Triumph to access your location"
        }
        if dependencies.cheatingPreventionService.isUsingVPN() {
            return ""
        }
        if let state = dependencies.location.getStateName() {
            return "We hope to come to \(state) soon!"
        }
        return "We hope to expand soon!"
    }

    public func continueButtonPressed() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
