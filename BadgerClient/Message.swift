//
//  Message.swift
//  BadgerClient
//
//  Created by Zoltan Lippai on 5/25/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation
import Networking

struct Message: Serializable, Streamable {
    
    let ref: String?
    let topic: String
    let event: String
    let payload: Serializable?
    
    init(ref: String?, topic: String, event: String, payload: Serializable?) {
        self.ref = ref
        self.topic = topic
        self.event = event
        self.payload = payload
    }
    
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
    
    var rawValue: Any? {
        var rawValue: [String: Any] = ["topic": topic, "event": event]
        if let payload = payload?.rawValue as? [String: Any] {
            rawValue = payload.reduce(rawValue) {
                var dict = $0
                dict[$1.key] = $1.value
                return dict
            }
        }
        
        if let ref = ref {
            rawValue["ref"] = ref
        }
        
        return rawValue
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
    
    var rawValue: Any? {
        return ["key": key, "status": status]
    }
}

struct Chat: Serializable {
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    init?(rawValue: Any) {
        guard let json = rawValue as? [String: Any] else { return nil }
        guard let key = json["key"] as? String else { return nil }
        self.key = key
    }
    
    var rawValue: Any? {
        return ["key": key]
    }
}
