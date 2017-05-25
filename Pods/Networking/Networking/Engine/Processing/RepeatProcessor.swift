//
//  RepeatProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/1/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Allows intercepting a network response to repeat the original request if necessary.
 The `predicate` of the processor should return whether or not the request should be repeated, but should also contain the work necessary that allows the repeated request to pass successfully to avoid further repetitions. Returning false will cause the processor to allow the response process to continue normally.
 */
public struct RepeatProcessor: ResponseProcessing {

    /// The predicate block of the processor. Should contain the necessary maintenance work to allow the repeated request to succeed without the same problem occurring that triggered this processor in the first place. In the end it should return `true` to have the engine repeat the original call, or `false` to allow the response to return normally.
    public let predicate: (Evaluable) -> Bool

    /**
     Designated initializer, initialize with a predicate block as necessary. See the description of the `predicate` above.
     */
    public init(predicate: @escaping (Evaluable) -> Bool) {
        self.predicate = predicate
    }

    public func process(result: Processable, completion: ((Processable) -> Void)?) {
        if let result = result as? Evaluable, predicate(result) {
            completion?(result.repeated())
        } else {
            completion?(result)
        }
    }
}
