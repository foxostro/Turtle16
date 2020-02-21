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
    public let carryFlag: Int
    public let equalFlag: Int
    public override var description: String {
        return String(format:"{carryFlag: %d, equalFlag: %d}", carryFlag, equalFlag)
    }
    
    public override init() {
        self.carryFlag = 0
        self.equalFlag = 0
    }
    
    public init(_ carryFlag: Int, _ equalFlag: Int) {
        self.carryFlag = carryFlag
        self.equalFlag = equalFlag
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? Flags {
            return self == rhs
        } else {
            return false
        }
    }
}

public func ==(lhs: Flags, rhs: Flags) -> Bool {
    return (lhs.equalFlag == rhs.equalFlag) && (lhs.carryFlag == rhs.carryFlag)
}
