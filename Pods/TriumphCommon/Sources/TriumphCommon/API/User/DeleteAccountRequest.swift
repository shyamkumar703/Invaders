//
//  File.swift
//  
//
//  Created by Maksim Kalik on 6/30/22.
//

import Foundation

struct DeleteAccountRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "users/delete"
}
