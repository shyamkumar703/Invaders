//
//  NetworkStrengthService.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 6/8/22.
//

import Foundation

protocol Network {
    var status: MatchConditionStatus? { get }
    func checkPing() async -> MatchConditionStatus
}

final class NetworkStrengthService: Network {
    
    var status: MatchConditionStatus?
    
    init() {
        Task { [weak self] in
            self?.status = await self?.checkPing()
        }
    }
    
    @discardableResult func checkPing() async -> MatchConditionStatus {
        if let url = URL(string: "https://dashboard.triumpharcade.com/") {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            do {
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 2.0
                sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
                sessionConfig.urlCache = nil
                let start = Date()
                let (_, response) = try await URLSession(configuration: sessionConfig).data(from: url)
                let finish = Date()
                if let response = response as? HTTPURLResponse,
                   response.statusCode == 200 {
                    let timeElapsed = finish.timeIntervalSince(start)
                    switch timeElapsed {
                    case 0..<1:
                        self.status = .good
                        return .good
                    case 1..<2:
                        self.status = .fair
                        return .fair
                    default:
                        self.status = .critical
                        return .critical
                    }
                }
            } catch {
                print(error)
                self.status = .critical
                return .critical
            }
        }
        self.status = .critical
        return .critical
    }
}
