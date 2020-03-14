//
//  InstructionMemoryRev1.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/27/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

// Emulates the instruction memory mapping in the Rev 1 hardware.
public class InstructionMemoryRev1: NSObject, InstructionMemory {
    public var size: Int { return 0x10000 }
    public var upperROMData: Data { instructionROM.upperROMData }
    public var lowerROMData: Data { instructionROM.lowerROMData }
    
    let instructionROM: InstructionMemory
    let upperInstructionRAM: Memory
    let lowerInstructionRAM: Memory
    let instructionFormatter: InstructionFormatter
    
    public convenience override init() {
        self.init(instructionROM: InstructionROM(),
                  upperInstructionRAM: Memory(),
                  lowerInstructionRAM: Memory(),
                  instructionFormatter: InstructionFormatter())
    }
    
    public init(instructionROM: InstructionMemory,
                upperInstructionRAM: Memory,
                lowerInstructionRAM: Memory,
                instructionFormatter: InstructionFormatter) {
        self.instructionROM = instructionROM
        self.upperInstructionRAM = upperInstructionRAM
        self.lowerInstructionRAM = lowerInstructionRAM
        self.instructionFormatter = instructionFormatter
    }
    
    public func load(from address: Int) -> Instruction {
        let offset = 0x8000
        
        let temp: Instruction
        if address < offset {
            temp = instructionROM.load(from: address)
        } else {
            let opcode = upperInstructionRAM.load(from: address - offset)
            let immediate = lowerInstructionRAM.load(from: address - offset)
            temp = Instruction(opcode: opcode, immediate: immediate)
        }

        let disassembly = instructionFormatter.format(instruction: temp)
        let instruction = Instruction(opcode: temp.opcode,
                                      immediate: temp.immediate,
                                      disassembly: disassembly,
                                      pc: ProgramCounter(withValue: UInt16(address)))
        
        return instruction
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
        let offset = 0x8000
        
        if address < offset {
            instructionROM.store(value: value, to: address)
        } else {
            let opcode =    UInt8((value & 0xff00) >> 8)
            let immediate = UInt8( value & 0x00ff)
            upperInstructionRAM.store(value: opcode, to: address - offset)
            lowerInstructionRAM.store(value: immediate, to: address - offset)
        }
    }
}
