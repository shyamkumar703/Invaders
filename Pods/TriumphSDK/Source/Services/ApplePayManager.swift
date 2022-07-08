// Copyright © TriumphSDK. All rights reserved.

import Foundation
import PassKit
import Frames
import TriumphCommon

protocol ApplePay {
    /// Creates the PKPaymentRequest for the coordinator to use to present the apple payment
    /// - Parameter amount: amount that apple pay should present in their model and charge
    /// - Parameter completion: Completion with teh actual payment request
    func preparePaymentRequest(amount: Double, completion: @escaping (PKPaymentRequest?) -> Void)
    
    /// Creates and uses the apple pay token
    /// if the payment is authorized by apple pay then proceede with creating and using the token
    /// - Parameter paymentData: from the apple payment
    /// - Parameter amount: amount assosiated with the payment data
    /// - Parameter completion: buisness logic handling payment PKPaymentAuthorizationResult is a tuple with the state of trhe transaction
    func createApplePayTokenWithPayentData(
        paymentData data: Data,
        amount: Double,
        completion: @escaping (PKPaymentAuthorizationResult) -> Void
    )
}

enum ApplePayError: Error {
    case checkoutError
    case applePayControllerError
    case requestError
}

// MARK: - ApplePayManager

final class ApplePayManager: NSObject, ApplePay {

    typealias Dependencies = HasLogger & HasAppInfo & HasSession & HasAnalytics
    private var dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    private lazy var checkoutAPIClient: CheckoutAPIClient = {
        CheckoutAPIClient(
            publicKey: APIKey.checkoutApiClientKey,
            environment: .live
        )
    }()

    private var paymentRequest: PKPaymentRequest = {
        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = TriumphSDK.merchantId
        request.merchantCapabilities = .capability3DS
        
        return request
    }()
    
    private let paymentNetworks: [PKPaymentNetwork] = {
        [
            //.amex, we don't accept amex.
            .discover,
            .masterCard,
            .visa
        ]
    }()

    func preparePaymentRequest(amount: Double, completion: @escaping (PKPaymentRequest?) -> Void) {
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let paymentItem = PKPaymentSummaryItem(
                label: "Triumph Tournaments",
                amount: NSDecimalNumber(value: amount)
            )
            paymentRequest.supportedNetworks = paymentNetworks
            paymentRequest.paymentSummaryItems = [paymentItem]
            completion(paymentRequest)
        } else {
            self.dependencies.logger.log("", .error)
            completion(nil)
        }
    }
    
    /// Sends the token to the BE the BE will communicate with the Checkout API to exersize the token
    private func makeApplePayment(token: String, amount: Double) async throws {
        let intAmount = Int(amount * 100)
        try await dependencies.session.makeApplePayment(with: intAmount, token: token)
    }
    
    private func makeApplePaymentDecoded(token: ApplePayTokenData, amount: Double) async throws {
        let intAmount = Int(amount * 100)
        try await dependencies.session.makeApplePaymentDecoded(with: intAmount, token: token)
    }
    
    func createApplePayTokenWithPayentData(
        paymentData data: Data,
        amount: Double,
        completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        if let applePayTokenData = try? JSONDecoder().decode(ApplePayTokenData.self, from: data) {
            Task(priority: .userInitiated) { [weak self] in
                do {
                    try await self?.makeApplePaymentDecoded(token: applePayTokenData, amount: amount)
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self?.dependencies.analytics.logEvent(
                        LoggingEvent(
                            .deposit,
                            parameters: [
                                "amount": "\(amount)"
                            ]
                        )
                    )
                } catch {
                    self?.dependencies.logger.log("makeApplePayment error", .error)
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                }
            }
        }
    }
}
