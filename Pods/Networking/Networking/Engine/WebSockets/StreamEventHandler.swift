//
//  StreamEventHandler.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/8/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The stream event handlers are responsible to interpret and react to delegation callbacks from the associated streams.
 
 *The event handlers are* `NSObject`*s as it is a requirement for implementing the* `StreamDelegate` *protocol.*
 */
class StreamEventHandler: NSObject, StreamDelegate {

    private typealias CallbackType = (Stream) -> Void
    private typealias Event = Stream.Event
    fileprivate var semaphore: DispatchSemaphore?
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.errorOccurred:
            semaphore?.signal()
        default:
            break
        }
    }
    
    /**
     Opens a stream. This is a blocking call until the stream is opened or an error occurs during the attempt.
     - parameter stream: The stream to open. The receiver will set itself as the stream's delegate
     - returns: The stream error that occurred during opening it, or `nil` if opening the stream was successful
     */
    func open(stream: Stream) -> Error? {
        stream.delegate = self
        stream.open()
        
        semaphore = DispatchSemaphore(value: 0)
        semaphore?.wait()
        
        return stream.streamError
    }
}

class InputStreamEventHandler: StreamEventHandler {
    
    var readHandler: ((InputStream) -> Void)?
    
    override func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        super.stream(aStream, handle: eventCode)
        
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            readHandler?(aStream as! InputStream)
        case Stream.Event.openCompleted:
            semaphore?.signal()
        default:
            break
        }
    }
}

class OutputStreamEventHandler: StreamEventHandler {
    override func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        super.stream(aStream, handle: eventCode)
        switch eventCode {
        case Stream.Event.hasSpaceAvailable:
            semaphore?.signal()
        default:
            break
        }
    }
}
