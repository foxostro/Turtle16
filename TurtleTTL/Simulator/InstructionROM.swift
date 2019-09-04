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
    public let upperROM: Memory
    public let lowerROM: Memory
    
    public var size: Int {
        return lowerROM.size
    }
    
    public override convenience init() {
        let blank = Memory(withSize: 131072)
        self.init(withUpperROM: blank,
                  withLowerROM: blank)
    }
    
    public required init(withUpperROM upperROM: Memory,
                         withLowerROM lowerROM: Memory) {
        assert(lowerROM.size == upperROM.size)
        self.upperROM = upperROM
        self.lowerROM = lowerROM
    }
    
    public func withUpperROM(_ upperROM: Memory) -> InstructionROM {
        return InstructionROM(withUpperROM: upperROM,
                              withLowerROM: lowerROM)
    }
    
    public func withLowerROM(_ lowerROM: Memory) -> InstructionROM {
        return InstructionROM(withUpperROM: upperROM,
                              withLowerROM: lowerROM)
    }
    
    public func withStore(value: UInt16, to address: Int) -> InstructionROM {
        let updatedUpper = upperROM.withStore(value: UInt8((value & 0xff00) >> 8), to: address)
        let updatedLower = lowerROM.withStore(value: UInt8( value & 0x00ff), to: address)
        return self
            .withUpperROM(updatedUpper)
            .withLowerROM(updatedLower)
    }
    
    public func withStore(opcode: Int, immediate: Int, to address: Int) -> InstructionROM {
        let updatedUpper = upperROM.withStore(value: UInt8(opcode), to: address)
        let updatedLower = lowerROM.withStore(value: UInt8(immediate), to: address)
        return self
            .withUpperROM(updatedUpper)
            .withLowerROM(updatedLower)
    }
    
    public func withStore(instruction: Instruction, to address: Int) -> InstructionROM {
        return self.withStore(opcode: Int(instruction.opcode),
                              immediate: Int(instruction.immediate),
                              to: address)
    }
    
    public func withStore(_ instructions: [Instruction]) -> InstructionROM {
        var updated = self
        for i in 0..<instructions.count {
            updated = updated.withStore(instruction: instructions[i], to: i)
        }
        return updated
    }
    
    public func load(from address: Int) -> Instruction {
        return Instruction(opcode: Int(upperROM.load(from: address)),
                           immediate: Int(lowerROM.load(from: address)))
    }
}
