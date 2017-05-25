//
//  ProcessableResponse.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/18/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Processable instances that belong to network responses
 */
public protocol ProcessableResponse: Evaluable {
    
    /**
     The original url response received
     */
    var response: HTTPURLResponse? { get }
    
    /**
     The http status from the response. The default implementation translates the status code of the `response` to `HTTPStatus` value
     */
    var status: HTTPStatus? { get }
    
    /**
     The original request for this response
     */
    var request: Requestable? { get }
}

extension ProcessableResponse {
    
    public var status: HTTPStatus? {
        return HTTPStatus(response?.statusCode)
    }
}
