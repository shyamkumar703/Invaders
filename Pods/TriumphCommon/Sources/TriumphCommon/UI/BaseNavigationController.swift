//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit

public protocol BaseNavigationControllerViewDelegate: AnyObject {
    func baseNavigationControllerTopBarButtonDidPress(senderType: BaseTopBarButtonType)
}

public protocol BaseNavigationControllerCoordinatorDelegate: AnyObject {
    func baseNavigationControllerTopBarButtonDidPress(senderType: BaseTopBarButtonType)
    func baseNavigationControllerDidDismiss()
}

// MARK: - Controller

open class BaseNavigationController: UINavigationController {
    
    public weak var viewDelegate: BaseNavigationControllerViewDelegate?
    public weak var coordinatorDelegate: BaseNavigationControllerCoordinatorDelegate?
    private var alert: UIAlertController?
    private var alertTextFieldChangeAction: ((_ textField: UITextField) -> Void)?

    private var haptics = UIImpactFeedbackGenerator()
    public var isNavBarViewHidden: Bool = false
    
    public lazy var leftTopNavButton: BaseTopBarButton = {
        let button = BaseTopBarButton()
        button.addTarget(self, action: #selector(leftTopNavButtonTap), for: .touchUpInside)
        return button
    }()

    public lazy var rightTopNavButton: BaseTopBarButton = {
        let button = BaseTopBarButton()
        button.addTarget(self, action: #selector(rightTopNavButtonTap), for: .touchUpInside)
        return button
    }()
    
    public var topNavBarPadding: CGFloat {
        self.isModalInPresentation ? 20 : 50
    }
    
    deinit {
        print("DEINIT \(self)")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        setupCommon()
        setupBackroundColor()
        setupCornerRadius()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarHidden(true, animated: animated)
        setupLeftTopNavButton()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinatorDelegate?.baseNavigationControllerDidDismiss()
        setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupCommon() {
        interactivePopGestureRecognizer?.delegate = self
        navigationItem.setHidesBackButton(true, animated: false)
    }

    private func setupBackroundColor() {
        navigationBar.tintColor = .black
        navigationBar.barTintColor = .black
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        view.backgroundColor = .black
    }
    
    private func setupCornerRadius() {
        view.layer.cornerRadius = 27
        view.layer.masksToBounds = true
        view.layer.isOpaque = false
    }
    
    @objc private func leftTopNavButtonTap(_ sender: BaseTopBarButton) {
        // FIXME: - Refactor it to the single delegate
        coordinatorDelegate?.baseNavigationControllerTopBarButtonDidPress(senderType: sender.type)
        viewDelegate?.baseNavigationControllerTopBarButtonDidPress(senderType: sender.type)
    }
    
    @objc private func rightTopNavButtonTap(_ sender: BaseTopBarButton) {
        viewDelegate?.baseNavigationControllerTopBarButtonDidPress(senderType: sender.type)
        haptics.impactOccurred()
    }
}

// MARK: - Setup

extension BaseNavigationController {

    private func setupLeftTopNavButton() {
        view.addSubview(leftTopNavButton)
        setupLeftTopNavButtonConstrains()
    }
    
    public func setupLeftTopNavButton(type: BaseTopBarButtonType) {
        leftTopNavButton.type = type
    }
    
    public func setupRightTopNavButton(type: BaseTopBarButtonType) {
        rightTopNavButton.type = type
        rightTopNavButton.alpha = 0

        UIView.animate(withDuration: 0.5) {
            self.rightTopNavButton.alpha = 1
        } completion: { _ in
            self.view.addSubview(self.rightTopNavButton)
            self.setupRightTopNavButtonConstrains()
        }
    }
}

// MARK: - TopNavBarView

public extension BaseNavigationController {
    func hideTopNavBarView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: []) {
            self.leftTopNavButton.alpha = 0
            self.leftTopNavButton.isHidden = true
            self.rightTopNavButton.alpha = 0
            self.rightTopNavButton.isHidden = true
        } completion: { _ in
            self.isNavBarViewHidden = true
        }
    }
    
    func showTopNavBarView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            self.leftTopNavButton.alpha = 1
            self.leftTopNavButton.isHidden = false
            self.rightTopNavButton.alpha = 1
            self.rightTopNavButton.isHidden = false
            
        } completion: { _ in
            self.isNavBarViewHidden = false
        }
    }
    
    func hideRightTopNavButton() {
        if rightTopNavButton.isDescendant(of: view) == true {
            UIView.animate(withDuration: 0.5) {
                self.rightTopNavButton.alpha = 0
            } completion: { _ in
                self.rightTopNavButton.removeFromSuperview()
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension BaseNavigationController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        self.interactivePopGestureRecognizer?.isEnabled = self.viewControllers.count > 1
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BaseNavigationController: UIGestureRecognizerDelegate {}

// MARK: - Alert

public extension BaseNavigationController {
    // MARK: Show Alert
    func showAlert(_ alertModel: AlertModel, completion: (() -> Void)? = nil) {
        self.alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        self.alert?.overrideUserInterfaceStyle = .dark

        if alertModel.okButtonTitle != nil {
            alert?.addAction(
                UIAlertAction(
                    title: alertModel.okButtonTitle,
                    style: alertModel.okButtonStyle,
                    handler: alertModel.okHandler
                )
            )
        }

        if alertModel.cancelHandler != nil {
            alert?.addAction(
                UIAlertAction(
                    title: alertModel.cancelButtonTitle,
                    style: alertModel.cancelButtonStyle,
                    handler: alertModel.cancelHandler
                )
            )
        }

        guard let alert = self.alert else { return }
        present(alert, animated: true, completion: completion)
    }
    
    // MARK: Show Action Alert
    func showAlert(_ alertModel: ActionAlertModel, completion: (() -> Void)? = nil) {
        self.alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .actionSheet
        )
        self.alert?.overrideUserInterfaceStyle = .dark

        for action in alertModel.actions {
            alert?.addAction(action)
        }
        
        if alertModel.cancelHandler != nil {
            alert?.addAction(
                UIAlertAction(
                    title: alertModel.cancelButtonTitle,
                    style: .cancel,
                    handler: alertModel.cancelHandler
                )
            )
        }
        
        guard let alert = self.alert else { return }
        present(alert, animated: true, completion: completion)
    }
    
    // MARK: Show Alert with Text Field
    func showAlert(_ alertModel: TextFieldAlertModel, completion: ((String?) -> Void)? = nil) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = alertModel.inputPlaceholder
            textField.keyboardType = alertModel.inputKeyboardType
            textField.text = alertModel.inputText
            textField.font = UIFont.systemFont(ofSize: 16)
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange), for: .editingChanged)
            self.alertTextFieldChangeAction = alertModel.inputDidChange
            
            guard alertModel.inputRightButtonTitle != nil else { return }
            
            let button = BaseTextFieldButton(type: .system)
            button.setTitle(alertModel.inputRightButtonTitle, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            button.frame = CGRect(
                x: textField.frame.size.width - 25,
                y: 5,
                width: 25,
                height: 25
            )
            button.action = { [weak self] in
                guard self != nil else { return }
                textField.text = alertModel.inputText
                alertModel.inputRightButtonHandler?()
            }
            
            textField.rightView = button
            textField.rightViewMode = .unlessEditing
        }
        
        alert.addAction(
            UIAlertAction(
                title: alertModel.okButtonTitle,
                style: alertModel.okButtonStyle,
                handler: { _ in
                    completion?(alert.textFields?.first?.text)
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: alertModel.cancelButtonTitle,
                style: alertModel.cancelButtonStyle,
                handler: alertModel.cancelHandler
            )
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldDidChange(_ textField: UITextField) {
        alertTextFieldChangeAction?(textField)
    }
    
    // MARK: Dismiss Alert
    func dismissAlert(completion: (() -> Void)? = nil) {
        self.alert?.dismiss(animated: true, completion: completion)
    }
}

// MARK: - Constrains

private extension BaseNavigationController {
    func setupLeftTopNavButtonConstrains() {
        leftTopNavButton.translatesAutoresizingMaskIntoConstraints = false
        setupTopNavBarButtonConstraint(leftTopNavButton)
        leftTopNavButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    func setupRightTopNavButtonConstrains() {
        rightTopNavButton.translatesAutoresizingMaskIntoConstraints = false
        setupTopNavBarButtonConstraint(rightTopNavButton)
        rightTopNavButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: -20
        ).isActive = true
    }
    
    private func setupTopNavBarButtonConstraint(_ button: BaseTopBarButton) {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: topNavBarPadding),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}
