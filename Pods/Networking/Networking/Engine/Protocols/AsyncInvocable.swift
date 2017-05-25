//
//  AsyncInvocable.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/18/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Instances conforming to this protocol can provide a dispatch queue and invoke a callback on that queue passing themselves as argument
 */
protocol AsyncInvocable {
    
    /**
     The dispatch queue to invoke the callback. If `nil`, the `.main` queue is used
     */
    var queue: DispatchQueue? { get }
    
    /**
     Invokes the provided callback, passing itself as argument
     - parameter completion: The block to invoke
     */
    func callback(completion: ((Self) -> Void)?)
}

extension AsyncInvocable {
    func callback(completion: ((Self) -> Void)?) {
        (queue ?? .main).async {
            completion?(self)
        }
    }
}
