//
//  Stream+DispatchQueueSchedule.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/10/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

protocol DispatchQueueSchedulable {
    /**
     Schedules the stream in the specified dispatch queue
     - parameter aDispatchQueue: The dispatch queue to use
     */
    func schedule(in aDispatchQueue: DispatchQueue)

    /**
     Returns the dispatch queue associated with the stream, if there was any
     */
    var dispatchQueue: DispatchQueue? { get }

    /**
     Removes the stream from the dispatch queue
     */
    func unscheduleFromDispatchQueue()
}

extension InputStream: DispatchQueueSchedulable {

    func schedule(in aDispatchQueue: DispatchQueue) {
        CFReadStreamSetDispatchQueue(self, aDispatchQueue)
    }

    var dispatchQueue: DispatchQueue? {
        // This is a bit explicit retrieval of an optional value in the getter, but the CoreFoundation function
        // is translated as an implicitly unwrapped optional, I'd prefer to play it safe
        if let queue = CFReadStreamCopyDispatchQueue(self) {
            return queue
        }
        return nil
    }

    func unscheduleFromDispatchQueue() {
        // despite the swift interface, the Core Foundation function accepts nil for its second argument
        CFReadStreamSetDispatchQueue(self, nil)
    }
}

extension OutputStream: DispatchQueueSchedulable {

    func schedule(in aDispatchQueue: DispatchQueue) {
        CFWriteStreamSetDispatchQueue(self, aDispatchQueue)
    }

    func unscheduleFromDispatchQueue() {
        // despite the swift interface, the Core Foundation function accepts nil for its second argument
        CFWriteStreamSetDispatchQueue(self, nil)
    }

    var dispatchQueue: DispatchQueue? {
        // This is a bit explicit retrieval of an optional value in the getter, 
        // but the CoreFoundation function is translated as an implicitly unwrapped optional, I'd prefer to play it safe
        if let queue = CFWriteStreamCopyDispatchQueue(self) {
            return queue
        }
        return nil
    }
}
