//
//  WebSocketDataFrame.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/9/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A dataframe used as 'packets' in the websocket streams
 */
public struct WebSocketDataFrame: WebSocketDataFraming, WebSocketMasking, StrongMaskingKeyGeneration, WebSocketFrameFragmentation {
    
    /// The managed data wrapping the actual data frame.
    var dataFrame: ManagedData
    
    /// The `Data` representation of the data frame
    var encodedDataFrame: Data {
        return dataFrame.data
    }
    
    var type: WebSocketFrameType
    
    var isFinal: Bool
    
    init(received data: Data) {
        let managed = ManagedData(managing: data)
        type = WebSocketFrameType(rawValue: managed[0][0..<4]) ?? .none
        isFinal = managed[0][7] == .high
        dataFrame = managed
    }
    
    init(data: Data? = nil, type: WebSocketFrameType? = nil, isFinal: Bool? = nil) {
        dataFrame = ManagedData(managing: nil)
        // since the data might be input data from an input stream these values only need to be set to any value in the managed data's bytebuffer if it is assembled on the client side
        self.type = type ?? .none
        self.isFinal = isFinal ?? true
        
        if let bytes = data?.bytes {
            dataFrame.append(contentsOf: createFrame(from: bytes).buffer)
        }
    }
}

// MARK: - Control frames
extension WebSocketDataFrame {

    /// Returns a new close frame
    static var close: WebSocketDataFrame {
        return WebSocketDataFrame(type: .close)
    }

    /// Returns a new ping frame
    static var ping: WebSocketDataFrame {
        return WebSocketDataFrame(type: .ping)
    }

    /// Returns a new pong frame
    static var pong: WebSocketDataFrame {
        return WebSocketDataFrame(type: .pong)
    }
}
