//
//  Register.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/15/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents an eight-bit register, or register-like device, in the TurtleTTL hardware.
public class Register: NSObject {
    public let value: UInt8
    
    public var stringValue: String {
        return String(value, radix: 16)
    }
    
    public override var description: String {
        return stringValue
    }
    
    public required init(withValue value: UInt8) {
        self.value = value
    }
    
    public convenience override init() {
        self.init(withValue: 0)
    }
    
    public convenience init?(withStringValue stringValue: String) {
        if let value = UInt8(stringValue, radix: 16) {
            self.init(withValue: value)
        } else {
            return nil
        }
    }
}
