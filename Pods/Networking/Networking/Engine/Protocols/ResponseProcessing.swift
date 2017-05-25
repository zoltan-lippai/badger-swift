//
//  ResponseProcessing.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes the behavior of post-processing the raw data of a network response
 */
public protocol ResponseProcessing {
    /**
     Processes a response and data and *optionally* returns a new set of response and data
     - parameter result: The original network operation result
     - returns: Either the input result if the processor does not touch the response, or a new set of response and data as a result of processing
     */
    func process(result: Processable, completion: ((Processable) -> Void)?)

    /**
     Finalizes the network operation result and returns a specific native type possibly constructed from the data downloaded
     - parameter result: The network operation result
     - returns: The specific data packaged into its own native type
     */
    static func finalize<T>(result: Processable) -> T?

    /**
     Finalizes the network operation result and returns a specific native type possibly constructed from the data downloaded
     - parameter result: The network operation result
     - returns: The specific data packaged into its own native type
     */
    func finalize<T>(result: Processable) -> T?
}

extension ResponseProcessing {
    public static func finalize<T>(result: Processable) -> T? {
        return result.translated as? T
    }

    public func finalize<T>(result: Processable) -> T? {
        return type(of: self).finalize(result: result)
    }
}

/**
 Describes the behavior of an instance to hold onto a set of processors to post-process a network response.
 */
public protocol ProcessorHosting {

    /// An array of response processor instances
    var processors: [ResponseProcessing] { get }
}
