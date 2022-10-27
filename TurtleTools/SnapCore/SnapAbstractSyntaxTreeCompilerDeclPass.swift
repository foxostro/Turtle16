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
    public private(set) var injectModules: [(String, String)]
    public let globalEnvironment: GlobalEnvironment
    public let runtimeSupport: String?
    
    public init(symbols: SymbolTable? = nil,
                injectModules: [(String, String)] = [],
                globalEnvironment: GlobalEnvironment,
                runtimeSupport: String? = nil) {
        self.injectModules = injectModules
        self.globalEnvironment = globalEnvironment
        self.runtimeSupport = runtimeSupport
        super.init(symbols)
    }
    
    public override func compile(func node0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerFunctionDeclaration()
        try subcompiler.compile(globalEnvironment: globalEnvironment,
                                symbols: symbols!,
                                node: node0)
        return nil
    }
    
    public override func compile(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerStructDeclaration(symbols: symbols!, globalEnvironment: globalEnvironment)
        try subcompiler.compile(node0)
        return nil // Erase the StructDeclaration now that it's been processed.
    }
    
    public override func compile(typealias node0: Typealias) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTypealias(symbols!)
        try subcompiler.compile(node0)
        return nil // Erase the typealias now that we've bound the new type.
    }
    
    public override func compile(trait node0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTraitDeclaration(globalEnvironment: globalEnvironment)
        let node1 = try subcompiler.compile(node0)
        reconnect(node1)
        let node2 = try super.compile(seq: node1)
        return node2
    }
    
    public override func compile(impl node0: Impl) throws -> AbstractSyntaxTreeNode? {
        try SnapSubcompilerImpl(symbols: symbols!, globalEnvironment: globalEnvironment).compile(node0)
        return nil // Erase the Impl node now that it's been processed.
    }
    
    public override func compile(import node0: Import) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerImport(symbols: symbols!,
                                                globalEnvironment: globalEnvironment,
                                                runtimeSupport: runtimeSupport)
        for (name, text) in injectModules {
            subcompiler.injectModule(name: name, sourceCode: text)
        }
        try subcompiler.compile(node0)
        return nil
    }
    
    public override func compile(implFor node0: ImplFor) throws -> AbstractSyntaxTreeNode? {
        try SnapSubcompilerImplFor(symbols: symbols!,
                                   globalEnvironment: globalEnvironment)
            .compile(node0)
        return nil
    }
}
