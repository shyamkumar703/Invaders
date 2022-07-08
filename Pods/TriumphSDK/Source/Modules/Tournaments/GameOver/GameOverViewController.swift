// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class GameOverViewController: StepViewController {
   
    private var viewModel: GameOverViewModel
    private let dashboardView = DashboardView(.gameOver(0))
    private let gameOverResultView = GameOverResultView()
    
    init(viewModel: GameOverViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCommon()
        setupDashboardView()
        
        if viewModel.isResultReady {
            setupViewModels()
            setupGameOverResultView()
            setupStartButton()
        }
        
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .back)
        leftTopBarButtonEnabled(true)
        rightTopBarButtonEnabled(true)
        setupRightTopNavButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setupLeftTopNavButton(type: .close)
        leftTopBarButtonEnabled(true)
        rightTopBarButtonEnabled(false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisapear()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}

// MARK: - BaseNavigationControllerViewDelegate

extension GameOverViewController: BaseNavigationControllerViewDelegate {
    func baseNavigationControllerTopBarButtonDidPress(senderType: BaseTopBarButtonType) {
        if senderType == .report {
            viewModel.startIntercom()
        }
    }
    
}

// MARK: - Setup

extension GameOverViewController {
    func setupViewModels() {
        gameOverResultView.viewModel = viewModel.gameOverResultViewModel
        dashboardView.viewModel = viewModel.tournamentsDashboardViewModel
    }

    func setupCommon() {
        view.backgroundColor = .black
        continueButton.alpha = 0
        continueButton.isGlowingEnabled = false
    }
    
    func setupDashboardView() {
        view.addSubview(dashboardView)
        setupDashboardViewConstrains()
    }

    func setupGameOverResultView() {
        view.addSubview(gameOverResultView)
        setupGameOverResultViewConstrains()
    }
    
    func setupStartButton() {
        continueButton.setTitle(viewModel.startButtonTitle, for: .normal)
        continueButton.isSpringLoaded = false
        continueButton.onPress { [weak self] in
            Task { [weak self] in
                let wasStartButtonPressed = await self?.viewModel.startButtonPressed()
                if wasStartButtonPressed == true {
                    await MainActor.run { [weak self] in
                        self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                        self?.leftTopBarButtonEnabled(false)
                        self?.rightTopBarButtonEnabled(false)
                    }
                }
            }
        }
        setupStartButtonAnimation()
    }
    
    func setupRightTopNavButton() {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.setupRightTopNavButton(type: .report)
        navigationController.viewDelegate = self
    }
    
    private func setupStartButtonAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.continueButton.alpha = 1
        } completion: { _ in
            let deadline: DispatchTime = .now() + self.viewModel.animationDuration.value
            DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
                guard let self = self else { return }
                self.continueButton.isGlowingEnabled = true
            }
        }
    }
}

// MARK: - GameOverViewModelViewDelegate

extension GameOverViewController: GameOverViewModelViewDelegate {
    func gameOverStartLoading() {
        startActivityIndicator()
    }
    
    func gameOverFinishLoading() {
        setupViewModels()
        stopActivityIndicator()
        setupGameOverResultView()
        setupStartButton()
    }
    
    func gameOverStartPlayButtonLoading() {
        continueButton.showLoading()
    }
    
    func gameOverFinishPlayButtonLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.continueButton.hideLoading()
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            self.leftTopBarButtonEnabled(true)
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish() {
        if continueButton.isLoading == true {
            continueButton.hideLoading()
        } else {
            setupViewModels()
            stopActivityIndicator()
            setupGameOverResultView()
            setupStartButton()
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func updatePlayAgainButton() {
        continueButton.setTitle(viewModel.startButtonTitle, for: .normal)
    }
}

// MARK: - Constrains

private extension GameOverViewController {
    func setupDashboardViewConstrains() {
        dashboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dashboardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            dashboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            dashboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            dashboardView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    func setupGameOverResultViewConstrains() {
        gameOverResultView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameOverResultView.topAnchor.constraint(equalTo: dashboardView.bottomAnchor, constant: 25),
            gameOverResultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gameOverResultView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gameOverResultView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -40)
        ])
    }
}
