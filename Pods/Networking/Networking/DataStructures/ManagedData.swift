//
//  ManagedData.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/10/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A wrapper class around `Data` to allow byte and bit-wise manipulation and data reading
 */
final class ManagedData {

    /// The data buffer
    var buffer: [Octet]

    /**
     The designated initializer.
     - parameter data: The data to wrap and help to manipulate.
     */
    init(managing data: Data? = nil) {
        buffer = [Octet](data ?? Data())
    }

    /// Returns the byte count of the data
    var length: Int { return buffer.count }
}

// MARK: - Buffer extension
extension ManagedData {

    /**
     Appends an bit octet to the end of the data
     */
    func append(_ octet: Octet) {
        buffer.append(octet)
    }

    /**
     Appends an array of bit octets to the end of the data
     */
    func append(contentsOf octetArray: [Octet]) {
        buffer.append(contentsOf: octetArray)
    }
}

// MARK: - Bytewise getters and setters
extension ManagedData {

    /**
     Gets or sets the last bit octet of the data. If the data is empty the setter appends the new value instead of editing it.
     */
    var last: Octet {
        get {
            return self[buffer.count > 0 ? buffer.count - 1 : 0]
        }
        set(newOctet) {
            self[buffer.count > 0 ? buffer.count - 1 : 0] = newOctet
        }
    }

    /**
     Gets or sets the first bit octet of the data. If the data is empty, the setter appends the new value instead of editing it.
     */
    var first: Octet {
        get { return self[0] }
        set(newOctet) { self[0] = newOctet }
    }

    /**
     Returns or sets the bit octet at the given index. If the index was out of bounds for reading or writing, these methods append enough zero bytes to the data for the operation to succeed.
     */
    subscript(index: Int) -> Octet {
        get {
            if index < buffer.count {
                return Octet(integerLiteral: buffer[index])
            } else {
                buffer.append(contentsOf: [Octet](repeating: 0, count: index-buffer.count + 1))
                return Octet(integerLiteral: buffer[index])
            }
        }
        set(newValue) {
            if index < buffer.count {
                buffer[index] = newValue
            } else if index == buffer.count {
                buffer.append(newValue)
            } else {
                buffer.append(contentsOf: [Octet](repeating: 0, count: index-buffer.count))
                buffer.append(newValue)
            }
        }
    }

    /**
     Returns or sets the bit octet array for the range specified. For the setter, you have make sure the new value has the same number of elements to cover the entire range specified.
     */
    subscript(range: Range<Int>) -> [Octet] {
        get {
            if buffer.count <= range.upperBound {
                buffer.append(contentsOf: [Octet](repeating: 0, count: range.upperBound - buffer.count + 1))
            }
            return Array(buffer[range])
        }
        set(newValue) {
            if buffer.count <= range.upperBound {
                buffer.append(contentsOf: [Octet](repeating: 0, count: range.upperBound - buffer.count))
            }
            buffer[range] = ArraySlice(newValue)
        }
    }
}

// MARK: - Data transformation
extension ManagedData {

    /// Returns the wrapped bytes as data
    var data: Data {
        return Data(bytes: buffer)
    }
}
