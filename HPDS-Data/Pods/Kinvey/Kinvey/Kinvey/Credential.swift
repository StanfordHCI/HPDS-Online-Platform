//
//  Credentials.swift
//  Kinvey
//
//  Created by Victor Barros on 2015-12-14.
//  Copyright © 2015 Kinvey. All rights reserved.
//

import Foundation

/// Protocol that provides an autorization header used for set the `Authorization` header required by Kinvey calls.
public protocol Credential {
    
    /// Autorization header used for set the `Authorization` header required by Kinvey calls.
    var authorizationHeader: String? { get }

}

struct BasicAuthCredential: Credential {
    
    let username: String
    let password: String
    
    var authorizationHeader: String? {
        let token = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? ""
        return "Basic \(token)"
    }
    
}
