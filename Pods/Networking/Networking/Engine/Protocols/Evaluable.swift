//
//  Evaluable.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/18/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A more specific processable instance that can be dropped or repeated
 */
public protocol Evaluable: Processable {
    
    /**
     Whether this packet should be dropped due to some error
     */
    var shouldDrop: Bool { get }
    
    /**
     Whether the original request resulting in this packet should be repeated after correcting the errors causing this one to fail
     */
    var shouldRepeat: Bool { get }
    
    /**
     Returns if other processors should continue to evaluate this packet or exit early from the processing flow
     */
    var shouldContinueEvaluation: Bool { get }
    
    /**
     Copies the instance setting the `shouldDrop` value to `true`
     */
    func dropped() -> Self
    
    /**
     Copies the instance setting the `shouldRepeat` value to `true`
     */
    func repeated() -> Self
}

extension Evaluable {
    
    public var shouldContinueEvaluation: Bool {
        return !shouldDrop && !shouldRepeat
    }
}
