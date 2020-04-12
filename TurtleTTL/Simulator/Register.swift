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
    
    public var integerValue: Int {
        return Int(value)
    }
    
    public override var description: String {
        return hexadecimalStringValue
    }
    
    public var displayString: String {
        return "\(hexadecimalStringValue) (\(binaryStringValue))"
    }
    
    public var stringValue: String {
        return hexadecimalStringValue
    }
    
    fileprivate var binaryStringValue: String {
        var result = String(value, radix: 2)
        if result.count < 8 {
            result = String(repeatElement("0", count: 8 - result.count)) + result
        }
        return "0b" + result
    }
    
    fileprivate var hexadecimalStringValue: String {
        return String(format: "0x%02x", value)
    }
    
    public required init(withValue value: UInt8 = 0) {
        self.value = value
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? Register {
            return self == rhs
        } else {
            return false
        }
    }
}

public func ==(lhs: Register, rhs: Register) -> Bool {
    return lhs.value == rhs.value
}
