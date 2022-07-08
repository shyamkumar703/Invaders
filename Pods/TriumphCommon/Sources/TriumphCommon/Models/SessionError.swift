// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol SessionErrorProtocol: Error {
    var message: String { get }
}

public enum SessionError: SessionErrorProtocol {
    case firebaseError(Error)
    case noData
    case noId
    case noUserId
    case invalidEndpoint
    case invalidResponse
    case invalidRequest
    case decodeError
    
    public var message: String {
        switch self {
        case .noData:
            return "Invalid response"
        case .invalidEndpoint:
            return "Invalid endpoit"
        case .invalidRequest:
            return "Invalid request"
        case .decodeError:
            return "Decoding error"
        case .noUserId:
            return "No user Id"
        default:
            return localizedDescription
        }
    }
}
