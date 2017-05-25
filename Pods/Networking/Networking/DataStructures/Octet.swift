//
//  Octet.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/10/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

internal typealias Octet = UInt8

// MARK: - Indexed subscripts - bitwise getters and setters
extension Octet {

    /**
     Sets or gets a specific bit in the byte
     */
    fileprivate subscript(index: UInt8) -> Bit {
        get { return Bit(self & (1 << index) == (1 << index)) }
        
        mutating set(newValue) {
            switch (newValue, self[index]) {
            case (Bit.high, Bit.low):
                self = self | 1 << index
            case (Bit.low, Bit.high):
                self = self & ~(1 << index)
            default:
                break
            }
        }
    }

    /**
     Sets or gets a specific bit in the byte
     */
    subscript(bitIndex: BitIndex) -> Bit {
        get {
            return self[bitIndex.rawValue]
        }
        set(newValue) {
            self[bitIndex.rawValue] = newValue
        }
    }

    /**
     Sets or gets a specific contiguous bit range from the byte as an integer. The bit range number representation always starts from 0, e.g. the bit range for bits 4 and 5 will still be in the range of [0,3], even though in the original byte these bits describe the orders of magnitude 16 and 32 respectively.
     */
    subscript(range: Range<Int>) -> UInt8 {
        get {
            var result = Octet(0)
            for index in 0..<range.count where self[UInt8(index+Int(range.lowerBound))] == .high {
                result += Octet(1 << index)
            }
            return result
        }
        set(newValue) {
            let addedValue = newValue << UInt8(range.lowerBound)
            self |= addedValue
        }
    }

    /**
     Sets or gets a specific contiguous bit range from the byte as an integer. The bit range number representation always starts from 0, e.g. the bit range for bits 4 and 5 will still be in the range of [0,3], even though in the original byte these bits describe the orders of magnitude 16 and 32 respectively.
     */
    subscript(range: Range<BitIndex>) -> UInt8 {
        get {
            var result = Octet(0)
            for index in 0..<range.count where self[index+range.lowerBound] == .high {
                result += Octet(1 << index)
            }
            return result
        }
        set(newValue) {
            let addedValue = newValue << range.lowerBound.rawValue
            self |= addedValue
        }
    }
}

// Mark: - Conversions
extension Octet {

    /// Returns a byte representation of a 64-bit integer value
    /// - parameter max: The maximum number of bytes to represent
    /// - parameter value: The integer value to represent as bytes
    /// - returns: An array of bytes containing 8 elements representing the integer
    static func bytes(of value: UInt64, magnitude: Int = 8) -> [Octet] {
        return magnitude > 0 ? [Octet(value >> (UInt64(magnitude - 1) * 8) & 0xff)] + bytes(of: value, magnitude: magnitude-1) : []
    }
    
    /// Returns a byte representation of a 64-bit integer value
    /// - parameter max: The maximum number of bytes to represent
    /// - parameter value: The integer value to represent as bytes
    /// - returns: An array of bytes containing 8 elements representing the integer
    static func bytes(of value: UInt16, magnitude: Int = 2) -> [Octet] {
        return magnitude > 0 ? [Octet(value >> (UInt16(magnitude - 1) * 8) & 0xff)] + bytes(of: value, magnitude: magnitude-1) : []
    }

    /// Returns a byte representation of a 64-bit integer value
    /// - parameter max: The maximum number of bytes to represent
    /// - parameter value: The integer value to represent as bytes
    /// - returns: An array of bytes containing 8 elements representing the integer
    static func bytes(of value: UInt32, magnitude: Int = 4) -> [Octet] {
        return magnitude > 0 ? [Octet(value >> (UInt32(magnitude - 1) * 8) & 0xff)] + bytes(of: value, magnitude: magnitude-1) : []
    }
}

extension Array where Element == Octet {
    
    /// Returns the integer representation of the `Octet` array assuming bigendian byte order
    var bigEndian: Int {
        return Array(reversed()).littleEndian
    }
    
    /// Returns the integer representation of the `Octet` array assuming littleendian byte order
    var littleEndian: Int {
        return enumerated().reduce(0) { $0 + (Int($1.element) << ($1.offset * 8)) }
    }
}
