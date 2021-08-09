//
//  SnapAbstractSyntaxTreeCompilerImplPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiles an Abstract Syntax Tree to another, simpler AST and symbol table.
// Accepts an AST and walks the tree. For each matched node, it may rewrite
// that node in terms of simpler concepts, and it may update the symbol table
// to record additional information derived from the program.
//
// SnapAbstractSyntaxTreeCompilerImplPass delegates most the specific work to
// various subcompilers classes.
public class SnapAbstractSyntaxTreeCompilerImplPass: SnapASTTransformerBase {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable? = nil) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        super.init(symbols)
    }
    
    public override func compile(assert node0: Assert) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerAssert().compile(node0)
        let node2 = try super.compile(node1)
        return node2
    }
    
    public override func compile(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerVarDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(varDecl: node1)
        return node2
    }
    
    public override func compile(forIn node0: ForIn) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerForIn(symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(block: node1)
        return node2
    }
    
    public override func compile(match node0: Match) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerMatch(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(node1)
        return node2
    }
    
    public override func compile(return node0: Return) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerReturn(symbols!)
        let node1 = try subcompiler.compile(node0)
        return node1
    }
}
