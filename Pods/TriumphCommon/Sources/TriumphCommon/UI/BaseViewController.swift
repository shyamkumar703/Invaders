//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit

@MainActor open class BaseViewController: UIViewController, BaseController {

    public lazy var scrollView = UIScrollView()
    public lazy var contentView = UIView()
    public lazy var progressView = ProgressHUD()
    private var alert: UIAlertController?

    public private(set) var topNavBarViewLastYPosition: CGFloat = 20
    public private(set) var keyboardHeight: CGFloat = 0
    public private(set) var keyboardBarHeight: CGFloat = 0
    public private(set) var isKeyboardShowing = false
    public private(set) var isKeyboardBarShowing: Bool = false
    
    public var isKeyboardingForceKeep: Bool = false
    
    deinit {
        print("DEINIT \(self)")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.parentViewController?.viewDidDisappear(true)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        guard let navigationController = self.navigationController else { return }
        if (navigationController.isBeingDismissed) {
            self.navigationController?.parentViewController?.viewDidAppear(true)
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        baseDidLayoutSubviews()
    }
}

// MARK: - Top Nav Buttons

public extension BaseViewController {
    func setupLeftTopNavButton(type: BaseTopBarButtonType) {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.setupLeftTopNavButton(type: type)
        if topNavBarViewLastYPosition == .zero { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            navigationController.leftTopNavButton.frame.origin.y = self.topNavBarViewLastYPosition
            navigationController.rightTopNavButton.frame.origin.y = self.topNavBarViewLastYPosition
        }
    }
    
    func setupRightTopNavButton(type: BaseTopBarButtonType) {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.setupRightTopNavButton(type: type)
        if topNavBarViewLastYPosition == .zero { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            navigationController.rightTopNavButton.frame.origin.y = self.topNavBarViewLastYPosition
        }
    }
    
    func hideRightTopNavButton() {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.hideRightTopNavButton()
    }
    
    func leftTopBarButtonEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let navigationController = self.navigationController as? BaseNavigationController else { return }
            navigationController.leftTopNavButton.isUserInteractionEnabled = isEnabled
        }
        
    }
    
    func rightTopBarButtonEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let navigationController = self.navigationController as? BaseNavigationController else { return }
            navigationController.rightTopNavButton.isUserInteractionEnabled = isEnabled
        }
    }
    
    func hideTopNavBar() {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.hideTopNavBarView()
    }
    
    func showTopNavBar() {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.showTopNavBarView()
    }
}

// MARK: - Setup Keyboard

extension BaseViewController {
    @objc open func keyboardWillShow(_ notification: NSNotification) {
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            keyboardWillAppear()
        }
    }
    
    @objc open func keyboardDidShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardBarHeight = keyboardFrame.cgRectValue.height - self.keyboardHeight
            
            if keyboardBarHeight > 0 && isKeyboardBarShowing == false {
                self.keyboardBarHeight = keyboardBarHeight
                isKeyboardBarShowing = true
            } else if keyboardBarHeight.isZero {
                self.keyboardBarHeight = -self.keyboardBarHeight
                isKeyboardBarShowing = false
            } else {
                return
            }

            keyboardDidAppear()
        }
    }
    
    @objc open func keyboardWillHide() {
        if isKeyboardingForceKeep == true { return }
        if isKeyboardShowing == false { return }

        isKeyboardShowing = false
        isKeyboardBarShowing = false
        keyboardBarHeight = 0
        keyboardWillDisappear()
    }
}

extension BaseViewController {
    public func hideKeyboard() {
        dismissKeyboard()
        isKeyboardShowing = false
    }
    
    @objc open dynamic func keyboardWillAppear() {}
    @objc open dynamic func keyboardDidAppear() {}
    @objc open dynamic func keyboardWillDisappear() {}
}

// MARK: - Setup Scroll View

extension BaseViewController {
    public func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        setupScrollViewConstrains()
        setupContentViewConstrains()
    }
}

// MARK: - UIScrollViewDelegate

extension BaseViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        topNavBarViewLastYPosition = -(scrollView.contentOffset.y) + navigationController.topNavBarPadding
        navigationController.leftTopNavButton.frame.origin.y = topNavBarViewLastYPosition
        navigationController.rightTopNavButton.frame.origin.y = topNavBarViewLastYPosition
    }
}

// MARK: - Constrains

private extension BaseViewController {
    func setupScrollViewConstrains() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupContentViewConstrains() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(250)
        heightConstraint.isActive = true
    }
}

// MARK: - Keyboard Toolbar

extension BaseViewController {
    func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
                previousButton.width = 30
                
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            items.append(contentsOf: [spacer, doneButton])

            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
}
