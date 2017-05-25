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
class StreamDispatcher: StreamDataReassembling, Cancelable {
    
    /**
     A collection of response processor chains that have a chance to process the incoming data
     */
    private var readFlows = [[ResponseProcessing]]()
    
    /// A private dispatch queue to enqueue messages if the dispatcher is not yet associated with a connection. Once the connection is added, the enqueued messages are sent through.
    private var feedQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.doordash.networking.websocket.dispatcherFeederQueue")
        queue.suspend()
        return queue } ()
    
    /**
     The stream connection
     */
    var connection: StreamConnection? {
        didSet {
            connection?.inputStream?.eventHandler?.readHandler = { [weak self] aStream in
                aStream.dispatchQueue?.async {
                    self?.connectionHasBytesAvailable()
                }
            }
            
            if connection != nil {
                feedQueue.resume()
            }
        }
    }
    
    /// A temporary array to keep the decoder(s) alive while reading successive frames from the stream
    var decoders = [WebSocketDataDecoder]()
    
    /// The dispatcher queue to dispatch read data from the input stream
    private let dispatcherQueue = DispatchQueue(label: "com.doordash.networking.websocket.IStreamDispatcherQueue")
    
    /// Adds a new processing flow to deal with data coming from the input stream
    func register(dataProcessors: [ResponseProcessing]) {
        readFlows.append(dataProcessors)
    }
    
    /// Writes data to the output stream. The dispatcher will slice it up into websocket dataframes and schedule them into the output stream
    /// - parameter data: The data to be written
    ///
    /// The data is separated into individual websocket dataframes - if necessary, e.g. a single frame cannot contain all data
    ///
    /// The individual frames are written to the output stream on the stream's serial dispatch queue in the order they are created.
    func feed(data: Data) {
        WebSocketDataFrame.frames(from: data).forEach { aFrame in
            self.feed(aFrame)
        }
    }
    
    /**
     Feeds a single websocket data frame into the output stream
     - parameter frame: The frame to send to the output
     
     If the output stream does not exist, it has no space available, or it has not been scheduled to its own dispatch queue, this method does nothing.
     
     The data frame is written to the output stream on the stream's dispatch queue asynchronously. This is not a blocking call.
     
     The queue is expected to be set up as a serial background queue, and frames are written in the order they are fed into the dispatcher.
     */
    func feed(_ frame: WebSocketDataFrame) {
        if connection == nil {
            feedQueue.async { [weak self] in
                self?.__feed(frame)
            }
        } else {
            __feed(frame)
        }
    }
    
    private func __feed(_ frame: WebSocketDataFrame) {
        guard let oStream = connection?.outputStream, oStream.hasSpaceAvailable == true else { return }
        oStream.dispatchQueue?.async {
            _ = oStream.write(frame.encodedDataFrame.bytes, maxLength: frame.encodedDataFrame.count)
        }
    }
    
    /// Starts reading data from the input stream until there are no more data left. This method is invoked on the input stream's dispatch queue
    func connectionHasBytesAvailable() {
        if let data = connection?.inputStream?.readInput() {
            decode(data)
        }
    }
    
    /// Dispatches the reassembled stream data to the registered response processor flows
    /// - parameter response: The stream data reconstructed from the input stream
    func dispatch(response: StreamData) {
        if let type = response.translated as? WebSocketFrameType {
            switch type {
            case .close:
                cancel()
            case .ping:
                feed(.pong)
            case .binary, .text:
                dispatch(response: response.translating(to: nil), on: dispatcherQueue, to: readFlows)
            default:
                break
            }
        } else {
            dispatch(response: response, on: dispatcherQueue, to: readFlows)
        }
    }
    
    /// Sends a close frame and disconnects the stream
    func cancel() {
        feed(.close)
        connection?.disconnect()
        connection = nil
    }
}
