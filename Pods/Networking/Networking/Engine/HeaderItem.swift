//
//  HeaderItem.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A name-value pair for a network request header item.
 */
public struct HeaderItem {

    /// The name for the header field
    public let name: String

    /// The value of the header field
    public let value: String
}

extension Array where Element ==HeaderItem {

    /**
     Returns a `[String: String]` dictionary from an array of `HeaderItem`s. The dictionary is compatible in format with the `URLRequest` API of the Foundation framework.
     */
    var allHeaderFields: [String: String] {
        return reduce([String: String]()) { partialResult, headerItem in
            var result = partialResult
            result[headerItem.name] = [result[headerItem.name], headerItem.value].flatMap { $0 }.joined(separator: ",")
            return result
        }
    }
}

extension HeaderItem {

    /**
     Returns the standard `application/json` content type header item
     */
    public static var JSONContentType: HeaderItem {
        return HeaderItem(name: "content-type", value: "application/json")
    }
}
