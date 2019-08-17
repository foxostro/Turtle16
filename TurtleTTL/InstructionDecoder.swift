//
//  InstructionDecoder.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Instruction Decoder is backed by two ROM buffers.
// This mirrors the physical construction of the Instruction Decoder circuit
// which uses two eight-bit EEPROM chips to form a sixteen-bit word.
public class InstructionDecoder: NSObject {
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
    
    public func withUpperROM(_ upperROM: Memory) -> InstructionDecoder {
        return InstructionDecoder(withUpperROM: upperROM,
                                  withLowerROM: lowerROM)
    }
    
    public func withLowerROM(_ lowerROM: Memory) -> InstructionDecoder {
        return InstructionDecoder(withUpperROM: upperROM,
                                  withLowerROM: lowerROM)
    }
    
    public func withStore(opcode:Int, controlWord:ControlWord) -> InstructionDecoder {
        return self
            .withStore(opcode: opcode, carryFlag: 0, equalFlag: 0, controlWord: controlWord)
            .withStore(opcode: opcode, carryFlag: 1, equalFlag: 0, controlWord: controlWord)
            .withStore(opcode: opcode, carryFlag: 0, equalFlag: 1, controlWord: controlWord)
            .withStore(opcode: opcode, carryFlag: 1, equalFlag: 1, controlWord: controlWord)
    }
    
    public func withStore(opcode:Int, carryFlag:Int, equalFlag:Int, controlWord:ControlWord) -> InstructionDecoder {
        return withStore(value: UInt16(controlWord.unsignedIntegerValue),
                         to: makeAddress(opcode: opcode,
                                         carryFlag: carryFlag,
                                         equalFlag: equalFlag))
    }
    
    public func withStore(value: UInt16, to address: Int) -> InstructionDecoder {
        let updatedUpper = upperROM.withStore(value: UInt8((value & 0xff00) >> 8), to: address)
        let updatedLower = lowerROM.withStore(value: UInt8( value & 0x00ff), to: address)
        return self
            .withUpperROM(updatedUpper)
            .withLowerROM(updatedLower)
    }
    
    public func makeAddress(opcode:Int, carryFlag:Int, equalFlag:Int) -> Int {
        // The physical construction of the instruction decoder circuit has the
        // opcode feeding into the lower eight bits of the ROM address.
        // The carry flag is connected to address bit 9.
        // The equal flag is connected to address bit 8.
        return carryFlag<<9 | equalFlag<<8 | opcode
    }
    
    public func load(opcode:Int, carryFlag:Int, equalFlag:Int) -> UInt16 {
        return load(from: makeAddress(opcode: opcode,
                                      carryFlag: carryFlag,
                                      equalFlag: equalFlag))
    }
    
    public func load(from address: Int) -> UInt16 {
        return UInt16(upperROM.load(from: address))<<8 | UInt16(lowerROM.load(from: address))
    }
    
    public func writeUpperROM(url: URL) throws {
        try upperROM.data.write(to: url)
    }
    
    public func writeLowerROM(url: URL) throws {
        try lowerROM.data.write(to: url)
    }
}
