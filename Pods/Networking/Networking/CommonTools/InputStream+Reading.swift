//
//  InputStream+Reading.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/25/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension InputStream {
    
    /// Reads the input stream if it was bytes available and returns the data read
    /// - returns: The data object from the stream. The algorithm will read until there are bytes available.
    func readInput() -> Data? {
        guard hasBytesAvailable else { return nil }
        
        let max = WebSocketDataFrameSize.size3k.rawValue // read 3kbyte at once
        var data = [Octet]()
        var count = 0
        
        repeat {
            var buffer = [Octet](repeatElement(0, count: max))
            count = read(&buffer, maxLength: max)
            data.append(contentsOf: buffer[0..<count])
        } while count == max && hasBytesAvailable
        
        return count > 0 ? Data(data) : nil
    }
}
