// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct AuthenticationNewUserData: RequestQuery {
    var phoneNumber: String
    var otp: OTPStatus = .success
    var game: String
    var referrerUsername: String?
    var deviceCheckToken: String?
}

struct AuthenticationNewUserRequest: Request {
    typealias Output = EmptyResponse
    var path: String
    var query: RequestQuery?
    var shouldUseTriumphSignature: Bool = false
    var body: String?
    
    init(
        phoneNumber: String,
        appId: String,
        referrerUsername: String?,
        deviceCheckToken: String?
    ) {
        self.path = "users/"
        self.query = AuthenticationNewUserData(
            phoneNumber: phoneNumber,
            game: appId,
            referrerUsername: referrerUsername,
            deviceCheckToken: deviceCheckToken
        )
        self.body = query?.dictionary?.stringify()
    }
}
