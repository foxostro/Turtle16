//
//  Instruction.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class Instruction: NSObject {
    public var opcode:UInt8 = 0
    public var immediate:UInt8 = 0
    
    public override init() {
    }
    
    public init(opcode: Int, immediate: Int) {
        self.opcode = UInt8(opcode)
        self.immediate = UInt8(immediate)
    }
    
    public var value:UInt16 {
        return UInt16(Int(opcode) << 8 | Int(immediate))
    }
    
    public override var description: String {
        return String(format: "{op=0x%x, imm=0x%x}", opcode, immediate)
    }
}
