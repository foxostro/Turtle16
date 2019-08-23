//
//  AssemblerDeclarationPass.swift
//  Simulator
//
//  Created by Andrew Fox on 7/31/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Takes an AST and performs a pass that does declarations.
public class AssemblerDeclarationPass: NSObject, AbstractSyntaxTreeNodeVisitor {
    public typealias Symbols = [String:Int]
    public var symbols: Symbols = [:]
    public var programCounter = 0
    
    public func doDeclarations(_ root: AbstractSyntaxTreeNode) throws {
        symbols = [String:Int]()
        programCounter = 1
        try root.iterate {
            try $0.accept(visitor: self)
        }
    }
    
    public func visit(node: NOPNode) throws {
        programCounter += 1
    }
    
    public func visit(node: CMPNode) throws {
        programCounter += 1
    }
    
    public func visit(node: HLTNode) throws {
        programCounter += 1
    }
    
    public func visit(node: JMPToLabelNode) throws {
        assert(node.identifier.type == .identifier)
        programCounter += 5
    }
    
    public func visit(node: JMPToAddressNode) throws {
        programCounter += 5
    }
    
    public func visit(node: JCToLabelNode) throws {
        assert(node.identifier.type == .identifier)
        programCounter += 5
    }
    
    public func visit(node: JCToAddressNode) throws {
        programCounter += 5
    }
    
    public func visit(node: ADDNode) throws {
        programCounter += 1
    }
    
    public func visit(node: LINode) throws {
        programCounter += 1
    }
    
    public func visit(node: MOVNode) throws {
        programCounter += 1
    }
    
    public func visit(node: LabelDeclarationNode) throws {
        assert(node.identifier.type == .identifier)
        let name = node.identifier.lexeme
        if symbols[name] == nil {
            symbols[name] = self.programCounter
        } else {
            throw AssemblerError(line: node.identifier.lineNumber, format: "duplicate label: `%@'", name)
        }
    }
    
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
    
//    public func jmp(_ address: Int) throws {
//        assert(isAssembling)
//        commands.append({
//            try self.setAddress(address)
//            self.codeGenerator.jmp()
//            self.codeGenerator.nop()
//            self.codeGenerator.nop()
//        })
//        programCounter += 5
//    }
    
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
