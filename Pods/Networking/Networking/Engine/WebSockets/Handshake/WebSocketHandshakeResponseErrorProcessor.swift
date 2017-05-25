//
//  WebSocketHandshakeResponseErrorProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/9/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The websocket handshake response processor. Implements the error handling.
 */
struct WebSocketHandshakeResponseErrorProcessor: ResponseProcessing {

    /**
     Specific errors associated with websocket upgrade handshake
     */
    enum HandshakeError: Error {
        /// The handshake failed because a header field in the response does not match expectations. The name of the failing header field is associated with the case
        case handshakeFieldError(String)

        /// The handshake failed with an http error. The status code for the error is associated with the enum case
        case statusCodeError(HTTPStatus)

        /// The handshake response does not contain all expected header fields. The remote host might not support websockets.
        case unrecognizedHeader
        
        /// The data being processed if on unrecognized type
        case unrecognizedResponse
    }

    /// The accept key the handshake request has sent as the value for the header field `Sec-WebSocket-Key`
    let acceptKey: String
    
    /// A list of secondary websocket protocols that are acceptable for the client
    let protocols: [String]
    
    /**
     Designated initializer
     - parameter key: The websocket handshake security key to expect
     - parameter protocols: The expected set of websocket protocols. The default value is an empty array. At least one of the protocols - if provided - has to be present in the response to pass validation. This field is only validated if at least one protocol is specified here.
     */
    init(accepting key: String, protocols: [String] = []) {
        acceptKey = key
        self.protocols = protocols
    }

    /// The expected key in the handshake response for the header field `Sec-WebSocket-Key`
    private var expectedKey: String? {
        return (acceptKey + Constants.WebSocket.HandshakeKeySuffix).data(using: .utf8)?.sha1().base64EncodedString()
    }

    /// Validates the header fields of the handshake response
    /// - parameter header: The header fields in the handshake response
    /// - returns: Any potential error as a result of the validation.
    private func validate(header fields: [AnyHashable: Any]?) -> Error? {
        guard let headerFields = fields as? [String: String] else { return HandshakeError.unrecognizedHeader }
        guard headerFields["sec-websocket-accept"] == expectedKey else { return HandshakeError.handshakeFieldError("sec-websocket-accept") }
        
        let returnedSetOfWebsocketProtocols = headerFields["Sec-WebSocket-Protocol"].map { $0.components(separatedBy: ",") }.map { Set($0) }
        
        if protocols.count > 0, returnedSetOfWebsocketProtocols?.intersection(Set(protocols)).count == 0 {
            return HandshakeError.handshakeFieldError("Sec-WebSocket-Protocol")
        }
        
        return nil
    }

    func process(result processableResult: Processable, completion: ((Processable) -> Void)?) {
        var error: Error? = nil
        guard let result = processableResult as? ProcessableResponse else {
            completion?(processableResult.failing(becauseOf: HandshakeError.unrecognizedResponse))
            return
        }
        
        error = validate(header: result.response?.allHeaderFields)

        if error == nil, let code = result.status, code != .switchingProtocols {
            error = HandshakeError.statusCodeError(code)
        }

        if let error = error {
            completion?(processableResult.failing(becauseOf: error))
        } else {
            completion?(processableResult)
        }
    }
}
