//
//  StreamData.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/17/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A piece of stream data reconstructed from websocket data frame(s)
 */
public struct StreamData: Processable {
    
    /// The data payload received
    public var data: Data?
    
    /// Errors associated with the data retrieval or reconstruction
    public var error: Error?
    
    /// Any native object translated from the `data` downloaded
    public var translated: Any?
    
    public func failing(becauseOf error: Error) -> StreamData {
        return StreamData(data: data, error: error, translated: translated)
    }
    
    public func translating(to value: Any?) -> StreamData {
        return StreamData(data: data, error: error, translated: value)
    }
    
    /**
     Designated initializer to fill any non-`nil` fields
     - parameter data: The data downloaded. The default value is `nil`.
     - parameter error: Any error that might have occurred. The default value is `nil`.
     - parameter translated: Native object(s) translated from the downloaded data. The default value is `nil`
     */
    public init(data: Data? = nil, error: Error? = nil, translated: Any? = nil) {
        self.data = data
        self.error = error
        self.translated = translated
    }
}
