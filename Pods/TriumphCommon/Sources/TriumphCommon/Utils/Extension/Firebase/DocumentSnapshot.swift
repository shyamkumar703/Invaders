// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebaseFirestore

extension DocumentSnapshot {
    func data<T: Codable>(as: T.Type) -> T? {
        return data()?.toCodable(of: T.self)
    }
    
    func data<T: Codable>(fieldName: String, as: T.Type) -> [T] {
        let dataArray = (data()?[fieldName] as? [[String: Any]])?
            .compactMap { $0.toCodable(of: T.self) }
        return dataArray ?? []
    }
}

extension QueryDocumentSnapshot {
    func data<T: Codable & SelfIdentifiable>(identifiable: T.Type) -> T? {
        return data().toCodable(with: documentID, of: T.self)
    }
}
