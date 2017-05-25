//
//  WebSocketHandshaking.swift
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
protocol WebSocketHandshaking {
    
    /**
     Returns an endpoint to the provided host to initiate the handshake
     - parameter address: The host's address, including the URL, the scheme, the path, and - if provided - the port, e.g. https://somehost<:port>
     - parameter protocols: An optional list of protocols to suggest for the websocket handshake. By default the value is an empty array.
     - parameter port: The port to use for the stream connection
     - parameter connection: A stream connection to use for the handshake
     */
    func performHandshake(to address: String, specifying protocols: [String], port: Constants.Port, completion: @escaping (Processable) -> Void) throws -> StreamConnection?
    
    /**
     Returns the websocket protocol version to use. The default value is `"13"`
     */
    var webSocketProtocolVersion: String { get }
}

extension WebSocketConnecting {
    
    var webSocketProtocolVersion: String {
        return "13"
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
    
    func performHandshake(to address: String, specifying protocols: [String] = [], port: Constants.Port = .secure, completion: @escaping (Processable) -> Void) throws -> StreamConnection? {
        guard var components = URLComponents(string: address) else { throw Constants.Errors.handshakeUrlInvalid }
        components.port = port.port
        guard let url = components.url,
            let origin = components.origin,
            let host = components.host else {
                throw Constants.Errors.handshakeUrlInvalid
        }
        
        guard let key = connectionSecKey else { throw Constants.Errors.secureKeyInvalid }
        
        var connection = StreamConnection(host: host, port: port)
        connection.connect()
        try connection.openStreams()
        
        guard connection.inputStream?.streamStatus == .open, connection.outputStream?.streamStatus == .open, connection.outputStream?.hasSpaceAvailable == true else {
            throw Constants.Errors.streamsNotConnected
        }
        
        let headerFields = headers(to: origin, using: key, protocols: protocols)
        let message = CFHTTPMessage.message(method: "GET", url: url)
        message.allHeaderFields = headerFields.allHeaderFields
        let processor = WebSocketHandshakeResponseErrorProcessor(accepting: key, protocols: protocols)
        
        connection.inputHandler?.readHandler = { inputStream in
            inputStream.readInput().map { OperationResult(with: HTTPURLResponse(url: url, data: $0), data: $0) }
                .flatMap { processor.process(result: $0, completion: completion) }
        }
        
        if let data = message.data {
            connection.outputStream?.write(data.bytes, maxLength: data.count)
        }
        
        return connection
    }
}
