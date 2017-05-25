//
//  Cancelable.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Describes the behavior of an operation or process to be cancelable
 */
public protocol Cancelable {

    /**
     Cancels the conforming process, operation, or task
     */
    func cancel()
}

extension URLSessionDataTask: Cancelable { }
