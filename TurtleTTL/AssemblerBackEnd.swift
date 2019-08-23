//
//  AssemblerBackEnd.swift
//  Simulator
//
//  Created by Andrew Fox on 7/31/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Takes an AST and drives the code generator.
public class AssemblerBackEnd: NSObject, AbstractSyntaxTreeNodeVisitor {
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
    
    public func generate(_ root: AbstractSyntaxTreeNode) throws -> [Instruction] {
        begin()
        try root.iterate {
            try $0.accept(visitor: self)
        }
        try end()
        return instructions
    }
    
    // Begin emitting instructions.
    public func begin() {
        instructions = []
        isAssembling = true
        symbols = [String:Int]()
        commands = []
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
    
    public func visit(node: NOPNode) throws {
        nop()
    }
    
    public func visit(node: CMPNode) throws {
        cmp()
    }
    
    public func visit(node: HLTNode) throws {
        hlt()
    }
    
    public func visit(node: JMPNode) throws {
        try jmp(token: node.identifier)
    }
    
    public func visit(node: JCNode) throws {
        try jc(token: node.identifier)
    }
    
    public func visit(node: ADDNode) throws {
        try add(node.destination)
    }
    
    public func visit(node: LINode) throws {
        try li(node.destination, token: node.immediate)
    }
    
    public func visit(node: MOVNode) throws {
        try mov(node.destination, node.source)
    }
    
    public func visit(node: LabelDeclarationNode) throws {
        try label(token: node.identifier)
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
    
    // Load Immediate -- Loads an immediate value to the specified destination
    public func li(_ destination: String, token immediate: AssemblerScanner.Token) throws {
        assert(isAssembling)
        assert(immediate.type == .number)
        commands.append({
            try self.codeGenerator.li(destination, token: immediate)
        })
        programCounter += 1
    }
    
    // Store -- Store the contents of a register to memory at the address.
    public func store(address: Int, source: String) throws {
        assert(isAssembling)
        if(address < 0 || address > 0xffff) {
            throw AssemblerError(format: "Address is invalid: 0x%x", address)
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
            throw AssemblerError(format: "Address is invalid: 0x%x", address)
        }
        if(immediate < 0 || immediate > 0xff) {
            throw AssemblerError(format: "Immediate is invalid: 0x%x", immediate)
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
            throw AssemblerError(format: "Address is invalid: 0x%x", address)
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
    public func cmp() {
        assert(isAssembling)
        commands.append({
            self.codeGenerator.cmp()
        })
        programCounter += 1
    }
    
    public func label(token identifier: AssemblerScanner.Token) throws {
        assert(isAssembling)
        assert(identifier.type == .identifier)
        let name = identifier.lexeme
        if symbols[name] == nil {
            symbols[name] = self.programCounter
        } else {
            throw AssemblerError(line: identifier.lineNumber, format: "duplicate label: `%@'", name)
        }
    }
    
    public func label(name: String) throws {
        assert(isAssembling)
        if symbols[name] == nil {
            symbols[name] = self.programCounter
        } else {
            throw AssemblerError(format: "duplicate label: `%@'", name)
        }
    }
    
    public func resolveSymbol(token identifier: AssemblerScanner.Token) throws -> Int {
        assert(identifier.type == .identifier)
        let name = identifier.lexeme
        if let value = self.symbols[name] {
            return value
        }
        throw AssemblerError(line: identifier.lineNumber, format: "unrecognized symbol name: `%@'", name)
    }
    
    public func resolveSymbol(name: String) throws -> Int {
        if let value = self.symbols[name] {
            return value
        }
        throw AssemblerError(format: "unrecognized symbol name: `%@'", name)
    }
    
    func setAddress(_ address: Int) throws {
        if(address < 0 || address > 0xffff) {
            throw AssemblerError(format: "invalid address: 0x%x", address)
        }
        try self.codeGenerator.li("X", (address & 0xff00) >> 8)
        try self.codeGenerator.li("Y", (address & 0xff))
    }
    
    func setAddress(withSymbol name: String) throws {
        let address = try self.resolveSymbol(name: name)
        try self.setAddress(address)
    }
    
    func setAddress(token identifier: AssemblerScanner.Token) throws {
        assert(identifier.type == .identifier)
        let address = try self.resolveSymbol(token: identifier)
        try self.setAddress(address)
    }
    
    // Jump -- Jump to the specified label.
    public func jmp(token identifier: AssemblerScanner.Token) throws {
        assert(identifier.type == .identifier)
        assert(isAssembling)
        commands.append({
            try self.setAddress(token: identifier)
            self.codeGenerator.jmp()
            self.codeGenerator.nop()
            self.codeGenerator.nop()
        })
        programCounter += 5
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
    public func jc(token identifier: AssemblerScanner.Token) throws {
        assert(identifier.type == .identifier)
        assert(isAssembling)
        commands.append({
            try self.setAddress(token: identifier)
            self.codeGenerator.jc()
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
