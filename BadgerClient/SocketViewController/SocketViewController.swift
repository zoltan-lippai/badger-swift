//
//  SocketViewController.swift
//  BadgerClient
//
//  Created by Anderthan Hsieh on 5/3/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import UIKit
import SwiftPhoenixClient

class SocketViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton?
    
    let socket = Socket(domainAndPort: "localhost:4000", path: "socket", transport: "websocket")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSocket()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let message = Message(message: ["key": "This is a ping from iOS client"])
        let topic = "device:1234"
        let event = "new_msg"
        let payload = Payload(topic: topic, event: event, message: message)
        socket.send(data: payload)
    }
    
    func setupSocket() {
        socket.join(topic:"device:1234", message: Message(subject:"status", body:"joining")) { (channel: Any) in
            let chan = channel as! Channel
            
            chan.on(event: "new_msg", callback: { (msg: Any) in
                let message = msg as! Message
                print("on")
                print(message)
            })

        }
    }

}
