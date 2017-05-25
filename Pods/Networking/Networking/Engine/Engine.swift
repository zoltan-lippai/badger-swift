//
//  Engine.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The network enginte implementation of the framework. The engine works with `URLSessions` and related data tasks. The cancelable operation handles are the data tasks performing the network operations cast as `Cancelable`.
 */
public struct Engine: Cancelable {

    /// The `URLSession` of the engine
    fileprivate var session: URLSession

    /// The session configuration object
    fileprivate var config: URLSessionConfiguration

    /// The set of running tasks. The hashtable holds onto the tasks with `weakMemory` specification, deallocating tasks are automatically removed from this collection.
    fileprivate var runningTasks = NSHashTable<URLSessionTask>(options: .weakMemory)

    /// The set of required response processors to adjust/inspect the network response per the application's requirements. These processors are applied to all network response acquired through this engine.
    fileprivate var responseProcessors: [ResponseProcessing] = [HostedProcessor()]

    /**
     Designated initializer. Initialize it with a set of mandatory headers which will be appended to all network requests
     - parameter headers: The array of mandator header items. The default value is an empty array.
     */
    public init(mandatory headers: [HeaderItem] = []) {
        config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = headers.allHeaderFields
        session = URLSession(configuration: config)
    }

    /**
     Cancels all running operations.
     */
    public func cancelAll() {
        runningTasks.allObjects.forEach { $0.cancel() }
        runningTasks.removeAllObjects()
    }

    /**
     Shuts down the engine and invalidates the `URLSession`.
     */
    public func cancel() {
        cancelAll()
        session.invalidateAndCancel()
    }
}

extension Engine: RequestProcessing {

    @discardableResult public func process(task: Requestable?, completion: ((Processable) -> Void)?) -> Cancelable? {
        guard let task = task, let request = task.request else { return nil }

        let responseProcessors = self.responseProcessors

        let dataTask = session.dataTask(with: request) { (data, response, error) in
            let result = OperationResult(with: response, data: data, error: error, request: task)
            responseProcessors.map {ResponseProcessorWrapper(processor: $0) }.forAsync(iterateWith: result) {
               CallbackProcessor(engine: self).process(result: $0, completion: completion)
            }
        }

        runningTasks.add(dataTask)
        dataTask.resume()
        return dataTask
    }
}
