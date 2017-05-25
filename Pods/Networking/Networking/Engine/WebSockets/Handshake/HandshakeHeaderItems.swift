//
//  HandshakeHeaderItems.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/23/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension URLComponents {
    
    /**
     Returns the `origin` of the receiver. The origin contains the scheme, the host name and the port, if available:
     
          https://www.example.com:8080
     
     It is used by the websocket handshake as the value for the header field `Host`
     */
    var origin: String? {
        guard let host = host, let scheme = scheme else { return nil }
        var origin = scheme + "://" + host
        
        if let port = port {
            origin += ":" + String(port)
        }
        
        return origin
    }
}

extension Array where Element == HeaderItem {
    
    /**
     Returns an array of `HeaderItems` containing all necessary header fields for a websocket handshake
     - parameter components: The `URLComponents` for the handshake endpoint
     - parameter key: The security key sent to validate the response
     - parameter version: The websocket protocol version number. The default value is `13`
     - parameter protocols: A list of secondary websocket protocols the client is offering to negotiate
     */
    init?(components: URLComponents, security key: String, version number: Int = 13, protocols: [String] = []) {
        var components = components
        components.queryItems = nil
        
        guard var host = components.host, let origin = components.origin else { return nil }
        
        if let port = components.port {
            host += ":" + String(port)
        }
        
        var headerItems = [HeaderItem(name: "Connection", value: "Upgrade"),
                           HeaderItem(name: "Sec-WebSocket-Version", value: String(number)),
                           HeaderItem(name: "Upgrade", value: "websocket"),
                           HeaderItem(name: "Host", value: host),
                           HeaderItem(name: "Origin", value: origin),
                           HeaderItem(name: "Sec-WebSocket-Key", value: key)]

        headerItems += protocols.map { HeaderItem(name: "Sec-WebSocket-Protocol", value: $0) }
        
        self.init(headerItems)
    }
}
