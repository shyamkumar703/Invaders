// Copyright © TriumphSDK. All rights reserved.

import Foundation

public struct UserPublicInfo: Response, SelfIdentifiable {
    public init(
        id: String? = nil,
        createdAt: Double? = nil,
        name: String? = nil,
        profilePhotoURL: String? = nil,
        updateAt: Double? = nil,
        username: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.profilePhotoURL = profilePhotoURL
        self.updateAt = updateAt
        self.username = username
    }
    
    public var id: String?
    public var createdAt: Double?
    public var name: String?
    public var profilePhotoURL: String?
    public var updateAt: Double?
    public var username: String?
}
