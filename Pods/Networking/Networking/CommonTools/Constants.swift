//
//  Constants.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/11/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

public struct Constants {
    
    /// The ports used in the websocket handshake
    public enum Port {
        case plain
        case secure
        case custom(Int)
        
        var port: Int {
            switch self {
            case .plain:
                return 80
            case .secure:
                return 443
            case .custom(let x):
                return x
            }
        }
    }

    /**
     Schemes available for the network engine and websocket channels
     */
    public enum Scheme: String {
        case http
        case https
        case ws
        case wss
    }

    /**
     Dispatch queues for the input and output streams
     */
    public struct Queues {
        public static let iStreamQueue = DispatchQueue(label: "com.doordash.network.websocket.IStreamQueue")
        public static let oStreamQueue = DispatchQueue(label: "com.doordash.network.websocket.OStreamQueue")
    }
    
    /**
     Global errors for the websocket connections
     */
    public enum Errors: Error {
        case streamsNotConnected
    }
    
    /**
     The 'magic' number of the websocket handshake
     */
    struct WebSocket {
        static let HandshakeKeySuffix = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
    }
}
