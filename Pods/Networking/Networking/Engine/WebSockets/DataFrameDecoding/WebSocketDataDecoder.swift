//
//  WebSocketDataDecoder.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/17/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

final class WebSocketDataDecoder {
    
    /// The managed data instance used internally to concatenate fragmented data frames
    private let managedData = ManagedData()
    
    /// The stream data object constructed from the assembled payload
    public var streamData: StreamData {
        return StreamData(data: payload, translated: type)
    }
    
    /// Tells whether all data fragments have been read and processed
    var isFinalized: Bool = false
    
    /// Tells if the decoder has already had one or more fragments written into it
    var isStarted: Bool = false
    
    /// The payload data
    private var payload: Data {
        return managedData.data
    }
    
    private var type: WebSocketFrameType?
    
    /**
     Appends a new data fragment read from the stream
     - parameter frame: The websocket data frame received
     */
    func append(fragment frame: WebSocketDataFrame) {
        guard (frame.type == .continuation && managedData.length > 0) ||
               (frame.type != .continuation && managedData.length == 0) else { return }
        
        if !isStarted {
            type = frame.type
        }
        
        managedData.append(contentsOf: frame.payload)
        isFinalized = frame.isFinal
        isStarted = true
    }
}
