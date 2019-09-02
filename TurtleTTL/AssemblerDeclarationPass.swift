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
        programCounter += 5
    }
    
    public func visit(node: JMPToAddressNode) throws {
        programCounter += 5
    }
    
    public func visit(node: JCToLabelNode) throws {
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
        let name = node.identifier.lexeme
        if symbols[name] == nil {
            symbols[name] = self.programCounter
        } else {
            throw AssemblerError(line: node.identifier.lineNumber, format: "duplicate label: `%@'", name)
        }
    }
    
    public func visit(node: LoadNode) throws {
        programCounter += 3
    }
    
    public func visit(node: StoreNode) throws {
        programCounter += 3
    }
    
    public func visit(node: StoreImmediateNode) throws {
        programCounter += 3
    }
}
