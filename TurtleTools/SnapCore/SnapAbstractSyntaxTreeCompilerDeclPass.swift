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
    
    public override func visit(func node0: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        assert(node0.symbols.frameLookupMode.isSet)
        let subcompiler = SnapSubcompilerFunctionDeclaration()
        try subcompiler.compile(globalEnvironment: globalEnvironment,
                                symbols: symbols!,
                                node: node0)
        return nil
    }
    
    public override func visit(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerStructDeclaration(symbols: symbols!, globalEnvironment: globalEnvironment)
        try subcompiler.compile(node0)
        return nil // Erase the StructDeclaration now that it's been processed.
    }
    
    public override func visit(typealias node0: Typealias) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerTypealias(symbols!)
        try subcompiler.compile(node0)
        return nil // Erase the typealias now that we've bound the new type.
    }
    
    public override func visit(trait node0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        _ = try SnapSubcompilerTraitDeclaration(
            globalEnvironment: globalEnvironment,
            symbols: symbols!).compile(node0)
        return nil // Erase the trait declaration now that we've bound new types in the environment.
    }
    
    public override func visit(impl node0: Impl) throws -> AbstractSyntaxTreeNode? {
        try SnapSubcompilerImpl(symbols: symbols!, globalEnvironment: globalEnvironment).compile(node0)
        return nil // Erase the Impl node now that it's been processed.
    }
    
    public override func visit(import node0: Import) throws -> AbstractSyntaxTreeNode? {
        let subcompiler = SnapSubcompilerImport(symbols: symbols!,
                                                globalEnvironment: globalEnvironment,
                                                runtimeSupport: runtimeSupport)
        for (name, text) in injectModules {
            subcompiler.injectModule(name: name, sourceCode: text)
        }
        try subcompiler.compile(node0)
        return nil
    }
    
    public override func visit(implFor node0: ImplFor) throws -> AbstractSyntaxTreeNode? {
        try SnapSubcompilerImplFor(symbols: symbols!,
                                   globalEnvironment: globalEnvironment)
            .compile(node0)
        return nil
    }
}
