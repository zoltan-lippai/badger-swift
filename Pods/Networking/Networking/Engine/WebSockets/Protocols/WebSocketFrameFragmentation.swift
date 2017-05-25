//
//  WebSocketFrameFragmentation.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/17/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The maximum size of the data frames for streaming application data
 */
public struct WebSocketDataFrameSize: RawRepresentable, ExpressibleByIntegerLiteral {
    public let rawValue: Int
    
    public init(integerLiteral value: Int) {
        rawValue = value
    }
    
    public init?(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// websocket dataframe with size of 1 kbyte
    public static let size1k: WebSocketDataFrameSize = 1024
    
    /// websocket dataframe with size of 3 kbytes
    public static let size3k: WebSocketDataFrameSize = 3072
}

/**
 Describes the behavior to split a source data into pre-defined sized websocket dataframes
 */
protocol WebSocketFrameFragmentation {
    /**
     Returns an array of data frames slicing up the original data into the specified packet sizes
     - parameter data: the data to stream in the websocket connection
     - parameter frameSize: The maximum size of payload in an individual frame
     - returns: The array of data frames to send in the websocket stream
     */
    static func frames(from data: Data, of frameSize: WebSocketDataFrameSize) -> [WebSocketDataFrame]
    
    /**
     Required initializer
     - parameter data: The data to or from the steam in the websocket connection
     - parameter type: The type of the data frame
     - parameter isFinal: whether the dataframe is a single one or the last one in a set of fragmanted dataframes
     */
    init(data: Data?, type: WebSocketFrameType?, isFinal: Bool?)
}

extension WebSocketFrameFragmentation where Self: WebSocketMasking & StrongMaskingKeyGeneration {

    static func frames(from data: Data, of frameSize: WebSocketDataFrameSize = .size3k) -> [Self] {
        var splits = [Self]()
        let payloadSize = frameSize.rawValue
        
        let numberOfFramesToCreate = data.count / payloadSize + 1
        
        // Generates the part type (binary or continuation) based on the index(argument) and number of frames
        let partType = { (index: Int) -> WebSocketFrameType in
            return index > 0 && numberOfFramesToCreate > 1 ? .continuation : .text
        }
        
        // Tells if the frame was final based on the index(argument) and the number of frames
        let isFinal = { (index: Int) -> Bool in
            return index == numberOfFramesToCreate - 1
        }
        
        for index in stride(from: 0, to: numberOfFramesToCreate, by: payloadSize) {
            // Constructing the byte indexes for the data slice
            let lowIndex = index * payloadSize
            let highIndex = min((index+1)*payloadSize - 1, data.count)
            // The data slice
            let part = Data(data[lowIndex..<highIndex])
            
            splits.append(Self(data: part, type: partType(index), isFinal: isFinal(index)))
        }
        
        return splits
    }
}
