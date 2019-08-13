//
//  InstructionROM.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Instruction ROM is backed by two ROM buffers.
// This mirrors the physical construction of the Instruction ROM circuit which
// uses two eight-bit EEPROM chips to form a sixteen-bit word.
public class InstructionROM: NSObject {
    public let size = 131072
    public let upperROM = Memory(size: 131072)
    public let lowerROM = Memory(size: 131072)
    
    public func load(address:Int) -> Instruction {
        let instruction = Instruction()
        instruction.opcode = upperROM[address]
        instruction.immediate = lowerROM[address]
        return instruction
    }
    
    public func store(address:Int, value:UInt16) {
        upperROM[address] = UInt8((value & 0xff00) >> 8)
        lowerROM[address] = UInt8( value & 0x00ff)
    }
    
    public func store(address:Int, opcode:Int, immediate:Int) {
        upperROM[address] = UInt8(opcode)
        lowerROM[address] = UInt8(immediate)
    }
    
    public func store(address:Int, instruction:Instruction) {
        store(address: address,
              opcode: Int(instruction.opcode),
              immediate: Int(instruction.immediate))
    }
    
    public func store(_ instructions: [Instruction]) {
        for i in 0..<instructions.count {
            store(address: i, instruction: instructions[i])
        }
    }
}
