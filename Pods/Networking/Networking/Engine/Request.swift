//
//  Request.swift
//  Networking
//
//  Created by Zoltan Lippai on 4/27/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A concrete implementation of the `Requestable` instance. By default this is the data type returned from `EndPoint` instances.
 */
public struct Request: Requestable, ProcessorHosting, AsyncInvocable {
    /// The url string template used to construct the `URL`
    fileprivate var pathTemplate: String

    /// The query items of the URL
    fileprivate var queryItems: [URLQueryItem] = []

    /// The body of the `URLRequest`
    fileprivate var body = [String: Any]()

    /// The header fields set for this request
    fileprivate var headerFields = [HeaderItem]()

    /// The HTTP method
    var method: HTTPMethod

    /// The `EndPoint` that created this request if any
    fileprivate var endPoint: EndPoint?

    /// The list of response processors to post-process the downloaded data. The last of these processors is used to optionally automatically convert the response's data into a specific native object, assuming the last processor is capable of doing so.
    fileprivate(set)
    public var processors: [ResponseProcessing]

    /// The queue to use for delivering the response. The default value (when no queue is set) is the main queue.
    fileprivate(set)
    public var queue: DispatchQueue?

    /**
     Copies the request
     - returns: A copy of the request
     */
    fileprivate func copy() -> Request {
        var newRequest = Request(urlString: pathTemplate, method: method, processors: processors)
        newRequest.body = body
        newRequest.headerFields = headerFields
        newRequest.endPoint = endPoint
        newRequest.queue = queue
        newRequest.queryItems = queryItems
        return newRequest
    }
    
    /**
     Designated initialzer.
     - parameters:
     template: The path template of the request
     method: The HTTP method. The default value is `.get`
     processors: The array of response processors. The default value is an empty array.
     */
    public init(urlString template: String, method: HTTPMethod = .get, processors: [ResponseProcessing] = []) {
        pathTemplate = template
        self.method = method
        self.processors = processors
        queue = nil
    }

    /**
     Constructs a the `URLRequest` for the network engine.
     - returns: A valid `URLRequest` using all the data that was injected into this request, or `nil` if the request could not be constructed: e.g. the data validation failed.
     */
    public var request: URLRequest? {
        var components = URLComponents(string: pathTemplate)
        components?.queryItems = queryItems.count == 0 ? nil : queryItems // only append the query if there are elements. This avoids appending a extra `?` at the end without a query
        return components?.url.map {
            var request = URLRequest(url: $0)
            request.allHTTPHeaderFields = headerFields.allHeaderFields
            request.httpBody = body.count != 0 ? try? JSONSerialization.data(withJSONObject: body, options: []) : nil
            request.httpMethod = method.string
            return request
        }
    }
}

extension Request {
    fileprivate func adding(body: [String: Any]) -> Request {
        var product = copy()
        product.body = body
        return product
    }

    fileprivate func adding(body name: String, value: Any) -> Request {
        var product = copy()
        product.body[name] = value
        return product
    }

    fileprivate func adding(headerFields: [HeaderItem]) -> Request {
        var product = copy()
        product.headerFields += headerFields
        return product
    }

    fileprivate func adding(query item: URLQueryItem) -> Request {
        var product = copy()
        product.queryItems.append(item)
        return product
    }

    fileprivate func adding(path element: String, value: String) -> Request {
        var product = copy()
        product.pathTemplate = product.pathTemplate.replacingOccurrences(of: "%\(element)%", with: value)
        return product
    }

    fileprivate func adding(endPoint: EndPoint) -> Request {
        var product = copy()
        product.endPoint = endPoint
        return product
    }

    fileprivate func adding(processors: [ResponseProcessing]) -> Request {
        var product = copy()
        product.processors = self.processors + processors
        return product
    }

    fileprivate func adding(queue: DispatchQueue) -> Request {
        var product = copy()
        product.queue = queue
        return product
    }
}

extension Request: Buildable {

    // swiftlint:disable cyclomatic_complexity
    /**
     The builder pattern extension of the `Request`. Use this pattern to further specify the data required for the network call.
     - parameter data: The data to append to the network request.
     The supported data types are:
        * `URLQueryItem`: query item
        * `HeaderItem`: a single **or** array of header item(s)
        * `PathComponent`: for url path template substitution
        * `[String: Any]` dictionary: to parse each key-value pair in the dictionary as a `(String, Any)` tuple (*see below*)
        * `EndPoint`: to specify the host endpoint
        * `ResponseProcessing`: a single **or** array of response processor(s)
        * `(String, Any)` tuple: to *add* a key-value pair based on the `EndPoint` requirement mappings (body, query, or header field)
        * 'DispatchQueue': to specify the response dispatch queue if necessary. By default requests use the main queue for this purpose.
     
     - returns: A new network request with updated data, or the old one if the data specified was not matched
     */
    public func adding(_ data: Any) -> Request {
        switch data {
        case is URLQueryItem:
            return adding(query: data as! URLQueryItem)

        case is HeaderItem:
            return adding(headerFields: [data as! HeaderItem])

        case is [HeaderItem]:
            return adding(headerFields: data as! [HeaderItem])

        case is PathComponent:
            return adding(path: (data as! PathComponent).name, value: (data as!PathComponent).value)

        case is [String: Any]:
            return (data as! [String: Any]).reduce(self) { $0.0.adding(key: $0.1.key, value: $0.1.value) }

        case is EndPoint:
            return adding(endPoint: data as!EndPoint)

        case is (String, Any):
            return adding(key: (data as! (String, Any)).0, value: (data as! (String, Any)).1)

        case is ResponseProcessing:
            return adding(processors: [data as! ResponseProcessing])

        case is [ResponseProcessing]:
            return adding(processors: data as! [ResponseProcessing])

        case is DispatchQueue:
            return adding(queue: data as! DispatchQueue)

        default:
            return self
        }
    }

    private func adding(key: String, value: Any) -> Request {
        if endPoint!.requiredQueryFields.contains(key), let value = value as? String {

            return adding(query: URLQueryItem(name: key, value: value))

        } else if endPoint!.requiredPathComponents.contains("%\(key)%"), let value = value as? String {

            return adding(path: key, value: value)

        } else if endPoint!.requiredBodyFields.contains(key) {

            return adding(body: key, value: value)
        }

        return self
    }
}
