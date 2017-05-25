//
//  RequestProcessing.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes the behavior of a network engine.
 */
public protocol RequestProcessing {

    /**
     Processes a request and invokes a completion closure with the data/result downloaded. The completion by default is called asynchronously.
     - parameter task: A requestable task to construct the `URLRequest`
     - parameter completion: A callback closure invoked asynchronously once the network operation has been completed.
     - returns: A cancelable handle to interrupt the network operation. Can be discarded.
     */
    @discardableResult func process(task: Requestable?, completion: ((Processable) -> Void)?) -> Cancelable?

    /**
     Cancels all ongoing network operations of the engine.
     */
    func cancelAll()

    /**
     Processes a request and invokes a completion closure with the data/result downloaded. The completion by default is called asynchronously.
     - parameter task: A requestable task to construct the `URLRequest`
     - parameter completion: A callback closure invoked asynchronously once the network operation has been completed. The argument of the closure will be converted into the expected result type from the downloaded data.
     - returns: A cancelable handle to interrupt the network operation. Can be discarded.
     
     
     Note: this implementation is automatically suppored by the protocol if the task also hosts the response processors necessary to perform the data conversion. Otherwise, this method invokes the completion closure with a `nil` argument.
     */
    @discardableResult func process<T>(task: Requestable?, completion: ((T?) -> Void)?) -> Cancelable?
}

extension RequestProcessing {
    // Providing default argument for the optional closure
    @discardableResult public func process(task: Requestable?, completion: ((Processable) -> Void)? = nil) -> Cancelable? {
        return process(task: task, completion: completion)
    }

    // Automatic support for data conversion, assuming the task's last response processor is capable of doing so
    @discardableResult public func process<T>(task: Requestable?, completion: ((T?) -> Void)? = nil) -> Cancelable? {
        if let host = task as? ProcessorHosting, let lastProcessor = host.processors.last {
            return process(task: task) { completion?(lastProcessor.finalize(result: $0)) }
        } else {
            return process(task: task) { _ in completion?(nil) }
        }
    }
}
