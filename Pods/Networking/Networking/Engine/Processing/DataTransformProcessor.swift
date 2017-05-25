//
//  DataTransformProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/8/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Attempts to apply a data transformation to an operation result. You supply a transformation block `(Data) -> T?` to describe the transformation.
 */
public struct DataTransformProcessor<T>: ResponseProcessing {

    let transformationHandler: (Data) -> T?

    /**
     Initializes a new transformation processor
     - parameter transformationHandler: The code block to transform the `Data` downloaded into a specific type. If the closure returns `nil`, no action is taken. If the closure returns a valid value, the value is placed into the `translated` property of the operation result, and it is passed on to next processor.
     - parameter operationResultData: The data downloaded or streamed from the network operation
     The transformation handler is only invoked if a valid piece of data is available. Otherwise no action is taken.
     */
    init(transformationHandler: @escaping (_ operationResultData: Data) -> T?) {
        self.transformationHandler = transformationHandler
    }

    public func process(result: Processable, completion: ((Processable) -> Void)?) {
        if let data = result.data, let transformed = transformationHandler(data) {
            completion?(result.translating(to: transformed))
        } else {
            completion?(result)
        }
    }
}
