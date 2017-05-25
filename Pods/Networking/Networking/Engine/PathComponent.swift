//
//  PathComponent.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A template-value pair for a url path template
 */
public struct PathComponent {

    /// The name of the template field
    public let name: String

    /// The substitution value
    public let value: String
}
