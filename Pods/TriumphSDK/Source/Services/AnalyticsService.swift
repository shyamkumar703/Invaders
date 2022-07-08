// Copyright © TriumphSDK. All rights reserved.

import FirebaseAnalytics
import Foundation
import TriumphCommon

protocol FirebaseAnalytics {
    func logEvent(_ loggingEvent: LoggingEvent)
}

class AnalyticsService: NSObject, FirebaseAnalytics {
    typealias Dependencies = HasAppInfo & HasSession
    private var dependencies: Dependencies
    private var taskID: String = UUID().uuidString {
        didSet {
            Analytics.setDefaultEventParameters([
                "taskID": taskID,
                "gameID": dependencies.appInfo.id
            ])
        }
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(invalidateTaskID),
            name: .invalidateTask,
            object: nil
        )
        Task { [weak self] in await self?.setDefaultLoggingParameters() }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .invalidateTask, object: nil)
    }
    
    /// Set FirebaseAnalytics default logging parameters
    func setDefaultLoggingParameters() async {
        var uid = "noUid"
        if let id = await dependencies.session.currentUserId {
            uid = id
        }
        Analytics.setDefaultEventParameters([
            "taskID": taskID,
            "gameID": dependencies.appInfo.id,
            "uid": uid
        ])
    }
    
    /// Log an analytics event
    func logEvent(_ loggingEvent: LoggingEvent) {
        Analytics.logEvent(loggingEvent.event.name, parameters: loggingEvent.parameters)
    }
    
    /// Invalidate the current taskID and assign a new one
    /// Called when app enters background
    @objc func invalidateTaskID() {
        taskID = UUID().uuidString
    }
}
