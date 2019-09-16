//
//  ALU.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Represents the ALU module in TurtleTTL hardware.
public class ALU: NSObject {
    public var a:UInt8 = 0
    public var b:UInt8 = 0
    public var s:UInt8 = 0
    public var mode = 0
    public var carryIn = 0 // active-low
    public private(set) var carryFlag = 0
    public private(set) var equalFlag = 0
    public private(set) var result:UInt8 = 0
    
    // The actual hardware will update outputs as inputs change. However, in
    // the simulator, the outputs only update when the update method is called.
    public func update() {
        let lower181 = Chip74x181()
        lower181.a = (a & 0b1111)
        lower181.b = (b & 0b1111)
        lower181.s = (s & 0b1111)
        lower181.mode = mode
        lower181.carryIn = carryIn
        lower181.update()
        
        let upper181 = Chip74x181()
        upper181.a = (a & 0b11110000) >> 4
        upper181.b = (b & 0b11110000) >> 4
        upper181.s = (s & 0b1111)
        upper181.mode = mode
        upper181.carryIn = lower181.carryOut
        upper181.update()
        
        result = lower181.result | (upper181.result << 4)
        equalFlag = lower181.equalOut & upper181.equalOut
        carryFlag = upper181.carryOut
    }
}
