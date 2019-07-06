//
//  LocalResponse.swift
//  Kinvey
//
//  Created by Victor Barros on 2016-01-18.
//  Copyright © 2016 Kinvey. All rights reserved.
//

import Foundation

class LocalResponse: Response {
    
    var isOK = true
    var isUnauthorized = false
    var isBadRequest = false
    var isNotModified = false
    var isForbidden = false
    var isNotFound = false
    var isMethodNotAllowed = false
    
    var etag: String? = nil
    var contentTypeIsJson: Bool = false

}
