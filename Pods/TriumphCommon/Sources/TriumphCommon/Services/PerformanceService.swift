//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation
import FirebasePerformance

public protocol PerformanceService: Actor {
    var traces: Set<PerformanceTrace> { get }
    var dependencies: HasAppInfo & HasLogger { get }
    
    // MARK: - Basic Methods
    func createTrace(_ performanceTrace: PerformanceTrace) -> PerformanceTrace?
    @discardableResult
    func startTrace(_ performanceTrace: PerformanceTrace) -> PerformanceTrace?
    func getTrace(_ performanceTrace: PerformanceTrace) -> PerformanceTrace?
    func stopTrace(_ performanceTrace: PerformanceTrace)

    // MARK: - User Profile Data Trace
    func startUpdateUserProfileDataTrace(with fileSize: Int)
    func stopUpdateUserProfileDataTrace()
    
    // MARK: - Upload Profile Photo
    func startUploadProfilePhotoTrace(with fileSize: Int)
    func stopUploadProfilePhotoTrace()
}

// MARK: - Upload Profile Photo

public extension PerformanceService {
    func startUploadProfilePhotoTrace(with fileSize: Int) {
        let performanceTrace = startTrace(.uploadProfilePhoto)
        performanceTrace?.trace?.incrementMetric("log_photo_file_size", by: Int64(fileSize))
    }

    func stopUploadProfilePhotoTrace() {
        stopTrace(.uploadProfilePhoto)
    }
}

// MARK: - User Profile Data

public extension PerformanceService {

    func startUpdateUserProfileDataTrace(with fileSize: Int) {
        let performanceTrace = startTrace(.updateUserProfileData)
        performanceTrace?.trace?.incrementMetric("log_photo_file_size", by: Int64(fileSize))
    }

    func stopUpdateUserProfileDataTrace() {
        stopTrace(.updateUserProfileData)
    }
}

// MARK: - Requests

public extension PerformanceService {
    func startRequestTrace<R: Request>(_ request: R) {
        startTrace(.request(name: request.typeName))
    }
    
    func stopRequestTrace<R: Request>(_ request: R) {
        stopTrace(.request(name: request.typeName))
    }
}

// MARK: - Implementation

public actor PerformanceImplementation: PerformanceService {
    public var traces: Set<PerformanceTrace> = [] {
        didSet {
            let ids: [String] = traces.map { $0.id }
            dependencies.logger.log("Performance Traces: \(ids)")
        }
    }
    public var dependencies: HasAppInfo & HasLogger
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - Basic Methods

public extension PerformanceImplementation {
    func createTrace(_ performanceTrace: PerformanceTrace) -> PerformanceTrace? {
        guard traces.contains(performanceTrace) == false else { return nil }
        let performanceTrace = PerformanceTrace(rawValue: performanceTrace.rawValue)
        performanceTrace.trace?.setValue(dependencies.appInfo.id, forAttribute: "app_id")
        return performanceTrace
    }
    
    @discardableResult
    func startTrace(_ performanceTrace: PerformanceTrace) -> PerformanceTrace? {
        guard let performanceTrace = createTrace(performanceTrace) else { return nil }
        performanceTrace.trace?.start()
        traces.insert(performanceTrace)
        return performanceTrace
    }
    
    func getTrace(_ performanceTrace: PerformanceTrace) -> PerformanceTrace? {
        traces.first(where: { $0.id == performanceTrace.id })
    }
    
    func stopTrace(_ performanceTrace: PerformanceTrace) {
        guard let performanceTrace = getTrace(performanceTrace) else { return }
        performanceTrace.trace?.stop()
        traces.remove(performanceTrace)
    }
}

// MARK: - PerformanceTrace

extension PerformanceTrace {
    static let updateUserProfileData = PerformanceTrace(rawValue: "update_profile_data_trace")
    
    static let uploadProfilePhoto = PerformanceTrace(rawValue: "upload_profile_photo_trace")
    static let getProfilePhotoUrlOfCurrentUser = PerformanceTrace(rawValue: "get_profile_photo_url_of_current_user_trace")
    static let deleteProfilePhotoUrlOfCurrentUser = PerformanceTrace(rawValue: "delete_profile_photo_url_of_current_user_trace")
    
    static let createUser = PerformanceTrace(rawValue: "create_user_trace")
    static let signIn = PerformanceTrace(rawValue: "sign_in_trace")
    static let verifyOTP = PerformanceTrace(rawValue: "verify_otp_trace")
    static let verifyPhoneNumber = PerformanceTrace(rawValue: "verify_phone_number_trace")
    
    static func request(name: String) -> PerformanceTrace {
        PerformanceTrace(rawValue: "request_\(name)_trace")
    }
}
