// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation

public class LocationViewController<ViewModel: BaseLocationViewModel>: StepViewController {

    private lazy var headerView = LocationHeaderView()
    private lazy var statesVideoView = LocationStatesVideoView()
    
    public var viewModel: ViewModel?
    public var shouldHideTopNavBar: Bool = false

    public override func viewDidLoad() {
        setupHeaderView()
        setupStatesView()
        setupContinueButton()
        super.viewDidLoad()
        
        if shouldHideTopNavBar == true {
            hideTopNavBar()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldHideTopNavBar == true {
            hideTopNavBar()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}

// MARK: - Setup

private extension LocationViewController {
    func setupHeaderView() {
        headerView.setTitle(viewModel?.title)
        view.addSubview(headerView)
        setupHeaderViewConstrains()
    }
    
    func setupStatesView() {
        view.addSubview(statesVideoView)
        setupStatesViewConstrains()
        guard let title = viewModel?.descriptionText else { return }
        statesVideoView.setTitle(title)
    }
    
    func setupContinueButton() {
        continueButton.setTitle(viewModel?.continueButtonTitle, for: .normal)
        continueButton.onPress { [weak self] in
            guard let self = self else { return }
            self.viewModel?.continueButtonPressed()
        }
        // If viewModel is nil or shouldShowActionButton is false, continue button is hidden
        continueButton.isHidden = viewModel?.shouldShowActionButton != true
    }
}

// MARK: - Constrains

private extension LocationViewController {
    func setupHeaderViewConstrains() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    func setupStatesViewConstrains() {
        statesVideoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statesVideoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statesVideoView.widthAnchor.constraint(equalTo: view.widthAnchor),
            statesVideoView.heightAnchor.constraint(equalToConstant: 320)
        ])
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            statesVideoView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -40).isActive = true
        } else {
            statesVideoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        }
    }
}
