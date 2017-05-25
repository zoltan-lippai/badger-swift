//
//  AsyncIteration.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/1/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

// This struct is sadly necessary to perform the async iteration, as array extensions with restriction on the elements to only conform to a particular protocol won't work
internal struct ResponseProcessorWrapper: ResponseProcessing {
    let processor: ResponseProcessing

    func process(result: Processable, completion: ((Processable) -> Void)?) {
        processor.process(result: result, completion: completion)
    }
}

extension Array where Element: ResponseProcessing {

    /**
     Iterates over an array of `ResponseProcessorWrapper`, each one invoking the `process(result:completion:)` method after their completion is called.
     */
    func forAsync(iterateWith result: Processable, completion: ((Processable) -> Void)?) {
        iterate(iterator: makeIterator(), result: result, completion: completion)
    }

    private func iterate(iterator: IndexingIterator<[Element]>, result: Processable, completion: ((Processable) -> Void)?) {
        var iterator = iterator

        if let aProcessor = iterator.next() {
            aProcessor.process(result: result) { aResult in
                if (aResult as? Evaluable)?.shouldContinueEvaluation ?? true {
                    self.iterate(iterator: iterator, result: aResult, completion: completion)
                } else {
                    completion?(aResult)
                }
            }
        } else {
            completion?(result)
        }
    }
}
