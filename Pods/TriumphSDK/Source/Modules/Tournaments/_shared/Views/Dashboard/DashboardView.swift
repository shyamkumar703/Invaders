// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class DashboardView: UIStackView {
    
    var viewModel: TournamentsDashboardViewModel? {
        didSet {
            viewModel?.viewDelegate = self
            switch screen {
            case .tournaments:
                setupViewsTournaments()
                addViewsToStackTournaments()
            default:
                setupLeftSideViewModels()
                setupRightSideViewModels()
            }
        }
    }

    private lazy var dashboardBalanceView = DashboardBalanceView()
    private lazy var dashboardHotStreakView = DashboardHotStreakView()
    private lazy var dashboardAccountView = DashboardAccountView()
    private lazy var dashboardWinView = DashboardWinView()
    
    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var tournamentsBalanceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 4
        stack.addArrangedSubview(tournamentsBalanceLabel)
        stack.addArrangedSubview(tournamentsTokensBalanceLabel)
        return stack
    }()
    
    private lazy var tournamentsBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.rounded(ofSize: 68, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tournamentsTokensBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.rounded(ofSize: 21, weight: .regular)
        label.textColor = .lightGreen
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tournamentsDepositCashoutStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.addArrangedSubview(depositButton)
        stack.addArrangedSubview(cashoutButton)
        return stack
    }()
    
    private lazy var depositButton: DashboardButton = {
        let button = DashboardButton()
        button.dashboardColor = .orandish
        button.dashboardTitleColor = .white
        button.name = "Deposit"
        button.icon = "square.and.arrow.down.fill"
        button.cornerRadius = 8
        button.onPress { [weak self] in
            self?.viewModel?.depositPressed()
        }
        return button
    }()
    
    private lazy var cashoutButton: DashboardButton = {
        let button = DashboardButton()
        button.dashboardTitleColor = .white
        button.name = "Cash Out"
        button.icon = "square.and.arrow.up.fill"
        button.cornerRadius = 8
        button.onPress { [weak self] in
            self?.viewModel?.cashOutPressed()
        }
        return button
    }()
    
    private var screen: TournamentScreen
    
    init(_ screen: TournamentScreen) {
        self.screen = screen
        super.init(frame: .zero)

        switch screen {
        case .tournaments:
            setupCommonTournaments()
        default:
            setupCommon()
            setupLeftStackView()
            setupRightSideView()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DashboardView {
    func setupCommon() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = 10
    }
    
    func setupLeftSideViewModels() {
        dashboardBalanceView.title = viewModel?.balanceTitle
        dashboardHotStreakView.title = viewModel?.hotStreakTitle
        Task { [weak self] in
            await MainActor.run { [weak self] in
                self?.dashboardBalanceView.amount = self?.viewModel?.balanceAmount
                self?.dashboardBalanceView.additionalInfo = self?.viewModel?.balanceAdditionalInfo
                self?.dashboardHotStreakView.hotstreak =  self?.viewModel?.streak
            }
            
        }
        //dashboardHotStreakView.viewModel = viewModel?.dashboardHotStreakViewModel
    }
    
    func setupRightSideViewModels() {
        switch screen {
        case .gameOver:
            dashboardWinView.viewModel = viewModel?.gameOverWinViewModel
            return
        case .tournaments:
            dashboardAccountView.viewModel = viewModel?.dashboardAccountViewModel
            return
        default: break
        }
    }
    
    func setupLeftStackView() {
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.addArrangedSubview(dashboardBalanceView)
        leftStackView.addArrangedSubview(dashboardHotStreakView)
        addArrangedSubview(leftStackView)
    }
    
    func setupRightSideView() {
        switch screen {
        case .gameOver:
            addArrangedSubview(dashboardWinView)
        case .tournaments:
            addArrangedSubview(dashboardAccountView)
        default: break
        }
    }
}

// MARK: - Tournaments Screen Dashboard
extension DashboardView {
    func setupCommonTournaments() {
        axis = .vertical
        distribution = .fill
        spacing = 20
    }
    
    func addViewsToStackTournaments() {
        addArrangedSubview(tournamentsBalanceStack)
        addArrangedSubview(tournamentsDepositCashoutStack)
    }
    
    func setupViewsTournaments() {
        tournamentsBalanceLabel.text = (viewModel?.balanceAmount ?? 0 * 100).formatCurrency()
        tournamentsTokensBalanceLabel.setText(viewModel?.balanceAdditionalInfo)
        tournamentsDepositCashoutStack.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
}

extension DashboardView: TournamentsDashboardViewDelegate {
    func balanceDidUpdate() {
        switch screen {
        case .tournaments:
            Task { @MainActor [weak self] in
                self?.tournamentsBalanceLabel.text = (self?.viewModel?.balanceAmount ?? 0 * 100).formatCurrency()
            }
        default:
            Task { [weak self] in
                let amount = self?.viewModel?.balanceAmount
                await MainActor.run { [weak self] in self?.dashboardBalanceView.amount = amount }
            }
        }
    }
    
    func tokenBalanceDidUpdate() {
        switch screen {
        case .tournaments:
            Task { @MainActor [weak self] in
                self?.tournamentsTokensBalanceLabel.setText(viewModel?.balanceAdditionalInfo)
            }
        default:
            Task { [weak self] in
                let tokenBalance = self?.viewModel?.balanceAdditionalInfo
                await MainActor.run { [weak self] in
                    self?.dashboardBalanceView.additionalInfo = tokenBalance
                }
            }
        }
    }
    
    func hotstreakDidUpdate() {
        Task { [weak self] in
            let hotstreak = self?.viewModel?.streak
            await MainActor.run { [weak self] in
                self?.dashboardHotStreakView.hotstreak = hotstreak
            }
        }
    }
}
