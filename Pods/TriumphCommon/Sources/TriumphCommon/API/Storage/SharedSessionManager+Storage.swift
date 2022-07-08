// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebaseStorage
import FirebasePerformance

extension SharedSessionManager {
    func uploadProfilePhoto(_ data: Data) async throws {
        let uid = try getUserId()
        let request = UploadUserPhotoRequest(uid: uid)
        await dependencies.performance.startUploadProfilePhotoTrace(with: data.count)
        try await Storage.upload(data, request: request)
        await dependencies.performance.stopUploadProfilePhotoTrace()
    }
    
    func getProfilePhotoUrlOfCurrentUser() async throws -> String? {
        let uid = try getUserId()
        let request = UserProfilePhotoURLRequest(uid: uid)
        await dependencies.performance.startTrace(.getProfilePhotoUrlOfCurrentUser)
        let response = try await Storage.getURL(request: request)
        await dependencies.performance.stopTrace(.getProfilePhotoUrlOfCurrentUser)
        return response
    }
    
    func removeProfilePhotoOfCurrentUser() async throws {
        let uid = try getUserId()
        let request = DeleteUserPhotoRequest(uid: uid)
        await dependencies.performance.startTrace(.deleteProfilePhotoUrlOfCurrentUser)
        try await Storage.delete(request: request)
        await dependencies.performance.stopTrace(.deleteProfilePhotoUrlOfCurrentUser)
    }
}
