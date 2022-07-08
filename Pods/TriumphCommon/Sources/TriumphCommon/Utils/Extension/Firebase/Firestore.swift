// Copyright © TriumphSDK. All rights reserved.
// swiftlint:disable all

import Foundation
import FirebaseFirestore

public actor FirestoreProperties {
    public var listeners: [String : ListenerRegistration] = [:]
    public var paths: [String] = []
    
    public func removeValueFromListeners(for key: String) {
        if let listener = listeners[key] {
            listener.remove()
        }
        listeners.removeValue(forKey: key)
    }
    
    public func addValueToListeners(path: String, listener: ListenerRegistration) {
        listeners[path] = listener
    }
    
    public func removeAll() {
        listeners.forEach { $0.value.remove() }
        paths.removeAll()
        listeners.removeAll()
    }
}

public extension Firestore {
    static var db = Firestore.firestore()
    static var properties = FirestoreProperties()

    // MARK: - Get Document

    static func get<R: Request>(request: R) async throws -> R.Output? {
        return try await get(request.path)
    }
    
    static func get<T: Codable>(_ path: String) async throws -> T? {
        return try await db.document(path)
            .getDocument()
            .data(as: T.self)
    }
    
    // MARK: - Get Document Array
    
    static func getArray<R: Request>(request: R) async throws -> [R.Output] {
        return try await getArray(request.path)
    }

    static func getArray<T: Codable>(_ path: String) async throws -> [T] {
        
        var documentPath: String
        var lastPathComp: String?
        
        if let url = URL(string: path), url.pathComponents.count % 2 != 0 {
            documentPath = url.deletingLastPathComponent().absoluteString
            lastPathComp = url.lastPathComponent
        } else {
            documentPath = path
        }
        
        guard let fieldName = lastPathComp else { return [] }
        return try await db.document(documentPath)
          .getDocument()
          .data(fieldName: fieldName, as: T.self)
    }

    // MARK: - Get Documents

    static func get<R: IdentifiableOutputRequest>(request: R) async throws -> [R.Output] {
        guard let limit = request.limit else {
            return try await self.get(request.path)
        }
        
        if let orderBy = request.orderBy, let descending = request.shouldSortDescending {
            return try await db.collection(request.path)
                .limit(to: limit)
                .order(by: orderBy, descending: descending)
                .getDocuments()
                .documents
                .compactMap { $0.data(identifiable: R.Output.self) }
        } else {
            return try await db.collection(request.path)
                .limit(to: limit)
                .getDocuments()
                .documents
                .compactMap { $0.data(identifiable: R.Output.self) }
        }
    }

    static func get<T: Codable & SelfIdentifiable>(_ path: String) async throws -> [T] {
        return try await db.collection(path)
            .getDocuments()
            .documents
            .compactMap { $0.data(identifiable: T.self) }
    }

    // MARK: - Listen Document

    static func listenDocument<R: Request>(request: R, completion: @escaping (Result<R.Output, SessionError>) -> Void) {
        Task {
            if await properties.listeners.contains(key: request.path) == false {
                let ref: DocumentReference = db.document(request.path)
                listenDocument(ref, completion: completion)
            }
        }
    }
    
    static func listenDocument<T: Codable>(_ ref: DocumentReference, completion: @escaping (Result<T, SessionError>) -> Void) {
        let listener = ref.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            } else {
                guard let result: T = snapshot?.data(as: T.self) else {
                    completion(.failure(.noData))
                    return
                }
                completion(.success(result))
            }
        }
        
        Task {
            await properties.addValueToListeners(path: ref.path, listener: listener)
        }
    }

    // MARK: - Listen Document Array
    
    static func listenDocumentArray<R: Request>(request: R, completion: @escaping (Result<[R.Output], SessionError>) -> Void) {
        listenDocumentArray(request.path, completion: completion)
    }
    
    static func listenDocumentArray<T: Codable>(_ path: String, completion: @escaping (Result<[T], SessionError>) -> Void) {
        
        var documentPath: String
        var lastPathComp: String?
        
        if let url = URL(string: path), url.pathComponents.count % 2 != 0 {
            documentPath = url.deletingLastPathComponent().absoluteString
            lastPathComp = url.lastPathComponent
        } else {
            documentPath = path
        }
        
        let ref: DocumentReference = db.document(documentPath)
        guard let fieldName = lastPathComp else { completion(.failure(.noData)); return }
        
        Task {
            if await properties.listeners.contains(key: path) == false {
                let listener = ref.addSnapshotListener { snapshot, error in
                    if let error = error {
                        completion(.failure(.firebaseError(error)))
                    } else {
                        guard let result: [T] = snapshot?.data(fieldName: fieldName, as: T.self) else {
                            completion(.failure(.noData))
                            return
                        }
                        completion(.success(result))
                    }
                }
            
                await properties.addValueToListeners(path: ref.path, listener: listener)
            }
        }
    }
    
    // MARK: - Listen Documents
    
    static func listenCollection<R: IdentifiableOutputRequest>(request: R, completion: @escaping (Result<[R.Output], SessionError>) -> Void) {
        Task {
            if await properties.listeners.contains(key: request.path) == false {
                var query: Query = db.collection(request.path)
                if let predicate = request.queryPredicate {
                    query = query.filter(using: predicate)
                }
                
                listenCollection(query, request.path, completion: completion)
            }
        }
    }
    
    static func listenCollection<T: Codable & SelfIdentifiable>(_ query: Query, _ path: String, completion: @escaping (Result<[T], SessionError>) -> Void) {
        let listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            } else {
                guard let result: [T] = snapshot?.documents.compactMap({ $0.data(identifiable: T.self) }) else {
                    completion(.failure(.noData))
                    return
                }
                completion(.success(result))
            }
        }

        Task { await properties.addValueToListeners(path: path, listener: listener) }
    }

    // MARK: - Update Document
    
    static func update<R: Request>(request: R) async throws {
        try await update(
            data: request.query?.dictionary ?? request.dict ?? [:],
            path: request.path
        )
    }
    
    static func update(data: [AnyHashable: Any], path: String) async throws {
        try await db.document(path).updateData(data)
    }
    
    // MARK: - Set Document
    // Create document if it doesn't exist
    
    static func set<R: Request>(request: R) async throws {
        try await set(data: request.query?.dictionary ?? [:], path: request.path)
    }
    
    static func set(data: [String: Any], path: String) async throws {
        try await db.document(path).setData(data)
    }

    static func removeAll() async {
        await properties.removeAll()
    }
}
