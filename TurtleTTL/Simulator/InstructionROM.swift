//
//  InstructionROM.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

// Instruction ROM is backed by two ROM buffers.
// This mirrors the physical construction of the Instruction ROM circuit which
// uses two eight-bit EEPROM chips to form a sixteen-bit word.
public class InstructionROM: NSObject, InstructionMemory {
    public let upperROM: Memory
    public let lowerROM: Memory
    public var upperROMData: Data { upperROM.data }
    public var lowerROMData: Data { lowerROM.data }
    public var size: Int { return lowerROM.size }
    
    public override convenience init() {
        self.init(upperROM: Memory(size: 131072),
                  lowerROM: Memory(size: 131072))
    }
    
    public required init(upperROM: Memory, lowerROM: Memory) {
        assert(upperROM !== lowerROM)
        assert(lowerROM.size == upperROM.size)
        self.upperROM = upperROM
        self.lowerROM = lowerROM
    }
    
    public func load(from address: Int) -> Instruction {
        return Instruction(opcode: upperROM.load(from: address),
                           immediate: lowerROM.load(from: address))
    }
    
    public func store(instructions: [Instruction]) {
        store(instructions: instructions, at: 0)
    }
    
    public func store(instructions: [Instruction], at address: Int) {
        for i in 0..<instructions.count {
            store(instruction: instructions[i], to: address + i)
        }
    }
    
    public func store(instruction: Instruction, to address: Int) {
        store(value: instruction.value, to: address)
    }
    
    public func store(value: UInt16, to address: Int) {
        let opcode =    UInt8((value & 0xff00) >> 8)
        let immediate = UInt8( value & 0x00ff)
        upperROM.store(value: opcode, to: address)
        lowerROM.store(value: immediate, to: address)
    }
}
