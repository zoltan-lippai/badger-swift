//
//  StreamInteraction.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/25/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

public protocol StreamInteraction {
    
    func register(streamReading flow: [ResponseProcessing])
    
    func stream(_ data: Data)
}
