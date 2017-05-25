//
//  Serializable.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes an object's behavior that allows its construction from a JSON object
 */
public protocol Serializable {

    /**
     Initialzies the instance from a JSON object. The initializer can fail, if the JSON object fails validation.
     - parameter rawValue: The JSON object
     */
    init?(rawValue: Any)

    /**
     Returns a JSON object from the instance. Can be either the original JSON object or a newly converted one as necessary. The default implementation returns `nil`. Provide a specific implementation if the native to JSON conversion is required.
     */
    var rawValue: Any? { get }
}

extension Serializable {

    public var rawValue: Any? {
        return nil
    }

    /**
     Returns a collection (array) of `Self` type from the JSON response, if the JSON is an array of JSON objects of compatible type.
     - parameter rawValue: The JSON array
     - returns: An array of objects of the receiver's type. Any JSON object that cannot be converted to the receiver's type are omitted.
     
     This method is not part of the protocol so it does not have `Self` or `associatedtype` requirements and can be used as a type without generics or further specification. It is usually not expected to override this method or provide a different a implementation.
     */
    static public func collection(from rawValue: Any) -> [Self]? {
        return __array(from: rawValue)
    }

    static private func __array<T>(from rawValue: Any) -> [T]? where T: Serializable {
        return [T](rawValue: rawValue)
    }
}

extension Array where Element: Serializable {

    /**
     Transforms a JSON array of JSON objects into a serialized collection of `Serializable` objects. JSON objects in the collection that cannot be converted to the expected type are skipped.
     The initializer can fail if the supplied argument is not an `NSArray`-convertible JSON array.
     - parameter rawValue: A JSON array (`NSArray`-convertible) of JSON objects
     */
    public init?(rawValue: Any) {
        guard let array = rawValue as? NSArray else { return nil }
        self.init(array.flatMap { Element.init(rawValue: $0) })
    }

    /**
     Returns a JSON object from the instance. Can be either the original JSON object or a newly converted one as necessary. The default implementation returns `nil`. Provide a specific implementation if the native to JSON conversion is required.
     */
    public var rawValue: Any? {
        return flatMap { $0.rawValue }
    }
}
