// Copyright © TriumphSDK. All rights reserved.

import UIKit

protocol CashoutViewModelViewDelegate: AnyObject {
    func cashoutCashBalanceDidUpdate()
}

protocol CashoutViewModel {
    var viewDelegate: CashoutViewModelViewDelegate? { get set }
    var items: [(icon: String, title: String)] { get }
    var continueButtonTitle: String { get }
    
    var balanceTextPlaceholder: String { get async }
    var balanceText: String { get async }
    var balanceDisclaimerWithdrawalTokens: String { get }
    var balanceDisclaimerWithdrawalLimits: String { get async }
    var balanceDisclaimerWithdrawalCash: String { get async }
        
    func viewWillAppear()
    func viewDidDisappear()
    func continueButtonPressed()
}

// MARK: - Impl.

final class CashoutViewModelImplementation: CashoutViewModel {
    
    private weak var coordinator: TournamentsCoordinator?
    weak var viewDelegate: CashoutViewModelViewDelegate?
    private var dependencies: AllDependencies
    private let notificationCenter = NotificationCenter.default
    
    init(coordinator: TournamentsCoordinator, dependencies: AllDependencies) {
        self.coordinator = coordinator
        self.dependencies = dependencies
    }
    
    deinit {
        print("DEINIT \(self)")
    }

    var items: [(icon: String, title: String)] {
        return Content.Cashout.items.map { ($0.0, localizedString($0.1)) }
    }
    
    var continueButtonTitle: String {
        localizedString(Content.Cashout.continueButtonTitle)
    }
    
    var balanceTextPlaceholder: String {
        get async {
            await balance.formatCurrency()
        }
    }
    
    private var balance: Int {
        get async {
            await dependencies.sharedSession.user?.balance ?? 0
        }
    }
    
    var balanceText: String {
        get async {
            await balance.formatCurrency()
        }
    }
    
    var balanceDisclaimerWithdrawalTokens: String {
        return "Cash must enter a tournament before withdrawal. Any withdrawal forfeits your tokens "
    }
    
    var balanceDisclaimerWithdrawalLimits: String {
        get async {
            let withdrawalLimit = await self.dependencies.sharedSession.hostConfig?.weeklyWithdrawableLimitGlobal ?? 0
            return " . \(withdrawalLimit.formatCurrency()) weekly limit."
        }
    }
    
    var balanceDisclaimerWithdrawalCash: String {
        get async {
            let withdrawableBalance = await dependencies.sharedSession.user?.withdrawableBalance ?? 0
            let withdrawableLimit = await dependencies.sharedSession.user?.withdrawalLimit ?? 0
            let withdrawableValue = min(withdrawableBalance, withdrawableLimit)
            
            return "\nYour withdrawable cash: \(withdrawableValue.formatCurrency())"
        }
    }

    func viewWillAppear() {
        notificationCenter.addObserver(
            self,
            selector: #selector(cashBalanceDidUpdate),
            name: .balanceUpdated,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(hostConfigDidUpdate),
            name: .hostConfigUpdated,
            object: nil
        )
    }
    
    func viewDidDisappear() {
        notificationCenter.removeObserver(self, name: .balanceUpdated, object: nil)
        notificationCenter.removeObserver(self, name: .hostConfigUpdated, object: nil)
    }
    
    func continueButtonPressed() {
        // An application won't fire haptics in the backgroud
        DispatchQueue.main.async { [weak self] in
                        
            // If we have the app, deep link to it
            guard let hostAppURLOnDevice = URL(string: "app-1-801438012284-ios-bb611cb4d83ea1a7f7caf9://") else {
                return
            }
            
            if UIApplication.shared.canOpenURL(hostAppURLOnDevice) {
                UIApplication.shared.open(hostAppURLOnDevice, options: [:], completionHandler: nil)
                return
            }

            self?.coordinator?.openAppStoreURL(rawURL: "1595159783")
        }
    }
    
    @objc
    func cashBalanceDidUpdate() {
        self.viewDelegate?.cashoutCashBalanceDidUpdate()
    }
    
    @objc
    func hostConfigDidUpdate() {
        self.viewDelegate?.cashoutCashBalanceDidUpdate()
    }
}

// MARK: - Localization

extension CashoutViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
