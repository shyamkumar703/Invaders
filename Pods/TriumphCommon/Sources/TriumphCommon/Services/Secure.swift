// Copyright © TriumphSDK. All rights reserved.

import UIKit
import CryptoKit
import FirebaseAppCheck

public enum SecureError: Error {
    case noData
    case idToken
    case noUserRandom
    case noHttpMethod
    case headers
    case URLFailed
    case noBody
    case serverIssue
}

public protocol Secure {
    @discardableResult
    func call<R: Request>(request: R) async throws -> R.Output?
}

// MARK: - Impl.

class SecureService: Secure {
    private var dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Call
    @discardableResult
    func call<R: Request>(request: R) async throws -> R.Output? {
        let response = try await execute(request: request)
        return response
    }
    
    // MARK: - Execute Request
    private func execute<R: Request>(request: R) async throws -> R.Output? {
        let headers = try await buildHeaders(request: request)
        
        guard let httpMethod = request.httpMethod else {
            throw SecureError.noHttpMethod
        }

        let baseUrl = await UIApplication.baseURL
        
        guard let url = URL(string: "\(baseUrl)/\(request.path)") else {
            throw SecureError.URLFailed
        }
        

        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = httpMethod.rawValue

        if request.httpMethod != .get {
            guard let body = request.body?.data(using: .utf8) else {
                throw SecureError.noBody
            }
            urlRequest.httpBody = body
        }
        
        dependencies.logger.log(urlRequest.description)

        let (data, response) = try await URLSession.shared.data(from: urlRequest)

        switch (response as? HTTPURLResponse)?.statusCode {
        case 401:
            if request.path.contains("tournaments/") {
                NotificationCenter.default.post(name: .showServerUnavailableAlert, object: nil)
                throw SecureError.serverIssue
            }
            fallthrough
        case 500, 503:
            NotificationCenter.default.post(name: .showServerUnavailableAlert, object: nil)
            throw SecureError.serverIssue
        default:
            break
        }
        
        if let emptyResponse = EmptyResponse() as? R.Output {
            return emptyResponse
        }

        return try JSONDecoder().decode(R.Output.self, from: data)
    }
    
    // MARK: - Build Headers
    private func buildHeaders<R: Request>(request: R) async throws -> [String: String] {
        guard let token = try await dependencies.authentication.getIDToken() else {
            throw SecureError.idToken
        }
    
        var headers: [String: String] = ["Game-Id": self.dependencies.appInfo.id, "X-Request-ID" : UUID().uuidString]

        if await UIDevice.current.isSimulator == false {
            let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false)
            headers["X-Firebase-AppCheck"] = appCheckToken.token
        }
        
        if request.shouldUseTriumphSignature {
            
            guard let user = await self.dependencies.sharedSession.user, let random = user.random1 else {
                throw SecureError.noUserRandom
            }
            
            if let queryString = request.body {
                
                let queryStringWithRandom = queryString + String(random)
                
                guard let data = queryStringWithRandom.data(using: .utf8) else { return headers }

                let digest = SHA256.hash(data: data)
                headers.merge(dict: [
                    "Firebase-Id-Token": token,
                    "Triumph-Signature": digest.hexStr.lowercased(),
                    "Content-Type": "application/json; charset=utf-8"
                ])
                
            } else {
                guard request.httpMethod == .get else {
                    throw SecureError.headers
                }
                
                headers.merge(dict: [
                    "Firebase-Id-Token": token,
                    "Content-Type": "application/json; charset=utf-8"
                ])
            }

        } else {
            headers.merge(dict: [
                "Firebase-Id-Token": token,
                "Content-Type": "application/json; charset=utf-8"
            ])
        }
        
        dependencies.logger.log(headers)
        return headers
    }
}
