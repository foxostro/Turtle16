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
    public var symbols: [String:Int] = [:]
    var patcherActions: [Patcher.Action] = []
    
    public required init(codeGenerator: CodeGenerator) {
        self.codeGenerator = codeGenerator
        super.init()
    }
    
    public func compile(_ root: AbstractSyntaxTreeNode) throws -> [Instruction] {
        patcherActions = []
        codeGenerator.begin()
        try root.iterate {
            try $0.accept(visitor: self)
        }
        codeGenerator.end()
        let patcher = Patcher(inputInstructions: codeGenerator.instructions,
                              symbols: symbols,
                              actions: patcherActions)
        let postPatchInstructions = try patcher.patch()
        return postPatchInstructions
    }
    
    public func visit(node: NOPNode) throws {
        self.codeGenerator.nop()
    }
    
    public func visit(node: CMPNode) throws {
        self.codeGenerator.cmp()
    }
    
    public func visit(node: HLTNode) throws {
        self.codeGenerator.hlt()
    }
    
    public func visit(node: JMPToLabelNode) throws {
        try self.setAddress(token: node.identifier)
        self.codeGenerator.jmp()
        self.codeGenerator.nop()
        self.codeGenerator.nop()
    }
    
    public func visit(node: JMPToAddressNode) throws {
        try self.setAddress(node.address)
        self.codeGenerator.jmp()
        self.codeGenerator.nop()
        self.codeGenerator.nop()
    }
    
    public func visit(node: JCToLabelNode) throws {
        try self.setAddress(token: node.identifier)
        self.codeGenerator.jc()
        self.codeGenerator.nop()
        self.codeGenerator.nop()
    }
    
    public func visit(node: JCToAddressNode) throws {
        try self.setAddress(node.address)
        self.codeGenerator.jc()
        self.codeGenerator.nop()
        self.codeGenerator.nop()
    }
    
    public func visit(node: ADDNode) throws {
        try self.codeGenerator.add(node.destination)
    }
    
    public func visit(node: LINode) throws {
        try self.codeGenerator.li(node.destination, token: node.immediate)
    }
    
    public func visit(node: MOVNode) throws {
        try self.codeGenerator.mov(node.destination, node.source)
    }
    
    public func visit(node: LabelDeclarationNode) throws {
        let name = node.identifier.lexeme
        if symbols[name] == nil {
            symbols[name] = codeGenerator.programCounter
        } else {
            throw AssemblerError(line: node.identifier.lineNumber, format: "duplicate label: `%@'", name)
        }
    }
    
    public func visit(node: LoadNode) throws {
        let lineNumber = node.sourceAddress.lineNumber
        let address = node.sourceAddress.literal
        if(address < 0 || address > 0xffff) {
            throw AssemblerError(line: lineNumber, format: "Address is invalid: 0x%x", address)
        }
        try self.setAddress(address)
        try self.codeGenerator.mov(node.destination, "M")
    }
    
    public func visit(node: StoreNode) throws {
        let lineNumber = node.destinationAddress.lineNumber
        let address = node.destinationAddress.literal
        if(address < 0 || address > 0xffff) {
            throw AssemblerError(line: lineNumber, format: "Address is invalid: 0x%x", address)
        }
        try self.setAddress(address)
        try self.codeGenerator.mov("M", node.source)
    }
    
    public func visit(node: StoreImmediateNode) throws {
        let lineNumber = node.destinationAddress.lineNumber
        let address = node.destinationAddress.literal
        if(address < 0 || address > 0xffff) {
            throw AssemblerError(line: lineNumber, format: "Address is invalid: 0x%x", address)
        }
        if(node.immediate < 0 || node.immediate > 0xff) {
            throw AssemblerError(line: lineNumber, format: "Immediate is invalid: 0x%x", node.immediate)
        }
        try self.setAddress(address)
        try self.codeGenerator.instruction(withMnemonic: "MOV M, C", immediate: node.immediate)
    }
    
    func setAddress(_ address: Int) throws {
        if(address < 0 || address > 0xffff) {
            throw AssemblerError(format: "invalid address: 0x%x", address)
        }
        try self.codeGenerator.li("X", (address & 0xff00) >> 8)
        try self.codeGenerator.li("Y", (address & 0xff))
    }
    
    func setAddress(token identifier: TokenIdentifier) throws {
        patcherActions.append((index: codeGenerator.programCounter,
                               symbol: identifier,
                               shift: 8))
        try codeGenerator.li("X", 0xAB)
        
        patcherActions.append((index: codeGenerator.programCounter,
                               symbol: identifier,
                               shift: 0))
        try codeGenerator.li("Y", 0xCD)
    }
}
