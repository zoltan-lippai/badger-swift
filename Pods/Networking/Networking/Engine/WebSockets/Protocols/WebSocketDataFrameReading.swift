//
//  WebSocketDataFrame+Decoding.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/17/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

protocol WebSocketDataFrameReading {
    
    /// The FIN bit of the dataframe
    var finBit: Bit { get }
    
    /// The payload size of the data frame
    var payloadSize: Int { get }
    
    /// The mask bit of the dataframe
    var maskBit: Bit { get }
    
    /// The payload of the data frame
    ///
    /// Keep in mind the returned value is computed on-demand for masked payloads every time this property is read
    var payload: [UInt8] { get }
    
    /// Returns the data frame type. Assumes the managed data already contains a properly set frame type
    var frameType: WebSocketFrameType { get }
}

extension WebSocketDataFrameReading where Self: WebSocketMasking & WebSocketDataFraming {
    
    var finBit: Bit {
        return dataFrame[0][7]
    }
    
    var maskBit: Bit {
        return dataFrame[1][7]
    }
    
    var payloadSize: Int {
        let size: Int
        switch dataFrame[1][0..<7] {
        case let x where (0..<126).contains(x):
            size = Int(x)
        case 126:
            size = dataFrame[2..<4].bigEndian
        default:
            size = dataFrame[2..<10].bigEndian
        }

        return size
    }
    
    var payloadStartIndex: Int {
        let startIndex: Int
        
        switch dataFrame[1][0..<7] {
        case 0..<126:
            startIndex = 2
        case 126:
            startIndex = 4
        default:
            startIndex = 10
        }
        return (maskBit == .high ? 4 : 0) + startIndex
    }
    
    var payload: [Octet] {
        let lowIndex = payloadStartIndex
        let data = dataFrame[lowIndex..<payloadSize+lowIndex]
        return maskBit == .high ? mask(data, with: maskingKey) : data
    }
    
    var frameType: WebSocketFrameType {
        return WebSocketFrameType(rawValue: dataFrame[0][0..<4]) ?? .none
    }
}

extension WebSocketDataFrame: WebSocketDataFrameReading { }
