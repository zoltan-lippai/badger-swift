//
//  CallbackProcessor.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/1/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

/**
 A simple processor unit executed as last in the response processing chain. It helps the engine to determine how to finish the processing flow:
 * allows dropping the response causing the completion block to not be invoked at all
 * allows repeating the original request and calling the original completion once it has finished successfully. This assumes the repeated request won't fail the same way the first attempt did.
 * allows calling back the original completion block normally
 */
struct CallbackProcessor: ResponseProcessing {

    /// The network engine
    let engine: RequestProcessing

    func process(result processableResult: Processable, completion: ((Processable) -> Void)?) {
        guard let result = processableResult as? ProcessableResponse & AsyncInvocable else {
            completion?(processableResult)
            return
        }
        
        if result.shouldRepeat {
            engine.process(task: result.request, completion: completion)
        } else if !result.shouldDrop {
            result.callback(completion: completion)
        }

        // IMPORTANT: If the result indicates `shouldDrop` = `true` then no completion block is called
    }
}
