//
//  Flags.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents a flags (condition codes) register in the TurtleTTL hardware.
public class Flags: NSObject {
    fileprivate let carryFlagMask: UInt8 = 0b00000001
    fileprivate let equalFlagMask: UInt8 = 0b00000010
    
    public let carryFlag: Int
    public let equalFlag: Int
    
    public override var description: String {
        return "{carryFlag: \(carryFlag), equalFlag: \(equalFlag)}"
    }
    
    public override init() {
        self.carryFlag = 0
        self.equalFlag = 0
    }
    
    public init(_ carryFlag: Int, _ equalFlag: Int) {
        assert(carryFlag == 0 || carryFlag == 1)
        assert(equalFlag == 0 || equalFlag == 1)
        self.carryFlag = carryFlag
        self.equalFlag = equalFlag
    }
    
    public init(value: UInt8) {
        carryFlag = ((value & carryFlagMask) == 0) ? 0 : 1
        equalFlag = ((value & equalFlagMask) == 0) ? 0 : 1
    }
    
    public var value: UInt8 {
        var value: UInt8 = 0
        if carryFlag != 0 {
            value |= carryFlagMask
        } else {
            value &= ~carryFlagMask
        }
        if equalFlag != 0 {
            value |= equalFlagMask
        } else {
            value &= ~equalFlagMask
        }
        return value
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? Flags else { return false }
        return self == rhs
    }
}

public func ==(lhs: Flags, rhs: Flags) -> Bool {
    return (lhs.equalFlag == rhs.equalFlag) && (lhs.carryFlag == rhs.carryFlag)
}
