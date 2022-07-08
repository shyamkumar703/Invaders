//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit

public struct Configuration {
    public struct General {
        public static var publishableApiKey: String = "TIUpRzwSpDkuW9AyudzQHuIQpsJZah4JWG287He7yXoDyll92t9xCSOxurq2Iuzx"
        public static let intercomApiClientKey = "ios_sdk-0a1cd896214268ecdd989d9c93f9b6373fcb635e"
        public static let intercomAppId = "vpckdrm2"
    }
    
    public struct WithdrawalLimit {
        public static let minimum: Int = 5
        public static let weekly: Int = 250
    }
    
    public struct NetworkConnection {
        public static let timeInterval: Double = 10.0
        public static let timeout: Double = 2.0
        public static let lowSpeed: Float = 10
        
    }
}

public struct StorageConfiguration {
    public static let url: String = UIApplication.storageURL
}

public struct URLConfiguration {
    public static let url: String = "https://debug-api.triumpharcade.com"
}
