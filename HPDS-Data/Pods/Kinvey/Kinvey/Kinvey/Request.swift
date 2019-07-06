//
//  Request.swift
//  Kinvey
//
//  Created by Victor Barros on 2016-01-07.
//  Copyright © 2016 Kinvey. All rights reserved.
//

import Foundation

/// Protocol that represents a request made to the backend.
public protocol Request : ProgressReporting {
    
    /// Indicates if a request still executing or not.
    var executing: Bool { get }
    
    /// Indicates if a request was cancelled or not.
    var cancelled: Bool { get }
    
    /// Cancels a request in progress.
    func cancel()
    
    /// Result Type expected for a specific request.
    associatedtype ResultType
    
    /// Result object expected for a specific request.
    var result: ResultType? { get }
    
}

extension Request {
    
    /// Returns `true` if the result is returned or `false` if the timeout ended before the result was returned.
    @discardableResult
    public func wait(timeout: TimeInterval = TimeInterval.infinity) -> Bool {
        var fulfilled = false
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 0) { (observer, activity) in
            if self.result != nil {
                fulfilled = true
                CFRunLoopStop(CFRunLoopGetCurrent())
            } else {
                CFRunLoopWakeUp(CFRunLoopGetCurrent())
            }
        }
        
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, .defaultMode)
        CFRunLoopRunInMode(.defaultMode, timeout, false)
        CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, .defaultMode)
     
        return fulfilled
    }
    
    /// Returns the `ResultType` if the result is returned or throws an `Error.requestTimeout` error if the timeout ended before the result was returned.
    public func waitForResult(timeout: TimeInterval = TimeInterval.infinity) throws -> ResultType {
        guard wait(timeout: timeout), let result = result else {
            throw Error.requestTimeout
        }
        return result
    }
    
}

public class AnyRequest<T>: NSObject, Request {
    
    public typealias ResultType = T
    
    private let _getExecuting: () -> Bool
    
    public var executing: Bool {
        return _getExecuting()
    }
    
    private let _getCancelled: () -> Bool
    
    public var cancelled: Bool {
        return _getCancelled()
    }
    
    private let _cancel: () -> Void
    
    public func cancel() {
        _cancel()
    }
    
    private let _getResult: () -> T?
    
    public var result: T? {
        return _getResult()
    }
    
    private let _getProgress: () -> Progress
    
    public var progress: Progress {
        return _getProgress()
    }
    
    init<RequestType: Request>(_ request: RequestType, conversionHandler: @escaping (RequestType.ResultType?) -> T?) {
        _getExecuting = { request.executing }
        _getCancelled = { request.cancelled }
        _cancel = request.cancel
        _getResult = { conversionHandler(request.result) }
        _getProgress = { request.progress }
    }
    
    init<RequestType: Request>(_ request: RequestType) where T == Any {
        _getExecuting = { request.executing }
        _getCancelled = { request.cancelled }
        _cancel = request.cancel
        _getResult = { request.result }
        _getProgress = { request.progress }
    }
    
    init<RequestType: Request>(_ request: RequestType) where RequestType.ResultType == T {
        _getExecuting = { request.executing }
        _getCancelled = { request.cancelled }
        _cancel = request.cancel
        _getResult = { request.result }
        _getProgress = { request.progress }
    }
    
    convenience init(_ result: ResultType) {
        let request = LocalRequest<ResultType>()
        request.result = result
        self.init(request)
    }
    
}
