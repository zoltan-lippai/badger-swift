//
//  StreamDispatcher.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/19/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A stream dispatcher reads the input stream and writes to the output stream of an established websocket connection
 */
class StreamDispatcher: StreamDispatching, StreamDataReassembling, Cancelable {
    
    /**
     A collection of response processor chains that have a chance to process the incoming data
     */
    private var readFlows = [[ResponseProcessing]]()
    
    /**
     The stream connection
     */
    var connection: StreamConnection?
    
    /// A temporary array to keep the decoder(s) alive while reading successive frames from the stream
    var decoders = [WebSocketDataDecoder]()
    
    var isExpectingWebsocketDataFrames = false
    
    /// The dispatcher queue to dispatch read data from the input stream
    private let dispatcherQueue = DispatchQueue(label: "com.doordash.networking.websocket.IStreamDispatcherQueue")
    
    /**
     Initializes the dispatcher with the stream connection
     - parameter connection: The websocket connection
     */
    required init(connection: StreamConnection) {
        self.connection = connection
        
        connection.inputStream?.eventHandler?.readHandler = { [weak self] aStream in
            aStream.dispatchQueue?.async {
                self?.connectionHasBytesAvailable()
            }
        }
    }
    
    /// Adds a new processing flow to deal with data coming from the input stream
    func register(dataProcessors: [ResponseProcessing]) {
        readFlows.append(dataProcessors)
    }
    
    /// Writes data to the output stream. The dispatcher will slice it up into websocket dataframes and schedule them into the output stream
    /// - parameter data: The data to be written
    func feed(data: Data) {
        WebSocketDataFrame.frames(from: data).forEach { aFrame in
            self.feed(aFrame)
        }
    }
    
    func feed(_ frame: WebSocketDataFrame) {
        guard let oStream = connection?.outputStream, oStream.hasSpaceAvailable == true else { return }
        
        oStream.dispatchQueue?.async {
            _ = oStream.write(frame.encodedDataFrame.bytes, maxLength: frame.encodedDataFrame.count)
        }
    }
    
    /// Starts reading data from the input stream until there are no more data left. This method is invoked on the input stream's dispatch queue
    func connectionHasBytesAvailable() {
        let data = readInput()
        if self.isExpectingWebsocketDataFrames {
            self.decode(data)
        } else {
            self.dispatch(response: StreamData(data: data))
        }
    }
    
    /// Reads the input stream if it was bytes available and returns the data read
    /// - returns: The data object from the stream. The algorithm will read until there are bytes available
    func readInput() -> Data {
        guard let input = connection?.inputStream, input.hasBytesAvailable else { return Data() }
        let max = WebSocketDataFrameSize.size3k.rawValue // read 3kbyte at once
        var data = [Octet]()
        var count = 0
        repeat {
            var buffer = [Octet](repeatElement(0, count: max))
            count = input.read(&buffer, maxLength: max)
            data.append(contentsOf: buffer[0..<count])
        } while count == max && input.hasBytesAvailable
        
        return count > 0 ? Data(data) : Data()
    }
    
    /// Dispatches the reassembled stream data to the registered response processor flows
    /// - parameter response: The stream data reconstructed from the input stream
    func dispatch(response: StreamData) {
        dispatch(response: response, on: dispatcherQueue, to: readFlows)
    }
    
    /// Sends a close frame and disconnects the stream
    func cancel() {
        feed(.close)
        connection?.disconnect()
        connection = nil
    }
}
