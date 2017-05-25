//
//  Buildable.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes the behavior of an object to follow the builder pattern
 */
public protocol Buildable {

    /**
     Appends/sets/updates a piece of data to the existing instance and returns a new instance with the data incorporated - assuming the data type is supported by the receiver.
     - parameter data: The data to be added to the instance
     - returns: A new instance of the same type extended with the new piece of data
     */
    func adding(_ data: Any) -> Self

    /**
     Appends/sets/updates a piece of data to the existing instance and returns a new instance with the data incorporated - assuming the data type is supported by the receiver.
     - parameter data: An optional piece of data to be added to the instance. If the data is `nil`, no action is taken.
     - returns: A new instance of the same type extended with the new piece of data, if the data was not `nil`. Otherwise returns the receiver.
     */
    func adding(optional data: Any?) -> Self
}

extension Buildable {

    public func adding(optional data: Any?) -> Self {
        return data.map { adding($0) } ?? self
    }
}
