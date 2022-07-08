// Copyright © TriumphSDK. All rights reserved.

extension SharedSessionManager {
    func executeCashout(_ cardDetails: CardDetailsModel) async throws {
        let request = CashoutRequest(
            query: CashoutRequestQuery(
                cardNum: cardDetails.number,
                cardExp: cardDetails.formatedExpiration
            )
        )
        
        try await dependencies.network.call(request: request)
    }
}

