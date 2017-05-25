//
//  StreamConnection.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/8/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 Contains the necessary means to connect to a remote host with streams to create and manage the streams and publish them to interested clients.
 */
public struct StreamConnection {
    
    /// The host url string
    public let host: String
    
    /// The host url as an `URL` object
    public var hostUrl: URL {
        return URL(string: host)!
    }
    
    /// The input stream, available once the connection has been opened to the remote host
    public var inputStream: InputStream?

    /// The input stream delegate
    var inputHandler: InputStreamEventHandler?
    
    /// The input stream, available once the connection has been opened to the remote host
    public var outputStream: OutputStream?

    /// The output stream delegate
    var outputHandler: OutputStreamEventHandler?

    /// The dispatch queue the input stream is scheduled on
    public let inputQueue = Constants.Queues.iStreamQueue
    
    /// The dispatch queue the output stream is scheduled on
    public let outputQueue = Constants.Queues.oStreamQueue

    /// The port to use for stream connections
    public var port: Int
    
    /// Returns whether the connection was secure or plain. The host url`s scheme is used to determine the result
    public var isSecureConnection: Bool { return hostUrl.scheme == Constants.Scheme.https.rawValue || hostUrl.scheme == Constants.Scheme.wss.rawValue }

    /**
     Designated initializer
     - parameter host: The host to connection to
     - parameter input: The input stream or `nil`
     - parameter output: The output stream or `nil`
     */
    public init(host: String, port: Constants.Port = .secure, input: InputStream? = nil, output: OutputStream? = nil) {
        self.host = host
        inputStream = input
        outputStream = output
        self.port = port.port
    }

    /**
     Closes the existing stream connections and returns a new instance with the connections released
     */
    fileprivate func closed() -> StreamConnection {
        return StreamConnection(host: host, input: nil, output: nil)
    }

    /**
     Initiates the connection to the remote host. If the connection has been successfully established, the `inputStream` and `outputStream` properties are set to the bidirectional stream instances representing the connection
     */
    mutating public func connect() {
        var input: InputStream?
        var output: OutputStream?
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &input, outputStream: &output)

        if isSecureConnection {
            input?.socketSecurity = .negotiatedSSL
            output?.socketSecurity = .negotiatedSSL
        }
        
        input?.networkServiceType = .background
        output?.networkServiceType = .background
        input?.schedule(in: inputQueue)
        output?.schedule(in: outputQueue)
        inputStream = input
        outputStream = output
    }
    
    /**
     Opens the streams and sets appropriate event handler delegates to each. This method should only be called after the streams have been connected and so created. Otherwise this method has no effect. This is a blocking call until the streams are open or an error is encountered during the attempt.
     - returns: The error that might have occurred during opening either of the streams.
     */
    public mutating func openStreams() -> Error? {
        guard let inputStream = inputStream, let outputStream = outputStream else {
            return Constants.Errors.streamsNotConnected
        }

        inputHandler = InputStreamEventHandler()
        var error = inputHandler?.open(stream: inputStream)
        
        if error == nil {
            outputHandler = OutputStreamEventHandler()
            error = outputHandler?.open(stream: outputStream)
        }
        
        return error
    }

    /**
     Disconnects the stream, unscheduling them from their respective dispatch queues, closing them, and releasing them.
     */
    public mutating func disconnect() {
        inputStream?.unscheduleFromDispatchQueue()
        outputStream?.unscheduleFromDispatchQueue()
        
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
    }
}
