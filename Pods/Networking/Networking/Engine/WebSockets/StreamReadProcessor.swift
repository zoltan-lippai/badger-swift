//
//  StreamReadProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/8/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A websocket processor allowing access to the most recently downloaded data from the input stream
 */
public struct StreamReadProcessor<CallbackArgumentType>: ResponseProcessing {

    /**
     Defines the callback notification queue type to read from the input stream
     */
    public enum NotificationQueueType {
        /// Specifies the main dispatch queue for notification callbacks
        case main

        /// Specifies a serial background dispatch queue for notification callbacks
        case serialBackground
    }

    /**
     Initializes the websocket processor with a queue type a stream reading handler. The handler is always invoked asynchronously relative to the queue processing the operation result.
     - parameter type: The queue type to use for the notification callbacks. The default value is `.main`, referring to the `.main` dispatch queue
     - parameter handler: The stream reading handler closure, invoked repeatedly whenever there is incoming data available on the input stream. *Note:* the provided callback's argument type defines the processor's `CallbackType` generic.
     - parameter data: The data read from the stream. If the processor's `CallbackType` is `Data` it invokes the handler with the raw data read. If the processor's `CallbackType` is a specific type, and the processor is preceeded by a data transformation processor/step to transform the data into that particular expected type, then the closure is invoked with an instance or value of that type.
     */
    public init(queue type: NotificationQueueType = .main, streamRead handler: @escaping (_ data: CallbackArgumentType) -> Void) {
        self.handler = handler

        switch type {
        case .main:
            messageQueue = .main
        case .serialBackground:
            messageQueue = DispatchQueue(label: "com.doordash.networking.websocket.messageQueue.\(UUID().hashValue)")
        }
    }

    public func process(result: Processable, completion: ((Processable) -> Void)?) {
        messageQueue.async {
            if let argument = self.callbackArgument(from: result) {
                self.sendCallback(with: argument)
            }
        }

        completion?(result)
    }

    private func callbackArgument(from operationResult: Processable) -> CallbackArgumentType? {
        return (isRawHandler ? operationResult.data : operationResult.translated) as? CallbackArgumentType
    }

    private func sendCallback(with data: CallbackArgumentType) {
        handler(data)
    }

    private let handler: (CallbackArgumentType) -> Void

    private var isRawHandler: Bool {
        return CallbackArgumentType.self is Data.Type
    }

    private let messageQueue: DispatchQueue
}
