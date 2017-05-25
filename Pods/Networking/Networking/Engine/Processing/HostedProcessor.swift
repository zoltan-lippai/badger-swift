//
//  HostedProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/28/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Applies the specific set of processors from the original request to the network operation result.
 This processor is a required response processor of the network engine
 */
struct HostedProcessor: ResponseProcessing {

    /**
     Applies the set of response processors that were attached to the network request.
     - parameter result: The original network operation result
     - returns: The processed network operation result
     */
    func process(result processableResult: Processable, completion: ((Processable) -> Void)?) {
        if let result = processableResult as? ProcessableResponse, let host = result.request as? ProcessorHosting {
            host.processors.map {ResponseProcessorWrapper(processor: $0) }.forAsync(iterateWith: result, completion: completion)
        } else {
            completion?(processableResult)
        }
    }
}
