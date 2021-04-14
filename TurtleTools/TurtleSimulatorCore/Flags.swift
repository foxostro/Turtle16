//
//  Flags.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

// Represents a flags (condition codes) register in the TurtleTTL hardware.
public class Flags: NSObject {
    private let carryFlagMask: UInt8 = 0b00000001
    private let equalFlagMask: UInt8 = 0b00000010
    
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
    
    public static func ==(lhs: Flags, rhs: Flags) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let unwrappedRhs = rhs as? Flags else { return false }
        guard equalFlag == unwrappedRhs.equalFlag else { return false }
        guard carryFlag == unwrappedRhs.carryFlag else {return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(equalFlag)
        hasher.combine(carryFlag)
        return hasher.finalize()
    }
}
