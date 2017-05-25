//
//  Processable.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/17/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The basic requirement for an instance to be subject of processing
 */
public protocol Processable {
    
    /**
     The data payload
     */
    var data: Data? { get }
    
    /**
     Any error assocaited with the payload
     */
    var error: Error? { get }
    
    /**
     Any object or instance translated/transformed from the data received
     */
    var translated: Any? { get }
    
    /**
     Creates a new instance of itself by specifying the translated field
     - parameter value: The new value for the `translated` property of the returned instance
     - returns: A new `Processable` instance with the `translated` property set
     */
    func translating(to value: Any?) -> Self

    /**
     Creates a new instance of itself by specifying the error field
     - parameter error: The new value for the `error` property of the returned instance
     - returns: A new `Processable` instance with the `error` property set
     */
    func failing(becauseOf error: Error) -> Self
}

extension Processable {
    
    public func failing(becauseOf error: Error) -> Self {
        return self
    }
    
    public func translating(to value: Any?) -> Self {
        return self
    }
}
