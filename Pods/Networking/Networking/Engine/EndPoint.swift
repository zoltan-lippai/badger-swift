//
//  EndPoint.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 The potential HTTP methods
 */
public enum HTTPMethod: String {
    case get
    case head
    case put
    case delete
    case options
    case trace
    case post
    case connect

    /**
     Converts an HTTP method case into an uppercased string as expected by the `URLRequest`'s `httpMethod` property
     */
    var string: String {
        return rawValue.uppercased()
    }
}

/**
 Describes an endpoint. Endpoints are considered a mapping or a factory between the voliatile pieces of data required for a particular network call and the requestable instance required by the network engine.
 
 The EndPoint will return a *stub* request through its factory method `request()`. The resulting `Requestable` object can be further specified and concretized through the builder pattern by gradually adding all data as necessary.
 */
public struct EndPoint: ProcessorHosting {

    /// The url path template for the endpoint. If any path components of this path are volatile, then bracket it with `%` signs to mark it as candidate for substitution
    public var urlPathTemplate: String

    /// The http method to call the remote endpoint
    public var httpMethod: HTTPMethod

    /// The custom header fields required for this call
    public var headerFields: [HeaderItem]

    /// The list of required query fields for the network call the caller is expected to provide for a valid request to be formed
    public var requiredQueryFields: [String]

    /// The list of body field names for the network call the caller is expected to provide for a valid request to be formed. This assumes the body is a JSON dictionary converted into JSON string and data when the request is fired. This array lists the required keys of this dictionary.
    public var requiredBodyFields: [String]

    /// Returns the list of path components that needs to be substituted before a valid network request can be formed. All path components in the `urlPathTemplate` bracketed with `%` signs are listed here.
    public var requiredPathComponents: [String] {
        var components = [String]()
        
        let regex = try? NSRegularExpression(pattern: "\\%(.*?)\\%", options: [.allowCommentsAndWhitespace, .caseInsensitive])
        
        let fullRange = NSRange(location: 0, length: urlPathTemplate.lengthOfBytes(using: .utf8))
        
        if let matches = regex?.matches(in: urlPathTemplate, options: [.reportCompletion], range: fullRange) {
            for aMatch in matches where aMatch.numberOfRanges > 1 {
                for rangeIndex in 1..<aMatch.numberOfRanges {
                    let aRange = aMatch.rangeAt(rangeIndex)
                    components.append((urlPathTemplate as NSString).substring(with: aRange))
                }
            }
        }
        
        return components.map { "%\($0)%" }
    }

    /// List of response processors to attach to every request created from this `EndPoint`
    public var processors = [ResponseProcessing]()

    /**
     Designated initializer.
     - parameters:
     - template: The url path template
     - method: The http method
     - fields: The header fields set for this call. The default value is an empty array.
     - queryFields: The list of mandatory query parameter names. The default value is an empty array.
     - bodyFields: The list of mandatory body field names. The default value is an empty array.
     */
    public init(template: String, method: HTTPMethod = .get, fields: [HeaderItem] = [], queryFields: [String] = [], bodyFields: [String] = [], processors: [ResponseProcessing] = []) {
        urlPathTemplate = template
        httpMethod = method
        headerFields = fields
        requiredBodyFields = bodyFields
        requiredQueryFields = queryFields
        self.processors = processors
    }

    /**
     Constructs a request from the endpoint.
     - returns: A `Request` structure with the specifications of this endpoint set. The request can - and should - be further customized by adding the required body/query/pathtemplate fields to hold the specific data required for this network call.
     */
    public var task: Requestable & Buildable {
        return Request(urlString: urlPathTemplate, method: httpMethod)
            .adding(self)
            .adding(headerFields)
            .adding(processors)
    }
}
