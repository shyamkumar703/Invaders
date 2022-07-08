// Copyright © TriumphSDK. All rights reserved.

import UIKit

public protocol SwiftMessage {
    var dependencies: HasLocalization & HasSharedSession & HasAppInfo { get }
    var swiftMessageTopPremenantConfig: SwiftMessages.Config { get }
    var switMessageBottomPermenantConfig: SwiftMessages.Config { get }
    var swiftMessageTopTemporaryConfig: SwiftMessages.Config { get }
    var swiftMessageStatusConfig: SwiftMessages.Config { get }
    
    func showMessage(_ swiftMessageModel: SwiftMessageModel)
    func hideMessage()
    
    func showErrorMessage(title: String, message: String)
    func showUnknownErrorMessage()
    func showStatusLineErrorMessage(_ message: String)
}

// MARK: - Impl.

open class SwiftMessageService: SwiftMessage {
  
    public var dependencies: HasLocalization & HasSharedSession & HasAppInfo
    
    private var model: SwiftMessageModel?

    public lazy var swiftMessageTopPremenantConfig: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.duration = .forever
        config.presentationStyle = .top
        config.interactiveHide = false
        config.dimMode = .gray(interactive: true)
        return config
    }()
    
    public lazy var switMessageBottomPermenantConfig: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.dimMode = .gray(interactive: true)
        config.duration = .forever
        config.presentationStyle = .bottom
        config.interactiveHide = true
        return config
    }()
    
    public lazy var swiftMessageTopTemporaryConfig: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.duration = .seconds(seconds: 3.0)
        config.presentationStyle = .top
        config.dimMode = .gray(interactive: true)
        return config
    }()
    
    public lazy var swiftMessageStatusConfig: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 1)
        config.prefersStatusBarHidden = true
        return config
    }()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public func showMessage(_ swiftMessageModel: SwiftMessageModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var config: SwiftMessages.Config
            var view: UIView
            
            switch swiftMessageModel.type {
            case .error:
                config = self.swiftMessageTopTemporaryConfig
                view = self.setUpErrorMessage(model: swiftMessageModel)
            case .statusLine:
                config = self.swiftMessageStatusConfig
                view = self.setUpStatusErrorMessage(model: swiftMessageModel)
            default:
                config = self.swiftMessageTopPremenantConfig
                view = self.setUpInfoMessage(model: swiftMessageModel)
            }
            
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    public func hideMessage() {
        SwiftMessages.hide()
    }
}

// MARK: - Setup

private extension SwiftMessageService {
    func setUpStatusErrorMessage(model: SwiftMessageModel) -> UIView  {
        let statusLineView = MessageView.viewFromNib(layout: .statusLine)
        statusLineView.backgroundView.backgroundColor = .red
        statusLineView.bodyLabel?.textColor = .white
        statusLineView.bodyLabel?.lineBreakMode = .byWordWrapping
        statusLineView.bodyLabel?.numberOfLines = 0
        statusLineView.configureContent(body: model.message)
        return statusLineView
    }
    
    func setUpErrorMessage(model: SwiftMessageModel) -> UIView  {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureTheme(
            backgroundColor: #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1),
            foregroundColor: .white
        )
        view.bodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        view.configureContent(title: .string(""), body: model.message)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        return view
    }
    
    func setUpInfoMessage(model: SwiftMessageModel) -> UIView {
        let view = MessageView.viewFromNib(layout: .centeredView)
        view.configureTheme(.info)
        view.configureDropShadow()
        view.backgroundView.backgroundColor = .lead
        view.button?.isHidden = true
        view.titleLabel?.setText(model.title)
        view.bodyLabel?.setText(model.title)
        view.iconLabel?.text = "🔥"
        view.configureContent(title: model.title, body: model.message, iconText: model.emoji ?? .string("🔥"))
        view.titleLabel?.textColor = .white
        view.bodyLabel?.textColor = .white
        view.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.bodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return view
    }
}

// MARK: - Base methods

extension SwiftMessageService {

    public func showUnknownErrorMessage() {
        let messageModel = SwiftMessageModel(
            title: .string("Error"),
            message: .string("We encountered an unknown error. Try again later."),
            type: .error
        )
        showMessage(messageModel)
    }
    
    public func showErrorMessage(title: String, message: String) {
        let messageModel = SwiftMessageModel(title: .string(title), message: .string(message), type: .error)
        showMessage(messageModel)
    }

    public func showStatusLineErrorMessage(_ message: String) {
        let messageModel = SwiftMessageModel(title: .string(""), message: .string(message), type: .statusLine)
        showMessage(messageModel)
    }
}
