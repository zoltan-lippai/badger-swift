//
//  NetworkingViewController.swift
//  BadgerClient
//
//  Created by Zoltan Lippai on 5/25/2017.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import UIKit
import Networking

class NetworkingViewController: UIViewController {

    let webService = WebService(engine: Engine())
    var referenceCounter = 0
    
    @IBOutlet weak var sendButton: UIButton?
    
    struct Reader: ResponseProcessing {
        let reader = StreamReadProcessor(queue: .main) { (data: Data) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(json)
            } else {
                print(data)
            }
        }

        func process(result: Processable, completion: ((Processable) -> Void)?) {
            reader.process(result: result, completion: completion)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didOpenSockets(notification:)), name: .WebServiceOpenedWebSocket, object: nil)
        
        webService.openWebSocket(to: "http://localhost", path: "/socket/websocket", port: .custom(4000))
        joinPacket.flatMap { self.webService.dispatcher?.feed(data: $0) }
        referenceCounter += 1
    }
    
    func didOpenSockets(notification: Notification) {
        webService.register(streamReading: [Reader()])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        messagePacket.flatMap { self.webService.dispatcher?.feed(data: $0) }
        referenceCounter += 1
    }
    
    var joinPacket: Data? {
        let joinPayload: [String: Any] = ["topic": "device:1234",
                                          "event": "phx_join",
                                          "ref": String(referenceCounter),
                                          "payload": ["subject": "status",
                                                      "body": "joining"]
                                         ]
        let data = try? JSONSerialization.data(withJSONObject: joinPayload, options: [])
        return data
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
