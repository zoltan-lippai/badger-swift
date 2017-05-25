//
//  ImageProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/28/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation
import UIKit

/**
 The image processor to create valid `UIImage` objects from the downloaded data.
 */
public struct ImageProcessor: ResponseProcessing {

    /**
     Returns a network operation with the 'translated' property set to a `UIImage` object constructed from the downloaded data
     - parameter result: The network operation result
     - returns: A new network operation result where the 'translated' property holds the `UIImage` created from the downloaded data if the conversion is possible
     */
    public func process(result: Processable, completion: ((Processable) -> Void)?) {
        completion?(result.data.flatMap { UIImage(data: $0) }.map { result.translating(to: $0) } ?? result)
    }
}
