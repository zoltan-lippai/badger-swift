//
//  WebService+StreamConnection.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/25/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension WebService: StreamInteraction {
    
    open func register(streamReading flow: [ResponseProcessing]) {
        connector?.register(streamReading: flow)
    }
    
    open func stream(_ data: Data) {
        connector?.stream(data)
    }
}
