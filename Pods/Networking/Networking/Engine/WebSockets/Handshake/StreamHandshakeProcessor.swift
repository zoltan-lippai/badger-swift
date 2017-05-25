//
//  StreamHandshakeProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/23/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

struct StreamHandshakeProcessor: ResponseProcessing {
    
    var processor: StreamReadProcessor<Data>!
    
    let processors: [ResponseProcessing]
    
    let url: URL
    
    let webService: WebService
    
    init(webService: WebService, handshake url: URL, processors: [ResponseProcessing]) {
        self.webService = webService
        self.url = url
        self.processors = processors
        processor = StreamReadProcessor(queue: .serialBackground, streamRead: processResult)
    }
    
    func processResult(data: Data) {
        if let urlResponse = HTTPURLResponse(url: url, data: data) {
            processors.map { ResponseProcessorWrapper(processor: $0) }.forAsync(iterateWith: OperationResult(with: urlResponse, data: data)) { result in
                if let error = result.error {
                    self.webService.didFailWebSocketHandshake(with: error)
                } else {
                    self.webService.didOpenWebSocketStreams()
                }
            }
        }
    }
    
    func process(result: Processable, completion: ((Processable) -> Void)?) {
        processor.process(result: result, completion: completion)
    }
}

extension CFHTTPMessage {
    
    /// Returns all the header fields of the receiver. Only string-convertible keys and values will be returned
    var allHeaderFields: [String: String]? {
        get {
            guard CFHTTPMessageIsHeaderComplete(self) else { return nil }
            
            let headers = CFHTTPMessageCopyAllHeaderFields(self)?.takeRetainedValue() as NSDictionary?
            return headers?.reduce([String: String]()) {
                var dictionary = $0
                if let key = ($1.key as? NSString).map({ String($0) }), let value = ($1.value as? NSString).map({ String($0) }) {
                    dictionary[key] = value
                }
                return dictionary
            }
        }
        set(newValue) {
            newValue?.forEach {
                CFHTTPMessageSetHeaderFieldValue(self, $0.key as CFString, $0.value as CFString)
            }
        }
    }
    
    /// Creates a new `CFHTTPMessage` from an http response data read from an input stream
    /// - parameter responseData: The data read from the stream
    /// - returns: A new `CFHTTPMessage` object
    static func message(from responseData: Data) -> CFHTTPMessage {
        let message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, false).takeRetainedValue()
        message.data = responseData
        return message
    }
    
    /// Creates a new `CFHTTPMessage` using a specified method and url
    /// - parameter method: An http method to use
    /// - parameter url: The URL to use
    /// - returns: A new `CFHTTPMessage` object
    static func message(method: String, url: URL) -> CFHTTPMessage {
        return CFHTTPMessageCreateRequest(kCFAllocatorDefault, method.uppercased() as CFString, url as CFURL, kCFHTTPVersion1_1).takeRetainedValue()
    }
    
    /// Returns the status code of the message
    var statusCode: Int? {
        return CFHTTPMessageGetResponseStatusCode(self)
    }
    
    /// The binary serialized data of the HTTP message
    var data: Data? {
        get {
            return CFHTTPMessageCopySerializedMessage(self)?.takeRetainedValue() as Data?
        }
        set(newValue) {
            if let data = newValue {
                CFHTTPMessageAppendBytes(self, data.bytes, data.count)
            }
        }
    }
}

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
