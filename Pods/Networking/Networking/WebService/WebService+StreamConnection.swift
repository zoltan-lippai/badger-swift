//
//  WebService+StreamConnection.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/18/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension WebService: WebSocketConnecting {
    
    /// The userinfo key for the `WebServiceFailedWebSocketHandshake` for the error causing the failure
    public static let FailedWebSocketHandshakeErrorKey = "WebServiceFailedWebSocketHandshakeFailKey"

    /**
     Instructs the `WebService` to open the websocket connection. The call does nothing (and returns `nil`) if the connection is already there.
      - parameter origin: The origin for the websocket connection, e.g. the host name including the url scheme, and optionally the connection's port
      - parameter path: The path to the handshake resource on the host
      - parameter port: The port to connect on
     */
    open func openWebSocket(to origin: String, path: String = "", port: Constants.Port = .secure) {
        var components = URLComponents(string: origin)
        components?.port = port.port
        guard let origin = components?.origin, var task = handshakeEndpoint(to: origin)?.task, let host = components?.host else { return }
        task = task
            .adding(["path": path])

        var connection = StreamConnection(host: host, port: port)
        connection.connect()
        
        if connection.openStreams() != nil {
            return
        }
        
        let processors = (task as? ProcessorHosting)?.processors ?? []
        
        dispatcher = StreamDispatcher(connection: connection)
        dispatcher?.register(dataProcessors: [StreamHandshakeProcessor(webService: self, handshake: (components?.url)!, processors: processors)])
        performHandshake(on: connection, handshake: task)
    }
    
    /**
     Registers an array of response processors (e.g. a processing flow) for stream data reading. The registered flows will be kept around until the stream connection is open, and given a chance to react to all data packets read  from the input stream from a websocket connection
     - parameter flow: The array of `ResponseProcessing` objects to process a data packet read from the input stream of a websocket connection. The data packet is scheduled for the processors on its own dispatch queue, and the data is fully reassembled before the flow interacts with it.
     */
    open func register(streamReading flow: [ResponseProcessing]) {
        dispatcher?.register(dataProcessors: flow)
    }

    /**
     Registers `.hasBytesAvailable` and `.hasSpaceAvailable` event handlers for the stream connection provided. The action handlers translate the message to the stream dispatcher. The dispatcher is created in this call and will keep a strong reference to the stream connection while kept alive.
     - parameter streamConnection: The stream connection established
     */
    private func addDispatcher(to streamConnection: StreamConnection) {
        dispatcher = StreamDispatcher(connection: streamConnection)
    }
    
    /// Invoked when the websocket connection has successfully opened. Fires a notification for interested subscribers
    func didOpenWebSocketStreams() {
        // replacing handshake dispather with data dispatcher
        guard let connection = dispatcher?.connection else { return }
        let newDispatcher = StreamDispatcher(connection: connection)
        newDispatcher.isExpectingWebsocketDataFrames = true
        dispatcher = newDispatcher
        dispatcher?.connection?.inputStream?.delegate = dispatcher?.connection?.inputHandler!
        dispatcher?.connection?.outputStream?.delegate = dispatcher?.connection?.outputHandler!
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .WebServiceOpenedWebSocket, object: self)
        }
    }
    
    /// Invoked when the websocket handshake failed with error. Fires a notification for interested subscribers.
    func didFailWebSocketHandshake(with error: Error) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .WebServiceFailedWebSocketHandshake, object: self, userInfo: [WebService.FailedWebSocketHandshakeErrorKey: error])
        }
    }
}

extension Notification.Name {
    /**
     A notification fired when the webservice connection is established but before the streams have confirmed space or bytes available
     
     The `object` associated with the notification is the `WebService` instance established the connection. The notification's `userInfo` is `nil`.
     */
    public static let WebServiceOpenedWebSocket = Notification.Name(rawValue: "WebServiceOpenedWebSocket")
    
    /**
     A notification fired when the webservice handshake failed
     
     The `object` associated with the notification is the `WebService` instance established the connection. The `userInfo` contains the error occurred for the key `WebService.FailedWebSocketHandshakeErrorKey`
     */
    public static let WebServiceFailedWebSocketHandshake = Notification.Name(rawValue: "WebServiceFailedWebSocketHandshake")
}
