//
//  Message.swift
//  BadgerClient
//
//  Created by Zoltan Lippai on 5/25/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation
import Networking

struct Message: Serializable {
    
    let ref: String?
    let topic: String
    let event: String
    let payload: Serializable?
    
    init?(rawValue: Any) {
        guard let json = rawValue as? [String: Any] else { return nil }
        guard let topic = json["topic"] as? String else { return nil }
        guard let event = json["event"] as? String else { return nil }
        
        self.topic = topic
        self.event = event
        self.ref = json["ref"] as? String
        
        if let jsonPayload = json["payload"] as? [String: Any] {
            if let reply = Reply(rawValue: jsonPayload) {
                self.payload = reply
            } else if let chat = Chat(rawValue: jsonPayload) {
                self.payload = chat
            } else {
                self.payload = nil
            }
        } else {
            self.payload = nil
        }
    }
}

struct Reply: Serializable {
    let key: String
    let status: String
    
    init?(rawValue: Any) {
        guard let json = rawValue as? [String: Any] else { return nil }
        guard let status = json["status"] as? String else { return nil }
        guard let response = json["response"] as? [String: Any] else { return nil }
        guard let key = response["key"] as? String else { return nil }
        
        self.key = key
        self.status = status
    }
}

struct Chat: Serializable {
    let key: String
    
    init?(rawValue: Any) {
        guard let json = rawValue as? [String: Any] else { return nil }
        guard let key = json["key"] as? String else { return nil }
        self.key = key
    }
}
