//
//  InstructionMemory.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Instruction ROM is backed by two ROM buffers.
// This mirrors the physical construction of the Instruction ROM circuit which
// uses two eight-bit EEPROM chips to form a sixteen-bit word.
public class InstructionMemory: NSObject {
    public let upperROM: Memory
    public let lowerROM: Memory
    
    public var size: Int {
        return lowerROM.size
    }
    
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
        for i in 0..<instructions.count {
            store(instruction: instructions[i], to: i)
        }
    }
    
    public func store(instruction: Instruction, to address: Int) {
        upperROM.store(value: instruction.opcode, to: address)
        lowerROM.store(value: instruction.immediate, to: address)
    }
    
    public func store(value: UInt16, to address: Int) {
        let opcode =    UInt8((value & 0xff00) >> 8)
        let immediate = UInt8( value & 0x00ff)
        upperROM.store(value: opcode, to: address)
        lowerROM.store(value: immediate, to: address)
    }
}
