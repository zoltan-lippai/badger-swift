//
//  JSONProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/28/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The JSON processor of the network response
 */
public struct JSONProcessor<T>: ResponseProcessing where T: Serializable {

    private var expectedType: T.Type?

    public let isExpectingCollection: Bool

    public init(type: T.Type? = nil) {
        expectedType = type
        isExpectingCollection = false
    }

    public init(type: Array<T>.Type? = nil) {
        if let type = type {
            expectedType = type.Element.self
        } else {
            expectedType = nil
        }

        isExpectingCollection = true
    }

    /**
     Returns a network operation with the 'translated' property set to the expected JSON serializable type
     - parameter result: The network operation result
     - parameter completion: A completion handler for the network operation result where the 'translated' property holds the expected JSON serializable type if the conversion is possible
     */
    public func process(result: Processable, completion: ((Processable) -> Void)?) {
        if let data = result.data, let object = try? JSONSerialization.jsonObject(with: data, options: []) {
            completion?( result.translating(to: serialize(json: object) ?? object))
        } else {
            completion?(result)
        }
    }

    private func serialize(json object: Any) -> Any? {
        guard let serializableType = expectedType else { return nil }
        if isExpectingCollection {
            return serializableType.collection(from: object)
        } else {
            return serializableType.init(rawValue: object)
        }
    }
}
