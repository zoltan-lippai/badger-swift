//
//  StreamDataReassembling.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/19/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Isolates the pieces of functionality to decode, concatenate and finalize (fragmented) websocket dataframes read from an input stream
 */
protocol StreamDataReassembling: class {
    
    /**
     A array of ephemeral decoders that deal with the incoming data frames
     */
    var decoders: [WebSocketDataDecoder] { get set }
    
    /**
     Starts the data decoding process
     - parameter data: The data read from the stream
     */
    func decode(_ data: Data)
    
    /**
     Distributes the reassembled stream data
     - parameter response: The stream data reconstructed from the input stream
     */
    func dispatch(response: StreamData)
}

extension StreamDataReassembling {
    
    func decode(_ data: Data) {
        guard data.count >= 10 else { return }
        let frame = WebSocketDataFrame(received: data)
        let (index, decoder) = activeDecoder(for: frame)
        decoder.append(fragment: frame)
        
        if decoder.isFinalized {
            dispatch(response: decoder.streamData)
        }
        
        decoders.remove(at: index)
    }
    
    /**
     Returns the active decoder from the `decoders` array. If the frame is a new frame, it returns a newly allocated decoder, otherwise it returns the decoder the frame supposedly belongs to.
     - parameter frame: The websocket dataframe read from the input stream
     - returns: A tuple of `(Int, WebSocketDataDecoder)`. The integer represent the index of the decoder in the `decoders` array in case it needs to be removed when the frame is a final frame.
     */
    func activeDecoder(for frame: WebSocketDataFrame) -> (offset: Int, element: WebSocketDataDecoder) {
        if let activeDecoder = decoders.enumerated().first(where: { !$0.element.isFinalized && (!$0.element.isStarted == (frame.type == .continuation)) }) {
            return activeDecoder
        } else {
            let newDecoder = WebSocketDataDecoder()
            decoders.append(newDecoder)
            return (decoders.count - 1, newDecoder)
        }
    }
    
    /**
     Dispatches the response on the designated queue using the response processing flows.
     - parameter response: The stream data reassembled
     - parameter queue: The dispatch queue to use for message dispatch
     - parameter flows: The collection of reponse processor flows to process the data response
     */
    func dispatch(response: StreamData, on queue: DispatchQueue, to flows: [[ResponseProcessing]]) {
        flows.forEach { aFlow in
            queue.async {
                aFlow.map { ResponseProcessorWrapper(processor: $0) }.forAsync(iterateWith: response, completion: nil)
            }
        }
    }
}
