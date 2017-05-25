//
//  HttpStatus.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/9/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The list of available status codes associated with `HTTPURLResponse` server responses supported in *HTML/1.1*
 */
public enum HTTPStatus: Int {
    case `continue`                     = 100
    case switchingProtocols             = 101

    case ok                             = 200
    case created                        = 201
    case accepted                       = 202
    case nonAuthoritiveInformation      = 203
    case noContent                      = 204
    case resetContent                   = 205
    case partialContent                 = 206

    case multipleChoices                = 300
    case movedPermanently               = 301
    case found                          = 302
    case seeOther                       = 303
    case notModified                    = 304
    case useProxy                       = 305
    case temporaryRedirect              = 307

    case badRequest                     = 400
    case unauthorized                   = 401
    case paymentRequired                = 402
    case forbidden                      = 403
    case notFount                       = 404
    case methodNotAllowed               = 405
    case notAcceptable                  = 406
    case proxyAuthenticationRequired    = 407
    case requestTimeout                 = 408
    case conflict                       = 409
    case gone                           = 410
    case lengthRequired                 = 411
    case preconditionFailed             = 412
    case requestEntityTooLarge          = 413
    case requestURITooLong              = 414
    case unsupportedMediaType           = 415
    case requestRangeNotSatisfiable     = 416
    case expectationFailed              = 417

    case internalServerError            = 500
    case notImplemented                 = 501
    case badGateway                     = 502
    case sericeUnavailable              = 503
    case gatewayTimeout                 = 504
    case httpVersionNotSupported        = 505

    init?(_ intValue: Int) {
        guard let `case` = HTTPStatus(rawValue: intValue) else { return nil }
        self = `case`
    }
    
    init?(_ intValue: Int?) {
        guard let value = intValue, let `case` = HTTPStatus(rawValue: value) else { return nil }
        self = `case`
    }

    static func == (lhs: HTTPStatus, rhs: Int) -> Bool {
        return lhs.rawValue == rhs
    }

    static func == (lhs: Int, rhs: HTTPStatus) -> Bool {
        return rhs == lhs
    }
}
