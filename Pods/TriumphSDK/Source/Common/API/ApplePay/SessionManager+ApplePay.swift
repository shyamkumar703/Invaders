// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon
import Frames

extension Session {    
    func makeApplePayment(with amount: Int, token: String) async throws {
        let query = ApplePayMakePaymentQuery(
            token: token,
            amount: amount,
            game: dependencies.appInfo.id,
            triumphTokens: depositDefinitions.filter({ $0.depositAmount == amount }).first?.tokens ?? 0
        )
        let request = ApplePayMakePaymentRequest(query: query)
        try await dependencies.secure.call(request: request)
    }
    
    func makeApplePaymentDecoded(with amount: Int, token: ApplePayTokenData) async throws {
        let merchantIDWithDashes = TriumphSDK.merchantId.replacingOccurrences(of: ".", with: "-")
        let query = ApplePayMakePaymentQueryDecoded(
            token: token,
            merchantId: merchantIDWithDashes,
            triumphTokens: depositDefinitions.filter({ $0.depositAmount == amount }).first?.tokens ?? 0
        )
        let request = ApplePayMakePaymentRequestDecoded(query: query)
        try await dependencies.secure.call(request: request)
    }
}
