// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension AlertFabric {
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    func showLocationAlert() {
        let alert = AlertModel(
            title: dependencies.localization.localizedString("alert_location_permission_title"),
            message: dependencies.localization.localizedString("alert_location_permission_msg"),
            okButtonTitle: dependencies.localization.commonLocalizedString("btn_close_title"),
            okHandler: { _ in
                delegate?.didFinish()
            },
            cancelButtonTitle: dependencies.localization.commonLocalizedString("btn_settings_title"),
            cancelHandler: { _ in
                openSettings()
            }
        )
        showAlert(alert)
    }

    func showNotEligableAlert(for state: String?) {
        let alertMessage = dependencies.localization.localizedString(
            Content.Matching.notEligibleMessage,
            arguments: [state ?? "your state"]
        )

        let alert = AlertModel(
            title: dependencies.localization.localizedString("not_eligible_title"),
            message: alertMessage,
            okButtonTitle: dependencies.localization.commonLocalizedString("btn_close_title")
        )
        showAlert(alert)
    }
}
