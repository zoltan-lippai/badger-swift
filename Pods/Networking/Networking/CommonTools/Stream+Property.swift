//
//  Stream+Property.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/10/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension Stream {
    /**
     Gets or sets the required/expected security level for the stream communication when connecting to a socket
     
     The property is a computed property over the generic `Stream` methods `property(forKey:)` and `setProperty(_:forKey:)` with the key fixed as `.socketSecurityLevelKey`. Thus this property only makes sense for `Stream`s connecting to a network socket. The getter only returns non-`nil` value if this propery was previously set to a valid security level.
     */
    var socketSecurity: StreamSocketSecurityLevel? {
        get {
            return property(forKey: .socketSecurityLevelKey) as? StreamSocketSecurityLevel
        }
        set(newValue) {
            setProperty(newValue, forKey: .socketSecurityLevelKey)
        }
    }
    
    /**
     Sets the network service type for the stream communication when connecting to a socket

     The property is a computed property over the generic `Stream` methods `property(forKey:)` and `setProperty(_:forKey:)` with the key fixed as `.networkServiceType`. Thus this property only makes sense for `Stream`s connecting to a network socket. The getter only returns non-`nil` value if this propery was previously set to a valid network service type.
     */
    var networkServiceType: StreamNetworkServiceTypeValue? {
        get {
            return property(forKey: .networkServiceType) as? StreamNetworkServiceTypeValue
        }
        set(newValue) {
            setProperty(newValue, forKey: .networkServiceType)
        }
    }
}

extension InputStream {
    
    /**
     Returns the stream event handler if one is appointed for the receiver
     
     This property is an optional cast of the `Stream`'s `delegate` to `InputStreamEventHandler` instance with the assumption the streams were opened with a delegate of this type assigned.
     */
    var eventHandler: InputStreamEventHandler? {
        return delegate as? InputStreamEventHandler
    }
}

extension OutputStream {
    
    /**
     Returns the stream event handler if one is appointed for the receiver
     
     This property is an optional cast of the `Stream`'s `delegate` to `OutputStreamEventHandler` instance with the assumption the streams were opened with a delegate of this type assigned.
     */
    var eventHandler: OutputStreamEventHandler? {
        return delegate as? OutputStreamEventHandler
    }
}
