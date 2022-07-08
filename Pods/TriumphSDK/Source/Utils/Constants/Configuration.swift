//  Copyright © 2021 Triumph Lab Inc. All rights reserved.
// swiftlint:disable identifier_name
import UIKit

struct Constants {
    static let INTERNAL_VERSION_NUM = UIApplication.minimumSupportedVersionNumber
    static let HOT_STREAK_COUNT = 5
    static let AVATAR_PHOTO_COMPRESSION_FACTOR: CGFloat = 0.125
}

struct APIKey {
    static let checkoutApiClientKey = "Bearer pk_uhsnthnal65ibz3cxdgoc6p3xae"
}

struct LocationConfiguration {
    static let locationRetriesAllowed = 3
    static let timeBetweenRetries = DispatchTimeInterval.seconds(1)
}

struct StorageConfiguration {
    static let url: String = UIApplication.storageURL
}

struct URLConfiguration {
    static let url: String = "https://debug-api.triumpharcade.com"
}
