//
//  SnapAbstractSyntaxTreeCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiles an Abstract Syntax Tree to another, simpler AST and symbol table.
// Accepts an AST and walks the tree. For each matched node, it may rewrite
// that node in terms of simpler concepts, and it may update the symbol table
// to record additional information derived from the program.
//
// SnapAbstractSyntaxTreeCompiler delegates most the specific work to various
// subcompilers classes.
public class SnapAbstractSyntaxTreeCompiler: SnapASTTransformerBase {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable? = nil) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        super.init(symbols)
    }
    
    public override func compile(func node0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerFunctionDeclaration(symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(node1)
        return node2
    }
    
    public override func compile(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerStructDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0) as! StructDeclaration
        let node2 = try super.compile(node1)
        return node2
    }
    
    public override func compile(typealias node0: Typealias) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTypealias(symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(node1)
        return node2
    }
    
    public override func compile(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerVarDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(node1)
        return node2
    }
}
