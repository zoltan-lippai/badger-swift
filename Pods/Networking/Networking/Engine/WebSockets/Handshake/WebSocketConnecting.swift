//
//  WebSocketConnecting.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/19/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation
import CryptoSwift

/**
 Describes and provides default implementation for the websocket connection handshake steps
 */
protocol WebSocketConnecting {
    
    /**
     Returns an endpoint to the provided host to initiate the handshake
     - parameter origin: The host's address, including the URL scheme and - if provided - the port, e.g. https://somehost<:port>
     - parameter protocols: An optional list of protocols to suggest for the websocket handshake. By default the value is an empty array.
     - returns: An `EndPoint` object. The task of the endpoint will perform the handshake when processed by a `RequestProcessing` object. The return value provides customization if required, you can fill the `path` url path component to specify the handshake endpoint, or optionally other values as required by the HTTP endpoint, e.g.
     
            handshakeEndpoint(to: "https://myHost")
                .task
                .adding(["path": "/websocket/handshake/"])
                .adding(URLQueryItem(name: "<handshake>", value: "<name>"))
        
        You can also customize the endpoint by its mutator copy functions, e.g.
     
            handshakeEndpoint(to: "https://myHost").endPoint(processors: ArrayOfProcessorsToExecute).task ...
     */
    func handshakeEndpoint(to origin: String, specifying protocols: [String]) -> EndPoint?
    
    /**
     Returns the websocket protocol version to use. The default value is `"13"`
     */
    var webSocketProtocolVersion: String { get }
}

extension WebSocketConnecting {
    
    var webSocketProtocolVersion: String {
        return "13"
    }
    
    func handshakeEndpoint(to origin: String, specifying protocols: [String] = []) -> EndPoint? {
        guard let key = connectionSecKey else { return nil }
        return EndPoint(template: "\(origin)%path%", fields: headers(to: origin, using: key, protocols: protocols), processors: [WebSocketHandshakeResponseErrorProcessor(accepting: key)])
    }
    
    /// Returns a random secure connection key to use in the handshake
    private var connectionSecKey: String? {
        var key = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        key = key.substring(to: key.index(key.startIndex, offsetBy: 16))
        return key.data(using: .utf8)?.base64EncodedString()
    }
    
    /**
     The list of headers to include in the request
     - parameter origin: The origin address with scheme prefix, e.g. http://whatever.com:port
     - parameter key: The SHA1 key for the handshake
     - parameter protocols: The list of websocket protocols to send in the request
     - returns: An array of header items to include in the request, if the origin parameter is an actual host url. Otherwise returns an empty array.
     */
    private func headers(to origin: String, using key: String, protocols: [String] = []) -> [HeaderItem] {
        guard let components = URLComponents(string: origin) else { return [] }
        return [HeaderItem](components: components, security: key, protocols: protocols) ?? []
    }

    private var handshakeResponseProcessor: WebSocketHandshakeResponseErrorProcessor? {
        return connectionSecKey.map { WebSocketHandshakeResponseErrorProcessor(accepting: $0) }
    }
    
    func performHandshake(on connection: StreamConnection, handshake task: Requestable) {
        guard let request = task.request, let method = request.httpMethod, let url = request.url else { return }
        guard connection.inputStream?.streamStatus == .open, connection.outputStream?.streamStatus == .open, connection.outputStream?.hasSpaceAvailable == true else { return }
        
        let message = CFHTTPMessage.message(method: method, url: url)
        message.allHeaderFields = request.allHTTPHeaderFields

        if let data = message.data {
            connection.outputStream?.write(data.bytes, maxLength: data.count)
        }
    }
}
