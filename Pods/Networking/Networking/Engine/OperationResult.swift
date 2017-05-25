//
//  OperationResult.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The network operation result. Bundles together all relevant piece of data for a network operation
 */
public struct OperationResult: ProcessableResponse, AsyncInvocable {

    /// The data downloaded if any. Can be `nil` if an error occured or the remote endpoint is not expected to respond with any data.
    public let data: Data?

    /// The error that occured during the operation
    public let error: Error?

    /// The translated native object type constructed from the data downloaded. Its type is specified by the `EndPoint` and `Request`'s `ResponseProcessor`s
    public let translated: Any?

    /// The url response
    public let response: HTTPURLResponse?

    /// The original task that started the operation
    public let request: Requestable?

    /// Indicates the result should be discared. No completion block with this result will be called
    public let shouldDrop: Bool

    /// Indicates the result contains some errors, and once corrected, the original request should be repeated.
    public let shouldRepeat: Bool
    
    var queue: DispatchQueue? {
        return (request as? AsyncInvocable)?.queue
    }

    /**
     Designated initializer
     - parameter response: The url response
     - parameter data: The downloaded data
     - parameter error: The error
     - parameter task: The original request
     - parameter translated: The native object converted from the downloaded data
     */
    public init(with response: URLResponse?, data: Data? = nil, error: Error? = nil, request: Requestable? = nil, translated: Any? = nil, shouldDrop: Bool? = nil, shouldRepeat: Bool? = nil) {
        self.data = data
        self.error = error
        self.response = response as? HTTPURLResponse
        self.request = request
        self.translated = translated
        self.shouldDrop = shouldDrop ?? false
        self.shouldRepeat = shouldRepeat ?? false
    }
    
    public func failing(becauseOf error: Error) -> OperationResult {
        return OperationResult(with: response, data: data, error: error, request: request, translated: translated, shouldDrop: shouldDrop, shouldRepeat: shouldRepeat)
    }
    
    public func translating(to value: Any?) -> OperationResult {
        return OperationResult(with: response, data: data, error: error, request: request, translated: value, shouldDrop: shouldDrop, shouldRepeat: shouldRepeat)
    }
    
    public func dropped() -> OperationResult {
        return OperationResult(with: response, data: data, error: error, request: request, translated: translated, shouldDrop: true, shouldRepeat: shouldRepeat)
    }
    
    public func repeated() -> OperationResult {
        return OperationResult(with: response, data: data, error: error, request: request, translated: translated, shouldDrop: shouldDrop, shouldRepeat: true)
    }
}
