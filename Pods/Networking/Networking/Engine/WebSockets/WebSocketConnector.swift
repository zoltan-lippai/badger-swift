//
//  WebSocketConnector.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/18/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A concrete implementation of the `WebSocketConnecting` protocol
 */
open class WebSocketConnector: WebSocketConnecting, WebSocketHandshaking, StreamInteraction {
    
    public init() {
        // for visibility purposes
    }
    
    /// The connection
    open var connection: StreamConnection?
    
    /// The stream data dispatcher both for reading and writing
    var dispatcher = StreamDispatcher()
    
    open func openWebSocket(to origin: String, path: String = "", protocols: [String] = [], port: Constants.Port = .secure) {
        guard connection == nil else { return }
        do {
            try connection = performHandshake(to: origin + path, specifying: protocols, port: port) { (result) in
                if let error = result.error {
                    self.didFailWebSocketHandshake(with: error)
                } else {
                    self.didOpenWebSocketStreams()
                }
            }
        } catch let error {
            didFailWebSocketHandshake(with: error)
        }
    }
    
    /// Invoked when the websocket connection has successfully opened. Fires a notification for interested subscribers
    open func didOpenWebSocketStreams() {
        guard let connection = connection else { return }
        dispatcher.connection = connection
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .WebServiceOpenedWebSocket, object: self)
        }
    }
    
    /// Invoked when the websocket handshake failed with error. Fires a notification for interested subscribers.
    open func didFailWebSocketHandshake(with error: Error) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .WebServiceFailedWebSocketHandshake, object: self, userInfo: [Constants.FailedWebSocketHandshakeErrorKey: error])
        }
    }
    
    open func cancel() {
        dispatcher.cancel()
    }
    
    open func register(streamReading flow: [ResponseProcessing]) {
        dispatcher.register(dataProcessors: flow)
    }
    
    open func stream(_ data: Data) {
        dispatcher.feed(data: data)
    }
}
