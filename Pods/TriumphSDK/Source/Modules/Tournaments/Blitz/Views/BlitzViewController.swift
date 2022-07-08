// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class BlitzViewController: StepViewController {
    
    private lazy var haptics = UIImpactFeedbackGenerator()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 60, width: UIScreen.main.bounds.size.width - 40, height: 60))
        label.textColor = .white
        label.numberOfLines = .zero
        label.textAlignment = .center
        label.font = .rounded(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 100, width: UIScreen.main.bounds.size.width - 40, height: 60))
        label.textColor = .grayish
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()

    private var amountSegmentControl: UISegmentedControl?
    private let infographicView = BlitzInfographicView()
    private var viewModel: BlitzViewModel
    
    init(viewModel: BlitzViewModel) {
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
        setupTitleLabel()
        setupSubTitleLabel()
        setupAmountSegmentControl()
        setupInfographicView()
        setupStartButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .back)
        setupRightTopNavButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setupLeftTopNavButton(type: .close)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideRightTopNavButton()
        leftTopBarButtonEnabled(true)
        viewModel.viewDidDisapear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        infographicView.blitzInfographicViewModelDidUpdate()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

// MARK: - Setup

private extension BlitzViewController {
    func setupCommon() {
        view.backgroundColor = .black
    }
    
    func setupRightTopNavButton() {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.setupRightTopNavButton(type: viewModel.isGameFinished ? .report : .info)
        navigationController.viewDelegate = self
    }
    
    func setupTitleLabel() {
        titleLabel.text = viewModel.title
        view.addSubview(titleLabel)
    }

    func setupSubTitleLabel() {
        subTitleLabel.text = viewModel.subTitle
        view.addSubview(subTitleLabel)
    }

    func setupAmountSegmentControl() {
        amountSegmentControl = UISegmentedControl()
        guard let segmentControl = amountSegmentControl else { return }
        segmentControl.overrideUserInterfaceStyle = .dark
        view.addSubview(segmentControl)
        setupAmountSegmentControlConstrains()
        
        Task { @MainActor [weak self] in
            if let items = await self?.viewModel.getSegmentControlItems() {
                items.enumerated().forEach { amountSegmentControl?.insertSegment(withTitle: $0.element, at: $0.offset, animated: false)}
                let font = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .medium)]
                amountSegmentControl?.setTitleTextAttributes(font, for: .normal)
                
                guard let segmentControl = self?.amountSegmentControl else { return }
                segmentControl.selectedSegmentIndex = viewModel.segmentControlSelectedItem
                segmentControl.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
            }
        }
    }
    
    func setupInfographicView() {
        infographicView.viewModel = viewModel.infographicViewModel
        view.insertSubview(infographicView, at: 0)
        setupInfographicViewConstrains()
    }

    @objc func segmentControlChanged(segment: UISegmentedControl) {
        haptics.impactOccurred()
        viewModel.segmentControlChanged(index: segment.selectedSegmentIndex)
    }
}

// MARK: - BaseNavigationControllerViewDelegate

extension BlitzViewController: BaseNavigationControllerViewDelegate {
    func baseNavigationControllerTopBarButtonDidPress(senderType: BaseTopBarButtonType) {
        switch senderType {
        case .info, .report:
            viewModel.infoButtonPressed()
        default:
            return
        }
    }
}

// MARK: - Constrains

private extension BlitzViewController {
    func setupAmountSegmentControlConstrains() {
        amountSegmentControl?.translatesAutoresizingMaskIntoConstraints = false
        guard let segmentControl = self.amountSegmentControl else { return }
        NSLayoutConstraint.activate([
            segmentControl.heightAnchor.constraint(equalToConstant: 40),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            segmentControl.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: -10)
        ])
    }

    func setupInfographicViewConstrains() {
        infographicView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infographicView.topAnchor.constraint(
                equalTo: amountSegmentControl?.bottomAnchor ?? subTitleLabel.bottomAnchor,
                constant: 0
            ),
            infographicView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infographicView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infographicView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: 0)
        ])
    }
    
    func setupStartButton() {
        continueButton.setTitle(viewModel.startButtonTitle, for: .normal)
        continueButton.onPress { [weak self] in
            guard let self = self else { return }
            self.viewModel.startButtonPressed()
        }
    }
}

// MARK: - BlitzViewModelViewDelegate

extension BlitzViewController: BlitzViewModelViewDelegate {
    func blitzBuyInDidUpdate() {
        Task { @MainActor [weak self] in
            self?.subTitleLabel.text = self?.viewModel.subTitle
            self?.continueButton.setTitle(viewModel.startButtonTitle, for: .normal)
        }
    }

    func blitzDidShowLoading() {
        Task { @MainActor [weak self] in
            self?.startActivityIndicator()
            self?.leftTopBarButtonEnabled(false)
            self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            
        }
    }
    
    func blitzDidHideLoading() {
        Task { @MainActor [weak self] in
            self?.stopActivityIndicator()
            self?.leftTopBarButtonEnabled(true)
            self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    func segmentedControlItemsDidUpdate() {
        Task { @MainActor [weak self] in
            if let items = await self?.viewModel.getSegmentControlItems(),
               amountSegmentControl?.numberOfSegments == 0 {
                items.enumerated().forEach { amountSegmentControl?.insertSegment(withTitle: $0.element, at: $0.offset, animated: false)}
                let font = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .medium)]
                amountSegmentControl?.setTitleTextAttributes(font, for: .normal)
                
                guard let segmentControl = self?.amountSegmentControl else { return }
                segmentControl.selectedSegmentIndex = viewModel.segmentControlSelectedItem
                segmentControl.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
            }
        }
    }
}
