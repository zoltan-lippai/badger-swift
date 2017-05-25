//
//  WebService+Downloads.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/18/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension WebService {
    /**
     Convenience function to download and expose the raw data from a remote endpoint URL
     - parameter asset: The URL of the remote endpoint
     - parameter completion: An asynchronously invoked completion handler that will expose the data downloaded if the call was successful.
     - parameter data: The downloade data if the operation was successful
     - returns: A cancelation handle to interrupt the operation if necessary. Can be discarded.
     */
    @discardableResult open func download(asset from: URL, completion: @escaping (_ data: Data?) -> Void) -> Cancelable? {
        return engine.process(task: EndPoint(template: from.absoluteString).task) { (result: Processable) in
            completion(result.data)
        }
    }
    
    /**
     Convenience function download and expose an image.
     - parameter asset: The URL of the remote endpoint
     - parameter completion: An asynchronously invoked completion handler that will expose the `UIImage` downloaded if the operation was successful.
     - parameter image: The downloaded image if the operation was successful
     - returns: A cancelation handle to interrupt the operation if necessary. Can be discarded.
     */
    @discardableResult open func download(image from: URL, completion: @escaping (_ image: UIImage?) -> Void) -> Cancelable? {
        return engine.process(task: EndPoint(template: from.absoluteString).task.adding(ImageProcessor()), completion: completion)
    }
    
    /**
     Convenience function download and expose a serializable object.
     - parameter asset: The URL of the remote endpoint
     - parameter completion: An asynchronously invoked completion handler that will expose the `Serializable` object downloaded if the operation was successful.
     - parameter serializable: The serialized native object from the downloaded data, if the download and the JSON conversion were successful
     - returns: A cancelation handle to interrupt the operation if necessary. Can be discarded.
     */
    @discardableResult open func download<T>(jsonResponse fromEndPoint: EndPoint, expected type: T.Type? = nil, completion: @escaping (_ serializable: T?) -> Void) -> Cancelable? where T: Serializable {
        return engine.process(task: fromEndPoint.task.adding(JSONProcessor(type: type)), completion: completion)
    }
}
