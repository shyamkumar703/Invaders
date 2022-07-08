// Copyright © TriumphSDK. All rights reserved.

import UIKit

// MARK: - Alert

public struct AlertModel {
    public var title: String
    public var message: String
    public var okButtonTitle: String? = "Ok"
    public var okButtonStyle: UIAlertAction.Style = .default
    public var okHandler: ((UIAlertAction) -> Void)? = nil
    public var cancelButtonTitle: String? = "Cancel"
    public var cancelButtonStyle: UIAlertAction.Style = .cancel
    public var cancelHandler: ((UIAlertAction) -> Void)? = nil
    
    public init(
        title: String,
        message: String,
        okButtonTitle: String? = "Ok",
        okButtonStyle: UIAlertAction.Style = .default,
        okHandler: ((UIAlertAction) -> Void)? = nil,
        cancelButtonTitle: String? = "Cancel",
        cancelButtonStyle: UIAlertAction.Style = .cancel,
        cancelHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.okButtonTitle = okButtonTitle
        self.okButtonStyle = okButtonStyle
        self.okHandler = okHandler
        self.cancelButtonTitle = cancelButtonTitle
        self.cancelButtonStyle = cancelButtonStyle
        self.cancelHandler = cancelHandler
    }
}

// MARK: - Alert Alert

public struct ActionAlertModel {
    public var title: String
    public var message: String?
    public var cancelButtonTitle: String? = "Cancel"
    public var cancelHandler: ((UIAlertAction) -> Void)?
    public var actions: [UIAlertAction]
    
    public init(
        title: String,
        message: String? = nil,
        cancelButtonTitle: String? = "Cancel",
        cancelHandler: ((UIAlertAction) -> Void)? = nil,
        actions: [UIAlertAction]
    ) {
        self.title = title
        self.message = message
        self.cancelButtonTitle = cancelButtonTitle
        self.cancelHandler = cancelHandler
        self.actions = actions
    }
}

// MARK: - Text Field Alert

public struct TextFieldAlertModel {
    public var title: String? = nil
    public var message: String? = nil
    public var okButtonTitle: String? = "Ok"
    public var okButtonStyle: UIAlertAction.Style = .default
    public var cancelButtonTitle: String? = "Cancel"
    public var cancelButtonStyle: UIAlertAction.Style = .default
    public var okHandler: ((UIAlertAction) -> Void)? = nil
    public var cancelHandler: ((UIAlertAction) -> Void)? = nil
    public var inputPlaceholder: String? = nil
    public var inputText: String? = nil
    public var inputKeyboardType: UIKeyboardType = .default
    public var inputRightButtonTitle: String? = nil
    public var inputRightButtonHandler: (() -> Void)? = nil
    public var inputDidChange: ((_ textField: UITextField) -> Void)? = nil
    
    public init(
        alertModel: AlertModel,
        inputPlaceholder: String? = nil,
        inputText: String? = nil,
        inputKeyboardType: UIKeyboardType = .default,
        inputRightButtonTitle: String? = nil,
        inputRightButtonHandler: (() -> Void)? = nil,
        inputDidChange: ((UITextField) -> Void)? = nil
    ) {
        self.title = alertModel.title
        self.message = alertModel.message
        self.okButtonTitle = alertModel.okButtonTitle
        self.okButtonStyle = alertModel.okButtonStyle
        self.cancelButtonTitle = alertModel.cancelButtonTitle
        self.cancelButtonStyle = alertModel.cancelButtonStyle
        self.okHandler = alertModel.okHandler
        self.cancelHandler = alertModel.cancelHandler
        self.inputPlaceholder = inputPlaceholder
        self.inputText = inputText
        self.inputKeyboardType = inputKeyboardType
        self.inputRightButtonTitle = inputRightButtonTitle
        self.inputRightButtonHandler = inputRightButtonHandler
        self.inputDidChange = inputDidChange
    }
}
