//
//  Requestable.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes the behavior of any type to work with the network engine. The only requirement prescribed here is the ability to return a `URLRequest`.
 */
public protocol Requestable {

    /**
     Returns the `URLRequest` for the network engine to start a network operation
     */
    var request: URLRequest? { get }
}
