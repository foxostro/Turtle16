//
//  ProgramCounter.swift
//  TurtleSimulatorCore
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
        return String(format: "0x%04x", value)
    }
    
    public override var description: String {
        return stringValue
    }
    
    public required init(withValue value: UInt16 = 0) {
        self.value = value
    }
    
    public func increment() -> ProgramCounter {
        return ProgramCounter(withValue: value &+ 1)
    }
    
    public static func ==(lhs: ProgramCounter, rhs: ProgramCounter) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? ProgramCounter else { return false }
        guard value == rhs.value else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(value)
        return hasher.finalize()
    }
}
