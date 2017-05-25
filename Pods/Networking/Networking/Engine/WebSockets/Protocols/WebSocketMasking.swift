//
//  WebSocketMasking.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/11/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes the behavior of masking the application data of the websocket dataframe.
 */
protocol WebSocketMasking {
    
    /**
     Masks a data buffer with the provided mask
     - parameter buffer: The application data to mask
     - parameter mask: The mask bytes to use in masking
     - returns: The masked data buffer
     
     The websocket protocol requires the dataframes sent by the client to be masked with a `XOR` masking. The mask should be a 4-byte arbitrary mask that is different in every frame and is generated from a strong source of entropy.
     */
    func mask(_ buffer: [Octet], with mask: [Octet]) -> [Octet]
        
    /**
     Sets or gets the current masking key
     */
    var maskingKey: [Octet] { get set }
}

extension WebSocketMasking {
    func mask(_ buffer: [Octet], with mask: [Octet]) -> [Octet] {
        var result = [Octet]()
        let maskSize = mask.count
        
        // append payload data
        for byteIndex in 0..<buffer.count {
            let maskOctet = mask[byteIndex % maskSize]
            result.append(maskOctet ^ buffer[byteIndex])
        }
        
        return result
    }
}

extension WebSocketMasking where Self: WebSocketDataFraming {
    
    var maskingKey: [Octet] {
        get {
            return dataFrame[11..<15]
        }
        set(newValue) {
            dataFrame[11..<15] = newValue
        }
    }
}
