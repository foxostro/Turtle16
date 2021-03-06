//
//  InstructionDecoder.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

// Instruction Decoder is backed by four ROM buffers.
// This mirrors the physical construction of the Instruction Decoder circuit
// which uses four 8-bit ROM chips to form a 32-bit word.
public class InstructionDecoder: NSObject {
    public let rom: [Memory]
    
    public var size: Int {
        return rom[0].size
    }
    
    public override convenience init() {
        let romChipSize = 131072
        self.init(withROM: [Memory(size: romChipSize),
                            Memory(size: romChipSize),
                            Memory(size: romChipSize),
                            Memory(size: romChipSize)])
    }
    
    public required init(withROM rom: [Memory]) {
        assert(rom.count == 4)
        self.rom = rom
    }
    
    public func store(opcode:Int, controlWord:ControlWord) {
        store(opcode: opcode, carryFlag: 0, equalFlag: 0, controlWord: controlWord)
        store(opcode: opcode, carryFlag: 1, equalFlag: 0, controlWord: controlWord)
        store(opcode: opcode, carryFlag: 0, equalFlag: 1, controlWord: controlWord)
        store(opcode: opcode, carryFlag: 1, equalFlag: 1, controlWord: controlWord)
    }
    
    public func store(opcode:Int, carryFlag:Int, equalFlag:Int, controlWord:ControlWord) {
        store(value: UInt32(controlWord.unsignedIntegerValue),
              to: makeAddress(opcode: opcode,
                              carryFlag: carryFlag,
                              equalFlag: equalFlag))
    }
    
    public func store(value: UInt32, to address: Int) {
        rom[0].store(value: UInt8( value & 0x000000ff), to: address)
        rom[1].store(value: UInt8((value & 0x0000ff00) >> 8), to: address)
        rom[2].store(value: UInt8((value & 0x00ff0000) >> 16), to: address)
        rom[3].store(value: UInt8((value & 0xff000000) >> 24), to: address)
    }
    
    public func makeAddress(opcode:Int, carryFlag:Int, equalFlag:Int) -> Int {
        // The physical construction of the instruction decoder circuit has the
        // opcode feeding into the lower eight bits of the ROM address.
        // The carry flag is connected to address bit 9.
        // The equal flag is connected to address bit 8.
        return carryFlag<<9 | equalFlag<<8 | opcode
    }
    
    public func load(opcode:Int, carryFlag:Int, equalFlag:Int) -> UInt32 {
        return load(from: makeAddress(opcode: opcode,
                                      carryFlag: carryFlag,
                                      equalFlag: equalFlag))
    }
    
    public func load(from address: Int) -> UInt32 {
        return UInt32(rom[3].load(from: address))<<24
             | UInt32(rom[2].load(from: address))<<16
             | UInt32(rom[1].load(from: address))<<8
             | UInt32(rom[0].load(from: address))
    }
}
