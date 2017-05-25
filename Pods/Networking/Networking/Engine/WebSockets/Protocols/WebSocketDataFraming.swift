//
//  WebSocketDataFraming.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/10/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The type of the websocket frame
 */
enum WebSocketFrameType: UInt8 {
    /// continuation frame for fragmented data
    case continuation = 0
    /// text based data frame
    case text = 1
    /// binary data frame
    case binary = 2
    /// close frame
    case close = 8
    /// ping frame
    case ping = 9
    /// pong frame
    case pong = 10
    /// undefined value for invalid rawValues
    case none = 255
}

/**
 Describes the behavior how to construct a websocket data frame. See details at https://tools.ietf.org/html/rfc6455
 */
protocol WebSocketDataFraming {
    
    /// The managed data wrapping the actual data frame.
    var dataFrame: ManagedData { get }
    
    /// The data frame type
    var type: WebSocketFrameType { get }
    
    /// Tells if the data frame is the final frame in the stream
    var isFinal: Bool { get }
}

// MARK: - Websocket specification default implementation
extension WebSocketDataFraming where Self: WebSocketMasking & StrongMaskingKeyGeneration {

    /**
     Creates the frame per the websocket protocol requirements.
     - parameter applicationData: The application data
     - parameter type: The frame's type
     - parameter singleOrFinal: Whether the frame is final (last for fragmented data or not fragmented data)
     - returns: returns a managed data wrapping the dataframe
     */
    func createFrame(from applicationData: [Octet]) -> ManagedData {
        let frameData = ManagedData()
        // setting FIN bit
        frameData[0][7] = isFinal ? .high : .low
        
        // setting frame type bits
        frameData[0][0..<4] = type.rawValue

        // setting mask bit
        frameData[1][7] = .high

        // adding payload length
        append(size: applicationData.count, to: frameData)
 
        // fetching and appending mask key
        let currentMask = generateStrongMask()
        frameData.append(contentsOf: currentMask)
        
        // adding masked application data
        frameData.append(contentsOf: mask(applicationData, with: currentMask))
        
        // returning the frame
        return frameData
    }
    
    /**
     Appends the payload size information to the data frame as required by the websocket specifications.
     - parameter size: The size of the payload
     - parameter frameData: The managed data containing the data frame
     
     * If the size of the payload is less than 127 bytes, the payload size is written to the 2nd byte, bit range [1:7], network byte order (big endian)
     * If the size of the payload is 126 or 127 bytes, the payload size is written into the 3rd byte (big endian)
     * Otherwise if the size of the payload is written to the 3rd-10th bytes, network byte order (big endian)
     */
    private func append(size payloadSize: Int, to frameData: ManagedData) {

        switch payloadSize {
        case 0..<126:
            frameData[1][0..<7] = Octet(payloadSize)
        case 126..<Int(UInt16.max):
            frameData[1][0..<7] = 126
            frameData[2..<4] = Octet.bytes(of: UInt32(payloadSize)).reversed()
        default:
            frameData[1][0..<7] = 127
            frameData[2..<11] = Octet.bytes(of: UInt64(payloadSize)).reversed()
        }
    }
}
