//
//  ProgramCounter.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents a program counter in the TurtleTTL hardware.
public class ProgramCounter: NSObject {
    public let value: UInt16
    
    public var integerValue: Int {
        return Int(value)
    }
    
    public var stringValue: String {
        return String(value, radix: 16)
    }
    
    public override var description: String {
        return stringValue
    }
    
    public required init(withValue value: UInt16) {
        self.value = value
    }
    
    public convenience override init() {
        self.init(withValue: 0)
    }
    
    public convenience init?(withStringValue stringValue: String) {
        if let value = UInt16(stringValue, radix: 16) {
            self.init(withValue: value)
        } else {
            return nil
        }
    }
    
    public func increment() -> ProgramCounter {
        return ProgramCounter(withValue: value &+ 1)
    }

    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? ProgramCounter {
            return self == rhs
        } else {
            return false
        }
    }
}

public func ==(lhs: ProgramCounter, rhs: ProgramCounter) -> Bool {
    return lhs.value == rhs.value
}
