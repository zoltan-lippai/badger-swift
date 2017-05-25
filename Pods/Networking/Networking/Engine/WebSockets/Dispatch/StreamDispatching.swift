//
//  StreamDispatching.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/19/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Dispatching objects decode, reassemble, and distribute data packets read from a connection's input stream, as well as encode, fragment, and feed data packets to a connection's output queue
 */
public protocol StreamDispatching {
    
    /**
     Initializes the dispatching service with a connection
     */
    init(connection: StreamConnection)
    
    /**
     Registers a data processor flow to process data responses read from the input stream
     */
    func register(dataProcessors: [ResponseProcessing])
    
    /**
     Writes data into the output stream. The data is fragmented into uniform sized frames if necessary
     */
    func feed(data: Data)
    
    /**
     Writes a single, prepared websocket data frame to the output stream
     */
    func feed(_ frame: WebSocketDataFrame)
    
    var connection: StreamConnection? { get }
}
