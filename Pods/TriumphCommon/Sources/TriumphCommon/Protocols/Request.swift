// Copyright © TriumphSDK. All rights reserved.

import Foundation

public enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
}

public protocol Request {
    associatedtype Output: Response
    
    var path: String { get set }
    var output: Output? { get }
    var query: RequestQuery? { get }
    var queryPredicate: NSPredicate? { get }
    var httpMethod: HttpMethod? { get }
    var shouldUseTriumphSignature: Bool { get }
    var body: String? { get }
    var limit: Int? { get }
    var stringifyWithoutEscapingSlashes: Bool { get }
    var dict: [AnyHashable: Any]? { get }
}

extension Request {
    public var query: RequestQuery? {
        get { return nil }
        set {}
    }

    public var queryPredicate: NSPredicate? {
        get { return nil }
        set {}
    }

    public var output: Output? {
        get { return nil }
        set {}
    }
    
    public var httpMethod: HttpMethod? {
        get { return .post }
        set {}
    }
    
    public var shouldUseTriumphSignature: Bool {
        get { return true }
        set {}
    }
    
    public var body: String? {
        get {
            return query?.dictionary?.stringify(withoutEscapingSlashes: stringifyWithoutEscapingSlashes) ?? "{}"
        }
        set {}
    }
    
    public var limit: Int? {
        get { return nil }
        set {}
    }
    
    public var stringifyWithoutEscapingSlashes: Bool {
        get { return false }
        set {}
    }
    
    public var orderBy: String? {
        get { return nil }
        set {}
    }
    
    public var shouldSortDescending: Bool? {
       get { return nil }
       set {}
    }

    public var dict: [AnyHashable: Any]? {
        get { return nil }
        set {}
    }
    
    public var typeName: String {
        String(describing: Self.self)
    }
}

// MARK: - IdentifiableOutputRequest

public protocol IdentifiableOutputRequest: Request where Output: SelfIdentifiable {

}
