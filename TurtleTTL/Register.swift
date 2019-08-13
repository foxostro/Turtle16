//
//  Register.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Register: NSObject {
    public var contents: UInt8 = 0
    public var stringValue: String {
        get {
            return String(contents, radix: 16)
        }
        set(newStringValue) {
            if let value = UInt8(newStringValue, radix: 16) {
                contents = value
            }
        }
    }
}
