//
//  WebSocketConnecting.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/25/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

public protocol WebSocketConnecting: Cancelable {
    /**
     Instructs the receiver to open the websocket connection. The call does nothing if the connection is already there.
     - parameter origin: The origin for the websocket connection, e.g. the host name including the url scheme, and optionally the connection's port
     - parameter path: The path to the handshake resource on the host
     - parameter protocols: The secondary websocket protocols to negotiate with the remote host
     - parameter port: The port to connect on
     */
    func openWebSocket(to origin: String, path: String, protocols: [String], port: Constants.Port)
}
