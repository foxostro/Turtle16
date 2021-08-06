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
    var injectModules: [(String, String)]
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable? = nil, injectModules: [(String, String)] = []) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.injectModules = injectModules
        super.init(symbols)
    }
    
    public override func compile(func node0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerFunctionDeclaration(symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(func: node1)
        return node2
    }
    
    public override func compile(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerStructDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        try subcompiler.compile(node0)
        return nil // Erase the StructDeclaration now that it's been processd.
    }
    
    public override func compile(typealias node0: Typealias) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTypealias(symbols!)
        try subcompiler.compile(node0)
        return nil // Erase the typealias now that we've bound the new type.
    }
    
    public override func compile(trait node0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTraitDeclaration(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0)
        let node2 = try super.compile(seq: node1)
        return node2
    }
    
    public override func compile(impl node0: Impl) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerImpl(symbols!)
        let node1 = try subcompiler.compile(node0)
        return node1
    }
    
    public override func compile(import node0: Import) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerImport(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        for (name, text) in injectModules {
            subcompiler.injectModule(name: name, sourceCode: "import stdlib\n" + text)
        }
        let node1 = try subcompiler.compile(node0)
        return node1
    }
    
    public override func compile(module node0: Module) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerModule(memoryLayoutStrategy: memoryLayoutStrategy, symbols: symbols!)
        let node1 = try subcompiler.compile(node0)
        return node1
    }
}
