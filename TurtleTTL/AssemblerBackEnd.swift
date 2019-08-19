//
//  AssemblerBackEnd.swift
//  Simulator
//
//  Created by Andrew Fox on 7/31/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Provides an interface for driving the code generator.
public class AssemblerBackEnd: NSObject {
    public struct AssemblerBackEndError: Error {
        public let message: String
        
        public init(format: String, _ args: CVarArg...) {
            message = String(format:format, arguments:args)
        }
    }
    
    public var instructions = [Instruction]()
    public var isAssembling: Bool = false
    let codeGenerator: CodeGenerator
    var symbols = [String:Int]()
    typealias Command = () throws -> ()
    var commands = [Command]()
    var programCounter = 0
    
    public required init(codeGenerator: CodeGenerator) {
        self.codeGenerator = codeGenerator
        super.init()
    }
    
    // Begin emitting instructions.
    public func begin() {
        isAssembling = true
        programCounter = 1
        codeGenerator.begin()
    }
    
    // End emitting instructions.
    // After this call, the client can copy instructions out of "instructions".
    public func end() throws {
        for i in 0..<commands.count {
            try commands[i]()
        }
        codeGenerator.end()
        instructions = codeGenerator.instructions
        isAssembling = false
    }
    
    // No Operation -- Do nothing
    public func nop() {
        assert(isAssembling)
        commands.append({
            self.codeGenerator.nop()
        })
        programCounter += 1
    }
    
    // Halt -- Halt the computer until reset
    public func hlt() {
        assert(isAssembling)
        commands.append({
            self.codeGenerator.hlt()
        })
        programCounter += 1
    }
    
    // Move -- Copy a value from one bus device to another.
    public func mov(_ destination: String, _ source: String) throws {
        assert(isAssembling)
        commands.append({
            try self.codeGenerator.mov(destination, source)
        })
        programCounter += 1
    }
    
    // Load Immediate -- Loads an immediate value to the specified destination
    public func li(_ destination: String, _ immediate: Int) throws {
        assert(isAssembling)
        commands.append({
            try self.codeGenerator.li(destination, immediate)
        })
        programCounter += 1
    }
    
    // Store -- Store the contents of a register to memory at the address.
    public func store(address: Int, source: String) throws {
        assert(isAssembling)
        if(address < 0 || address > 0xffff) {
            throw AssemblerBackEndError(format: "Address is invalid: 0x%x", address)
        }
        commands.append({
            try self.setAddress(address)
            try self.codeGenerator.mov("M", source)
        })
        programCounter += 3
    }
    
    // Store -- Store the contents of a register to memory at the address.
    public func store(address: Int, immediate: Int) throws {
        assert(isAssembling)
        if(address < 0 || address > 0xffff) {
            throw AssemblerBackEndError(format: "Address is invalid: 0x%x", address)
        }
        if(immediate < 0 || immediate > 0xff) {
            throw AssemblerBackEndError(format: "Immediate is invalid: 0x%x", address)
        }
        commands.append({
            try self.setAddress(address)
            try self.codeGenerator.instruction(withMnemonic: "MOV M, C", immediate: immediate)
        })
        programCounter += 3
    }
    
    // Load -- Load the contents of the memory at the address to a register.
    public func load(address: Int, destination: String) throws {
        assert(isAssembling)
        if(address < 0 || address > 0xffff) {
            throw AssemblerBackEndError(format: "Address is invalid: 0x%x", address)
        }
        commands.append({
            try self.setAddress(address)
            try self.codeGenerator.mov(destination, "M")
        })
        programCounter += 3
    }
    
    // Addition -- The ALU adds the contents of the A and B registers and moves
    // the result to the specified destination bus device.
    public func add(_ destination: String) throws {
        assert(isAssembling)
        commands.append({
            try self.codeGenerator.add(destination)
        })
        programCounter += 1
    }
    
    // Compare -- The ALU compares the contents of the A and B registers.
    //            Flags are updated but the ALU result is not stored.
    public func cmp() throws {
        assert(isAssembling)
        commands.append({
            self.codeGenerator.cmp()
        })
        programCounter += 1
    }
    
    public func label(_ name: String) throws {
        assert(isAssembling)
        if symbols[name] == nil {
            symbols[name] = self.programCounter
        } else {
            throw AssemblerBackEndError(format: "Duplicate label \"%@\"", name)
        }
    }
    
    public func resolveSymbol(_ name: String) throws -> Int {
        if let value = self.symbols[name] {
            return value
        } else {
            throw AssemblerBackEndError(format: "Unrecognized symbol name \"%@\"", name)
        }
    }
    
    func setAddress(_ address: Int) throws {
        if(address < 0 || address > 0xffff) {
            throw AssemblerBackEndError(format: "Address is invalid: 0x%x", address)
        }
        try self.codeGenerator.li("X", (address & 0xff00) >> 8)
        try self.codeGenerator.li("Y", (address & 0xff))
    }
    
    func setAddress(withSymbol name: String) throws {
        let address = try self.resolveSymbol(name)
        try self.setAddress(address)
    }
    
    // Jump -- Jump to the specified label.
    public func jmp(_ name: String) throws {
        assert(isAssembling)
        commands.append({
            try self.setAddress(withSymbol: name)
            self.codeGenerator.jmp()
            self.codeGenerator.nop()
            self.codeGenerator.nop()
        })
        programCounter += 5
    }
    
    // Jump -- Jump to the specified address.
    public func jmp(_ address: Int) throws {
        assert(isAssembling)
        commands.append({
            try self.setAddress(address)
            self.codeGenerator.jmp()
            self.codeGenerator.nop()
            self.codeGenerator.nop()
        })
        programCounter += 5
    }
    
    // Jump on Carry -- If the carry flag is set then jump to the specified
    // label. Otherwise, do nothing.
    public func jc(_ name: String) throws {
        assert(isAssembling)
        commands.append({
            try self.setAddress(withSymbol: name)
            self.codeGenerator.jc()
            self.codeGenerator.nop()
            self.codeGenerator.nop()
        })
        programCounter += 5
    }
}
