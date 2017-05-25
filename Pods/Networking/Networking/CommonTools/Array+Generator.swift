//
//  Array+Generator.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/11/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation

extension Array {
    
    /**
     Allows generating a new array with the specified number of elements, invoking a generator block for each index
     - parameter count: The number of elements to generate for the new array
     - parameter generator: A code block to invoke to generate the new element
     
     This method differs from the `repeating:value:` method as the block is allowed to return different elements
     */
    init(count: Int, generator: @escaping @autoclosure () -> Element) {
        self.init()
        (0..<count).forEach { _ in self.append(generator()) }
    }
    
    /**
     Allows generating a new array with the specified number of elements, invoking a generator block for each index
     - parameter count: The number of elements to generate for the new array
     - parameter generator: A code block to invoke to generate the new element
     
     This method differs from the `repeating:value:` method as the block is allowed to return different elements
     */
    init(count: Int, generator: @escaping () -> Element) {
        self.init()
        (0..<count).forEach { _ in self.append(generator()) }
    }
    
    /**
     Allows generating a new array with the specified number of elements, invoking a generator block for each index
     - parameter count: The number of elements to generate for the new array
     - parameter generator: A code block to invoke to generate the new element
     - parameter currentIndex: The current index passed to the generator
     
     This method differs from the `repeating:value:` method as the block is allowed to return different elements
     */
    init(count: Int, generator: @escaping (_ currentIndex: Int) -> Element) {
        self.init()
        (0..<count).forEach { self.append(generator($0)) }
    }
}
