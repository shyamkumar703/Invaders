//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation

enum ImageType: String, Codable {
    case link
    case local
}

struct OtherGame: Codable {
    var gameId: String
    var image: String?
    var appStoreURL: String?
    var isCompleted: Bool
    var urlScheme: String?
    var imageType: ImageType?
    
    private enum CodingKeys: String, CodingKey {
        case gameId
        case image
        case appStoreURL
        case isCompleted
        case urlScheme
        case imageType
    }
    
    init(gameId: String, image: String? = nil, appStoreURL: String? = nil, isCompleted: Bool, urlScheme: String? = nil, imageType: ImageType? = nil) {
        self.gameId = gameId
        self.image = image
        self.appStoreURL = appStoreURL
        self.isCompleted = isCompleted
        self.urlScheme = urlScheme
        self.imageType = imageType
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameId, forKey: .gameId)
        try container.encode(image ?? "", forKey: .image)
        try container.encode(appStoreURL ?? "", forKey: .appStoreURL)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(urlScheme ?? "", forKey: .urlScheme)
        try container.encode(imageType?.rawValue ?? "link", forKey: .imageType)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gameId = try values.decode(String.self, forKey: .gameId)
        image = try? values.decode(String.self, forKey: .image)
        appStoreURL = try? values.decode(String.self, forKey: .appStoreURL)
        isCompleted = try values.decode(Bool.self, forKey: .isCompleted)
        urlScheme = try? values.decode(String.self, forKey: .urlScheme)
        imageType = ImageType(rawValue: (try? values.decode(String.self, forKey: .imageType)) ?? "link") ?? .link
    }
}
