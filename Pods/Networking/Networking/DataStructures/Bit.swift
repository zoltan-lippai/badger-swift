//
//  Bit.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/10/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Represents a single bit. Can be expressed as a boolean literal.
 */
enum Bit: ExpressibleByBooleanLiteral {

    /// The high state
    case high

    /// The low state
    case low

    init(booleanLiteral value: Bool) {
        self = value ? .high : .low
    }

    /// Initializes the bit iwth a boolean `true` or `false` value corresponding to `high` and `low` respectively.
    init(_ value: Bool) {
        self = value ? .high : .low
    }
}

/**
 A bit index representing bit positions within a single byte
 */
enum BitIndex: UInt8, ExpressibleByIntegerLiteral, Comparable, Strideable {
    typealias Stride = UInt8.Stride

    func distance(to other: BitIndex) -> UInt8.Stride {
        return self.rawValue.distance(to: other.rawValue)
    }

    func advanced(by n: UInt8.Stride) -> BitIndex {
        return BitIndex(integerLiteral: self.rawValue.advanced(by: n))
    }

    /// The 0 indexed bit (e.g. value for 0 and 1 dec)
    case leastSignificant = 0
    case one
    case two
    case three
    case four
    case five
    case six
    case mostSignificant

    /// Represents all error cases where the bit was initialized with an integer value not in the interval of [0,7]
    case undefined

    /**
     Initializes the bit index with an integer literal value. Only values in the range [0:7] are supported. Values outside of these bounds will initialize the index to `undefined`. This is a more convenient way that failing the initializer that would require a lot of unwrapping
     - parameter value: The integer literal value to initialize the bit index with. Only values between (and including) 0 and 7 are supported.
     */
    init(integerLiteral value: UInt8) {
        switch value {
        case 0: self = .leastSignificant
        case 1: self = .one
        case 2: self = .two
        case 3: self = .three
        case 4: self = .four
        case 5: self = .five
        case 6: self = .six
        case 7: self = .mostSignificant
        default: self = .undefined
        }
    }

    static func < (lhs: BitIndex, rhs: BitIndex) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
