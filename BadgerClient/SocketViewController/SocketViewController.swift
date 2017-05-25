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

    let webService = WebService(engine: Engine(), websocket: WebSocketConnector())
    var referenceCounter = 0
    
    @IBOutlet weak var sendButton: UIButton?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        webService.connector?.openWebSocket(to: "http://localhost", path: "/socket/websocket", protocols: [], port: .custom(4000))
        joinPacket.flatMap { self.webService.stream($0) }
        referenceCounter += 1
        webService.register(streamReading: [JSONProcessor(type: Message.self), StreamReadProcessor(streamRead: log)])
        webService.register(streamReading: [StreamReadProcessor(streamRead: { (data: Data) in
            print(String(data: data, encoding: .utf8) ?? "nil")
        })])
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        messagePacket.flatMap { self.webService.stream($0) }
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
