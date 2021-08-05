//
//  SnapAbstractSyntaxTreeCompilerDeclPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiles an Abstract Syntax Tree to another, simpler AST and symbol table.
// Accepts an AST, walks the tree, and updates type information. Compilation
// must be performed in two distinct passes. The first pass, this one, processes
// declarations.
//
// SnapAbstractSyntaxTreeCompilerDeclPass delegates most the specific work to
// various subcompilers classes.
public class SnapAbstractSyntaxTreeCompilerDeclPass: SnapASTTransformerBase {
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public private(set) var modules: [Module] = []
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable? = nil) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        super.init(symbols)
    }
    
    public override func compile(func node0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerFunctionDeclaration(symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try node1.flatMap { try super.compile(func: $0) }
        return node2
    }
    
    public override func compile(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerStructDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try node1.flatMap { try super.compile(struct: $0) }
        return node2
    }
    
    public override func compile(typealias node0: Typealias) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTypealias(symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try node1.flatMap { try super.compile(typealias: $0) }
        return node2
    }
    
    public override func compile(trait node0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTraitDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let seq1 = try subcompiler.compile(node0)
        let seq2 = try seq1.compactMap { try compile($0) }
        assert(seq2.count == 1)
        return seq2.first!
    }
    
//    public override func compile(import node0: Import) throws -> AbstractSyntaxTreeNode? {
//        fatalError("unimplemented")
//    }
    
    public override func compile(module node0: Module) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerModule(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0)
        return node1
    }
}
