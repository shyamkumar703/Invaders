// Copyright © TriumphSDK. All rights reserved.

import UIKit
import PhoneNumberKit

class OTPPhoneNumberTextField: PhoneNumberTextField {
    override var defaultRegion: String {
        get {
            return "US"
        }
        set {}
    }
}
