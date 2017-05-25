//
//  WebService.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation
import UIKit

/**
 The web servive class. A high level interface to access the network engine. The webservice exposes specialized functions and endpoints for ease of use of remote network calls and translates them into requestable objects for the network engine.
 */
open class WebService: Cancelable {

    /// The network engine
    open let engine: RequestProcessing & Cancelable
    
    /// The websocket connector
    open let connector: (WebSocketConnecting & StreamInteraction)?

    /// Designated initializer, sets the engine the webserice is supposed to cooperate with
    /// - parameter engine: the network engine
    public init(engine: RequestProcessing & Cancelable, websocket connector: (WebSocketConnecting & StreamInteraction)? = nil) {
        self.engine = engine
        self.connector = connector
    }
    
    deinit {
        cancel()
    }
    
    /**
     Shuts down the webservice: the engine, and any potential websocket connections. Only call this method if you want to dispose of the receiver, as the networks cannot be re-established again without creating a new instance of it. Deallocating the webservice implicitly calls `cancel()` on its `deinit`.
     */
    open func cancel() {
        engine.cancel()
        connector?.cancel()
    }
}
