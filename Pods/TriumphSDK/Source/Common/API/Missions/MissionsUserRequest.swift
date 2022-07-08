//
//  MissionsUserRequest.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 2/23/22.
//

import Foundation
import TriumphCommon

struct MissionsUserRequest: IdentifiableOutputRequest {
    typealias Output = MissionUser
    var path: String
    
    init(userId: String) {
        self.path = "appUsers/\(userId)/missions"
    }
}
