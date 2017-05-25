//
//  StrongMaskingKeyGeneration.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/17/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes the behavior to generate random mask octets from strong source of entropy
 */
protocol StrongMaskingKeyGeneration {
    
    /**
     Generates a new strong mask. The size of the returned array is `maskSize` elements
     */
    func generateStrongMask() -> [Octet]
    
    /**
     The size of the mask in bytes. The default value is 4 bytes, per the websocket specification requirements.
     */
    var maskSize: Int { get }
}

extension StrongMaskingKeyGeneration where Self: WebSocketMasking {
    
    func generateStrongMask() -> [Octet] {
        var mask = [Octet](count: maskSize, generator: 0)
        _ = SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<Octet>.size * maskSize, &mask)
        return mask
    }
    
    var maskSize: Int {
        return 4
    }
}
