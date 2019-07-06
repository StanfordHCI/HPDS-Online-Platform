//
//  Result.swift
//  Kinvey
//
//  Created by Victor Hugo on 2017-04-11.
//  Copyright © 2017 Kinvey. All rights reserved.
//

import Foundation

/**
 Enumeration that represents the result of an operation.
 Here's a sample code how to handle a `Result`
 ```
switch result {
case .success(let successObject):
    print("here you should handle the success case")
case .failure(let failureObject):
    print("here you should handle the failure case")
}
 ```
 */
public enum Result<SuccessType, FailureType> {
    
    /// Case when the result is a success result holding the succeed type value
    case success(SuccessType)
    
    /// Case when the result is a failure result holding the failure type value
    case failure(FailureType)
    
}

extension Result where FailureType == Swift.Error {
    
    /// Returns the `SuccessType` if the result is a `.success`, otherwise throws the `.failure` error
    public func value() throws -> SuccessType {
        switch self {
        case .success(let successType):
            return successType
        case .failure(let error):
            throw error
        }
    }
    
}

extension Result where FailureType == [Swift.Error] {
    
    /// Returns the `SuccessType` if the result is a `.success`, otherwise throws the `.failure` errors wrapped in a `MultipleErrors`
    public func value() throws -> SuccessType {
        switch self {
        case .success(let successType):
            return successType
        case .failure(let errors):
            throw MultipleErrors(errors: errors)
        }
    }
    
}
