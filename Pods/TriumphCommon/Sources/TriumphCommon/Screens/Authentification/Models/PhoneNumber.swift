// Copyright © TriumphSDK. All rights reserved.

import Foundation

@propertyWrapper
struct PhoneNumber {
    private var number: String
    
    init() {
        self.number = "+1"
    }

    var wrappedValue: String {
        get { return number }
        set { number = "+1" + newValue }
    }
}
