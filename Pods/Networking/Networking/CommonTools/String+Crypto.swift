//
//  String+Crypto.swift
//  Networking
//
//  Created by Zoltan Lippai on 5/10/17.
//  Copyright © 2017 DoorDash. All rights reserved.
//

import Foundation
import CryptoSwift

extension String {
    /**
     Returns the SHA1 digest from the receiver as hex string
     */
    var sha1String: String? {
        return data(using: .utf8).flatMap { $0.sha1() }?.toHexString()
    }
}
