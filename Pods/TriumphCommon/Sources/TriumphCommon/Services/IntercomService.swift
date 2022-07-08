// Copyright © TriumphSDK. All rights reserved.

import Foundation
import Intercom

public protocol IntercomService {
    var dependencies: HasLogger & HasLocalization { get }
    
    func configure()
    func configureWithUid(_ uid: String)
    func showMessenger(with message: String?)
}

// MARK: - Base Methods

public extension IntercomService {
    func showMessenger(with message: String? = nil) {
        if let message = message {
            Intercom.presentMessageComposer(message)
        } else {
            Intercom.presentMessenger()
        }
    }
}

// MARK: - Implementation

public class IntercomeServiceImplementation: IntercomService {
    
    public var dependencies: HasLogger & HasLocalization
    
    init(dependencies: HasLogger & HasLocalization) {
        self.dependencies = dependencies
    }
    
    public func configure() {
        Intercom.setApiKey(Configuration.General.intercomApiClientKey, forAppId: Configuration.General.intercomAppId)
        Intercom.setLauncherVisible(false)
        Intercom.setInAppMessagesVisible(false)
    }
    
    public func configureWithUid(_ uid: String) {
        Task { [weak self] in
            let attributes = ICMUserAttributes()
            attributes.userId = uid
            await MainActor.run { [weak self] in
                Intercom.loginUser(with: attributes) { result in
                    switch result {
                    case .success:
                        self?.dependencies.logger.log("Successfuly connected to Intercom")
                    case .failure(let error):
                        self?.dependencies.logger.log(
                            "Failed to connected to Intercom. Error: \(error.localizedDescription)",
                            .warning
                        )
                    }
                }
            }
        }
    }
}
