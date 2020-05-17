//
//  CodeGenerator.swift
//  TurtleAssemblerCore
//
//  Created by Andrew Fox on 7/30/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

// Generates machine code for use in the IF stage of TurtleTTL hardware.
public class CodeGenerator: NSObject {
    public let microcodeGenerator: MicrocodeGenerator
    public var instructions = [Instruction]()
    var isAssembling: Bool = false
    public var programCounter: Int {
        return instructions.count
    }
    
    public init(microcodeGenerator: MicrocodeGenerator) {
        self.microcodeGenerator = microcodeGenerator
        super.init()
    }
    
    // Begin emitting instructions.
    public func begin() {
        isAssembling = true
        instructions = []
        nop()
    }
    
    // End emitting instructions.
    // After this call, the client can copy instructions out of "instructions".
    public func end() {
        isAssembling = false
    }
    
    // Produce a generic instruction with the specified immediate value.
    public func instruction(withMnemonic mnemonic:String, immediate: Int) throws {
        assert(isAssembling)
        if immediate < 0 || immediate > 255 {
            throw CompilerError(format: "immediate value is not between 0 and 255: `%d'", immediate)
        }
        let maybeOpcode = microcodeGenerator.getOpcode(withMnemonic: mnemonic)
        if let opcode = maybeOpcode {
            let inst = Instruction(opcode: UInt8(opcode), immediate: UInt8(immediate))
            instructions.append(inst)
        } else {
            throw CompilerError(format: "unrecognized mnemonic: `%@'", mnemonic)
        }
    }
    
    // Produce a generic instruction with the specified immediate value.
    public func instruction(withMnemonic mnemonic:String, token immediateToken: TokenNumber) throws {
        assert(isAssembling)
        let immediate = immediateToken.literal
        if immediate < 0 || immediate > 255 {
            throw CompilerError(line: immediateToken.lineNumber, format: "immediate value is not between 0 and 255: `%d'", immediate)
        }
        let maybeOpcode = microcodeGenerator.getOpcode(withMnemonic: mnemonic)
        if let opcode = maybeOpcode {
            let inst = Instruction(opcode: UInt8(opcode), immediate: UInt8(immediate))
            instructions.append(inst)
        } else {
            throw CompilerError(line: immediateToken.lineNumber, format: "unrecognized mnemonic: `%@'", mnemonic)
        }
    }
    
    // No Operation -- Do nothing
    public func nop() {
        assert(isAssembling)
        try! instruction(withMnemonic: "NOP", immediate: 0)
    }
    
    // Halt -- Halt the computer until reset
    public func hlt() {
        assert(isAssembling)
        try! instruction(withMnemonic: "HLT", immediate: 0)
    }
    
    // INUV -- Increment the UV register pair
    public func inuv() {
        assert(isAssembling)
        try! instruction(withMnemonic: "INUV", immediate: 0)
    }
    
    // INXY -- Increment the XY register pair
    public func inxy() {
        assert(isAssembling)
        try! instruction(withMnemonic: "INXY", immediate: 0)
    }
    
    // Move -- Copy a value from one bus device to another.
    public func mov(_ destination: RegisterName, _ source: RegisterName, _ immediate: Int) throws {
        assert(isAssembling)
        let mnemonic = String(format: "MOV %@, %@", String(describing: destination), String(describing: source))
        try instruction(withMnemonic: mnemonic, immediate: immediate)
    }
    
    // Move -- Copy a value from one bus device to another.
    public func mov(_ destination: RegisterName, _ source: RegisterName, token immediate: TokenNumber) throws {
        assert(isAssembling)
        let mnemonic = String(format: "MOV %@, %@", String(describing: destination), String(describing: source))
        try instruction(withMnemonic: mnemonic, token: immediate)
    }
    
    // Move -- Copy a value from one bus device to another.
    public func mov(_ destination: RegisterName, _ source: RegisterName) throws {
        assert(isAssembling)
        let mnemonic = String(format: "MOV %@, %@", String(describing: destination), String(describing: source))
        try instruction(withMnemonic: mnemonic, immediate: 0)
    }
    
    // Load Immediate -- Loads an immediate value to the specified destination
    public func li(_ destination: RegisterName, _ immediate: Int) throws {
        assert(isAssembling)
        try mov(destination, .C, immediate)
    }
    
    // Load Immediate -- Loads an immediate value to the specified destination
    public func li(_ destination: RegisterName, token immediate: TokenNumber) throws {
        assert(isAssembling)
        try mov(destination, .C, token: immediate)
    }
    
    // Addition -- The ALU adds the contents of the A and B registers and moves
    // the result to the specified destination bus device.
    public func add(_ destination: RegisterName) throws {
        assert(isAssembling)
        let mnemonic: String
        if destination == .NONE {
            mnemonic = "ALU"
        } else {
            mnemonic = String(format: "ALU %@", String(describing: destination))
        }
        try instruction(withMnemonic: mnemonic, immediate: 0b1001)
    }
    
    // Compare -- The ALU compares the contents of the A and B registers.
    //            Flags are updated but the ALU result is not stored.
    public func cmp() {
        assert(isAssembling)
        try! instruction(withMnemonic: "ALU", immediate: 0b0110)
    }
    
    // Link -- Save the contents of PC to the Link register
    public func link() {
        assert(isAssembling)
        try! instruction(withMnemonic: "LINK", immediate: 0)
    }
    
    // Jump -- Jump to the address specified by the XY register pair, and load the link register
    public func jalr() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JALR", immediate: 0)
    }
    
    // Jump -- Jump to the address specified by the XY register pair.
    public func jmp() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JMP", immediate: 0)
    }
    
    // Jump on Carry -- If the carry flag is set then jump to the address
    // specified by the XY register pair. Otherwise, do nothing.
    public func jc() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JC", immediate: 0)
    }
    
    public func jnc() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JNC", immediate: 0)
    }
    
    public func je() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JE", immediate: 0)
    }
    
    public func jne() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JNE", immediate: 0)
    }
    
    public func jg() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JG", immediate: 0)
    }
    
    public func jle() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JLE", immediate: 0)
    }
    
    public func jl() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JL", immediate: 0)
    }
    
    public func jge() {
        assert(isAssembling)
        try! instruction(withMnemonic: "JGE", immediate: 0)
    }
    
    // Bit Blit -- Copy a value from a peripheral to data RAM (or vice versa)
    // and increment the address registers for both the source and destination.
    public func blt(_ destination: RegisterName, _ source: RegisterName) throws {
        assert(isAssembling)
        let mnemonic = String(format: "BLT %@, %@", String(describing: destination), String(describing: source))
        try instruction(withMnemonic: mnemonic, immediate: 0)
    }
}
