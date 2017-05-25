//
//  SocketViewController.swift
//  BadgerClient
//
//  Created by Zoltan Lippai on 5/25/2017.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import UIKit
import Networking

class SocketViewController: UIViewController {

    let webService = WebService(engine: Engine())
    var referenceCounter = 0
    
    @IBOutlet weak var sendButton: UIButton?

    func didOpenSockets(notification: Notification) {
        webService.register(streamReading: [JSONProcessor(type: Message.self), StreamReadProcessor(streamRead: log)])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didOpenSockets(notification:)), name: .WebServiceOpenedWebSocket, object: nil)
        
        webService.openWebSocket(to: "http://localhost", path: "/socket/websocket", port: .custom(4000))
        joinPacket.flatMap { self.webService.dispatcher?.feed(data: $0) }
        referenceCounter += 1
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        messagePacket.flatMap { self.webService.dispatcher?.feed(data: $0) }
        referenceCounter += 1
    }
}

extension SocketViewController {
    func log(message: Message) {
        switch message.event {
        case "phx_reply" where message.payload is Reply:
            print("reply from server: \((message.payload as! Reply).key)")
        case "new_msg" where message.payload is Chat:
            print("chat message: \((message.payload as! Chat).key)")
        default:
            print("generic message with event: \(message.event)")
        }
    }
}

extension SocketViewController {
    var joinPacket: Data? {
        let joinPayload: [String: Any] = ["topic": "device:1234",
                                          "event": "phx_join",
                                          "ref": String(referenceCounter),
                                          "payload": ["subject": "status",
                                                      "body": "joining"]]
        return try? JSONSerialization.data(withJSONObject: joinPayload, options: [])
    }
    
    var messagePacket: Data? {
        let messagePacket: [String: Any] = ["topic": "device:1234",
                                            "event": "new_msg",
                                            "ref": String(referenceCounter),
                                            "payload": ["key": "This is a new message from iOS client"]
        ]
        return try? JSONSerialization.data(withJSONObject: messagePacket, options: [])
    }
}
