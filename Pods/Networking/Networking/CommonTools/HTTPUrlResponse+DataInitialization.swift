//
//  HTTPUrlResponse+DataInitialization.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/25/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    /**
     Convenience initializer for reconstructing an HTTP url response from data that was read from an input stream
     - parameter url: The url of the response
     - parameter data: The data read from the stream
     */
    convenience init?(url: URL, data: Data) {
        let message = CFHTTPMessage.message(from: data)
        guard let headers = message.allHeaderFields, let code = message.statusCode else { return nil }
        self.init(url: url, statusCode: code, httpVersion: String(kCFHTTPVersion1_1), headerFields: headers)
    }
}
