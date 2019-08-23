//
//  AssemblerCodeGenPass.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Takes an AST and performs a pass that does final code generation.
public class AssemblerCodeGenPass: NSObject, AbstractSyntaxTreeNodeVisitor {
    let codeGenerator: CodeGenerator
    var symbols: [String:Int]
    
    public required init(codeGenerator: CodeGenerator, symbols: [String:Int] = [:]) {
        self.codeGenerator = codeGenerator
        self.symbols = symbols
        super.init()
    }
    
    public func generate(_ root: AbstractSyntaxTreeNode) throws -> [Instruction] {
        codeGenerator.begin()
        try root.iterate {
            try $0.accept(visitor: self)
        }
        codeGenerator.end()
        return codeGenerator.instructions
    }
    
    // No Operation -- Do nothing
    public func visit(node: NOPNode) throws {
        self.codeGenerator.nop()
    }
    
    // Compare -- The ALU compares the contents of the A and B registers.
    //            Flags are updated but the ALU result is not stored.
    public func visit(node: CMPNode) throws {
        self.codeGenerator.cmp()
    }
    
    // Halt -- Halt the computer until reset
    public func visit(node: HLTNode) throws {
        self.codeGenerator.hlt()
    }
    
    // Jump -- Jump to the specified label.
    public func visit(node: JMPToLabelNode) throws {
        assert(node.identifier.type == .identifier)
        try self.setAddress(token: node.identifier)
        self.codeGenerator.jmp()
        self.codeGenerator.nop()
        self.codeGenerator.nop()
    }
    
    // Jump -- Jump to the specified absolute address.
    public func visit(node: JMPToAddressNode) throws {
        try self.setAddress(node.address)
        self.codeGenerator.jmp()
        self.codeGenerator.nop()
        self.codeGenerator.nop()
    }
    
    // Jump on Carry -- If the carry flag is set then jump to the specified
    // label. Otherwise, do nothing.
    public func visit(node: JCToLabelNode) throws {
        assert(node.identifier.type == .identifier)
        try self.setAddress(token: node.identifier)
        self.codeGenerator.jc()
        self.codeGenerator.nop()
        self.codeGenerator.nop()
    }
    
    // Addition -- The ALU adds the contents of the A and B registers and moves
    // the result to the specified destination bus device.
    public func visit(node: ADDNode) throws {
        try self.codeGenerator.add(node.destination)
    }
    
    // Load Immediate -- Loads an immediate value to the specified destination
    public func visit(node: LINode) throws {
        try self.codeGenerator.li(node.destination, token: node.immediate)
    }
    
    // Move -- Copy a value from one bus device to another.
    public func visit(node: MOVNode) throws {
        try self.codeGenerator.mov(node.destination, node.source)
    }
    
    public func visit(node: LabelDeclarationNode) throws {
        // do nothing
    }
    
//    // Store -- Store the contents of a register to memory at the address.
//    public func store(address: Int, source: String) throws {
//        assert(isAssembling)
//        if(address < 0 || address > 0xffff) {
//            throw AssemblerError(format: "Address is invalid: 0x%x", address)
//        }
//        commands.append({
//            try self.setAddress(address)
//            try self.codeGenerator.mov("M", source)
//        })
//        programCounter += 3
//    }
    
//    // Store -- Store the contents of a register to memory at the address.
//    public func store(address: Int, immediate: Int) throws {
//        assert(isAssembling)
//        if(address < 0 || address > 0xffff) {
//            throw AssemblerError(format: "Address is invalid: 0x%x", address)
//        }
//        if(immediate < 0 || immediate > 0xff) {
//            throw AssemblerError(format: "Immediate is invalid: 0x%x", immediate)
//        }
//        commands.append({
//            try self.setAddress(address)
//            try self.codeGenerator.instruction(withMnemonic: "MOV M, C", immediate: immediate)
//        })
//        programCounter += 3
//    }
    
//    // Load -- Load the contents of the memory at the address to a register.
//    public func load(address: Int, destination: String) throws {
//        assert(isAssembling)
//        if(address < 0 || address > 0xffff) {
//            throw AssemblerError(format: "Address is invalid: 0x%x", address)
//        }
//        commands.append({
//            try self.setAddress(address)
//            try self.codeGenerator.mov(destination, "M")
//        })
//        programCounter += 3
//    }
    
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
    
//    func setAddress(withSymbol name: String) throws {
//        let address = try self.resolveSymbol(name: name)
//        try self.setAddress(address)
//    }
    
    func setAddress(token identifier: AssemblerScanner.Token) throws {
        assert(identifier.type == .identifier)
        let address = try self.resolveSymbol(token: identifier)
        try self.setAddress(address)
    }
    
//    // Jump -- Jump to the specified label.
//    public func jmp(_ name: String) throws {
//        assert(isAssembling)
//        commands.append({
//            try self.setAddress(withSymbol: name)
//            self.codeGenerator.jmp()
//            self.codeGenerator.nop()
//            self.codeGenerator.nop()
//        })
//        programCounter += 5
//    }

//    // Jump on Carry -- If the carry flag is set then jump to the specified
//    // label. Otherwise, do nothing.
//    public func jc(_ name: String) throws {
//        assert(isAssembling)
//        commands.append({
//            try self.setAddress(withSymbol: name)
//            self.codeGenerator.jc()
//            self.codeGenerator.nop()
//            self.codeGenerator.nop()
//        })
//        programCounter += 5
//    }
}
