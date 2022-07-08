// Copyright © TriumphSDK. All rights reserved.

import UIKit

public struct LockdownInfoRequest: Request {
    public typealias Output = LockdownResponse
    public var path: String
    
    public init(app: ApplicationType) {
        self.path = app.path
    }
}

public struct LockdownResponse: Response {
    public var asyncLockdown: Bool? = nil
    public var blitzLockdown: Bool? = nil
    public var lockdownScreenMessage: String? = nil
    public var minimumSupportedVersionNumber: Double? = nil
    public var shouldShowUpdateButton: Bool? = nil

    public var isLockedDown: Bool {
        Double(UIApplication.minimumSupportedVersionNumber) < minimumSupportedVersionNumber ?? 0.0
    }
}
