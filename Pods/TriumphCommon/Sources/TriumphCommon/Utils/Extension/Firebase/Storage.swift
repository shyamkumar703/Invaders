// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebaseStorage

public extension Storage {
    private static var storage = Storage.storage()

    private static func upload<R: Request>(
        _ data: Data,
        request: R,
        completion: @escaping (Result<Void, SessionError>) -> Void
    ) {
        let ref: StorageReference = storage.reference(withPath: request.path)
        ref.putData(data, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    static func upload<R: Request>(_ data: Data, request: R) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            upload(data, request: request) { result in
                continuation.resume(with: result)
            }
        }
    }

    static func getURL<R: Request>(request: R) async throws -> String? {
        let ref: StorageReference = storage.reference(withPath: request.path)
        return try await ref.downloadURL().absoluteString
    }

    static func delete<R: Request>(request: R) async throws {
        let ref: StorageReference = storage.reference(withPath: request.path)
        try await ref.delete()
    }
}
