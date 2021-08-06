//
//  SymbolTablesReconnector.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SymbolTablesReconnector: NSObject {
    var symbols: SymbolTable? = nil
    
    public init(_ symbols: SymbolTable? = nil) {
        self.symbols = symbols
    }
    
    public func reconnect(_ genericNode: AbstractSyntaxTreeNode?) {
        switch genericNode {
        case let node as If:
            reconnect(if: node)
        case let node as While:
            reconnect(while: node)
        case let node as ForIn:
            reconnect(forIn: node)
        case let node as Block:
            reconnect(block: node)
        case let node as FunctionDeclaration:
            reconnect(func: node)
        case let node as Impl:
            reconnect(impl: node)
        case let node as ImplFor:
            reconnect(implFor: node)
        case let node as Match:
            reconnect(match: node)
        case let node as TestDeclaration:
            reconnect(testDecl: node)
        case let node as Module:
            reconnect(module: node)
        default:
            break
        }
    }
    
    func reconnect(if node: If) {
        reconnect(node.thenBranch)
        reconnect(node.elseBranch)
    }
    
    func reconnect(while node: While) {
        reconnect(node.body)
    }
    
    func reconnect(forIn node: ForIn) {
        reconnect(node.body)
    }
    
    func reconnect(block node: Block) {
        let parent = symbols
        node.symbols.parent = parent
        node.symbols.storagePointer = parent?.storagePointer ?? 0
        node.symbols.stackFrameIndex = parent?.stackFrameIndex ?? 0
        
        symbols = node.symbols
        for child in node.children {
            reconnect(child)
        }
        symbols = parent
    }
    
    func reconnect(func node: FunctionDeclaration) {
        let parent = symbols
        node.symbols.parent = parent
        node.symbols.storagePointer = 0
        node.symbols.stackFrameIndex = (parent?.stackFrameIndex ?? 0) + 1
        
        symbols = node.symbols
        reconnect(node.body)
        symbols = parent
    }
    
    func reconnect(impl node: Impl) {
        for child in node.children {
            reconnect(child)
        }
    }
    
    func reconnect(implFor node: ImplFor) {
        for child in node.children {
            reconnect(child)
        }
    }
    
    func reconnect(match node: Match) {
        for clause in node.clauses {
            reconnect(clause.block)
        }
        reconnect(node.elseClause)
    }
    
    func reconnect(testDecl node: TestDeclaration) {
        reconnect(node.body)
    }
    
    func reconnect(module node: Module) {
        let parent = symbols
        symbols = node.symbols
        for child in node.children {
            reconnect(child)
        }
        symbols = parent
    }
}
