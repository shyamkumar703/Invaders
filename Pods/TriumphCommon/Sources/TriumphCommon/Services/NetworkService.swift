// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebaseFirestore

public protocol NetworkService {
    var listenerKeys: [String] { get async }
    
    func getData<R: Request>(request: R) async throws -> R.Output?
    func getData<R: IdentifiableOutputRequest>(request: R) async throws -> [R.Output]
    func setData<R: Request>(request: R) async throws
    func update<R: Request>(request: R) async throws
    
    @discardableResult
    func call<R: Request>(request: R) async throws -> R.Output?
    
    func listenDocument<R: Request>(request: R, completion: @escaping (Result<R.Output, SessionError>) -> Void)
    func listenDocumentArray<R: Request>(request: R, completion: @escaping (Result<[R.Output], SessionError>) -> Void)
    func listenCollection<R: IdentifiableOutputRequest>(request: R, completion: @escaping (Result<[R.Output], SessionError>) -> Void)
    func removeListener(path: String) async
    func clearAll() async
}

// MARK: - Implementation

class NetworkServiceImplementation: NetworkService {

    typealias Dependencies = HasPerformance & HasLogger & HasSecure & HasAppInfo
    private var dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    var listenerKeys: [String] {
        get async {
            await Firestore.properties.listeners.keys.map { $0 }
        }
    }
    
    func getData<R: Request>(request: R) async throws -> R.Output? {
        await dependencies.performance.startRequestTrace(request)
        let response = try await Firestore.get(request: request)
        await dependencies.performance.stopRequestTrace(request)
        return response
    }
    
    func getData<R: IdentifiableOutputRequest>(request: R) async throws -> [R.Output] {
        await dependencies.performance.startRequestTrace(request)
        let response = try await Firestore.get(request: request)
        await dependencies.performance.stopRequestTrace(request)
        return response
    }
    
    func setData<R: Request>(request: R) async throws {
        await dependencies.performance.startRequestTrace(request)
        try await Firestore.set(request: request)
        await dependencies.performance.stopRequestTrace(request)
    }
    
    func update<R: Request>(request: R) async throws {
        await dependencies.performance.startRequestTrace(request)
        try await Firestore.update(request: request)
        await dependencies.performance.stopRequestTrace(request)
    }
    
    @discardableResult
    func call<R: Request>(request: R) async throws -> R.Output? {
        await dependencies.performance.startRequestTrace(request)
        let response = try await dependencies.secure.call(request: request)
        await dependencies.performance.stopRequestTrace(request)
        return response
    }
    
    func listenDocument<R: Request>(request: R, completion: @escaping (Result<R.Output, SessionError>) -> Void) {
        Firestore.listenDocument(request: request, completion: completion)
    }
    
    func listenDocumentArray<R: Request>(request: R, completion: @escaping (Result<[R.Output], SessionError>) -> Void) {
        Firestore.listenDocumentArray(request: request, completion: completion)
    }
    
    func listenCollection<R: IdentifiableOutputRequest>(request: R, completion: @escaping (Result<[R.Output], SessionError>) -> Void) {
        Firestore.listenCollection(request: request, completion: completion)
    }
    
    func removeListener(path: String) async {
        await Firestore.properties.removeValueFromListeners(for: path)
    }
    
    func clearAll() async {
        await Firestore.removeAll()
    }
}
