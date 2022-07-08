// Copyright © TriumphSDK. All rights reserved.

import Foundation

public extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        for (key, value) in dict {
            if let value = value as? [Any],
               let generalValue = self[key] as? [Any] {
                let updatedValue = generalValue + value
                if let updatedValue = updatedValue as? Value {
                    updateValue(updatedValue, forKey: key)
                }
            } else {
                updateValue(value, forKey: key)
            }
        }
    }
    
    func contains(key: Key) -> Bool {
        index(forKey: key) != nil
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func toCodable<T: Codable>(of type: T.Type) -> T? {
        if let data = toJSON() {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }

    func toJSON() -> Data? {
        do {
            let dict = self.mapValues { ($0 as? Double)?.isNaN == true ? nil : $0 }
            return try JSONSerialization.data(withJSONObject: dict)
        } catch {
            return nil
        }
    }
    
    func toCodable<T: Codable & SelfIdentifiable>(with id: String, of type: T.Type) -> T? {
        var object = self.toCodable(of: T.self)
        object?.id = id
        return object
    }
    
    func stringify(withoutEscapingSlashes: Bool = false) -> String? {
        if withoutEscapingSlashes {
            if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .withoutEscapingSlashes),
               let jsonText = String(data: jsonData, encoding: .utf8) {
                return jsonText
            } else {
                return nil
            }
        } else {
            if let jsonData = try? JSONSerialization.data(withJSONObject: self),
               let jsonText = String(data: jsonData, encoding: .utf8) {
                return jsonText
            } else {
                return nil
            }
        }
    }
}
