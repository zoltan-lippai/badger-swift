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

    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    
    let socket = Socket(domainAndPort: "localhost:4000", path: "socket", transport: "websocket")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupSocket()
        
        self.messageButton.addTarget(self, action: #selector(sendMessage(with:)), for: UIControlEvents.touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func sendMessage(with sender: UIButton) {
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
