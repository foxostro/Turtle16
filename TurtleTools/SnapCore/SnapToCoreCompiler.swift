//
//  SnapToCoreCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiles a syntax tree, lowering nodes to the core Snap language.
// Accepts a parse / syntax tree and returns an abstract syntax tree.
// This is generally a contraction and rewriting of the parse tree, simplifying,
// removing extraneous nodes, and rewriting nodes to express high-level concepts
// in terms simpler ones. (i.e., de-sugaring of language constructs)
// The core Snap language is a simpler subset of the language which can be
// accepted by the next stage of the compiler.
public class SnapToCoreCompiler: NSObject {
    public private(set) var testNames: [String] = []
    
    let shouldRunSpecificTest: String?
    let isUsingStandardLibrary: Bool
    let runtimeSupport: String?
    let sandboxAccessManager: SandboxAccessManager?
    let injectModules: [(String, String)]
    let globalEnvironment: GlobalEnvironment
    
    public init(shouldRunSpecificTest: String? = nil,
                injectModules: [(String, String)] = [],
                isUsingStandardLibrary: Bool = false,
                runtimeSupport: String? = nil,
                sandboxAccessManager: SandboxAccessManager? = nil,
                globalEnvironment: GlobalEnvironment = GlobalEnvironment()) {
        self.shouldRunSpecificTest = shouldRunSpecificTest
        self.injectModules = injectModules
        self.isUsingStandardLibrary = isUsingStandardLibrary
        self.runtimeSupport = runtimeSupport
        self.sandboxAccessManager = sandboxAccessManager
        self.globalEnvironment = globalEnvironment
    }
    
    public func compile(_ root: AbstractSyntaxTreeNode?) -> Result<Block?, Error> {
        Result {
            try root?
                .withImplicitImport(moduleName: standardLibraryName)?
                .withImplicitImport(moduleName: runtimeSupport)?
                .replaceTopLevelWithBlock()
                .reconnect(parent: nil)
                .desugarTestDeclarations(
                    testNames: &testNames,
                    globalEnvironment: globalEnvironment,
                    shouldRunSpecificTest: shouldRunSpecificTest)?
                .importPass(
                    injectModules: injectModules,
                    globalEnvironment: globalEnvironment)?
                .forInPass(globalEnvironment)?
                .declPass(
                    injectModules: injectModules,
                    globalEnvironment: globalEnvironment,
                    runtimeSupport: runtimeSupport)?
                .implPass(globalEnvironment)?
                .genericsPass(globalEnvironment)
        }
        .flatMap { ast in
            if let block = ast as? Block {
                .success(block)
            }
            else {
                .failure(CompilerError(message: "expected Block at root of tree after AST transformation"))
            }
        }
    }
    
    var standardLibraryName: String? {
        isUsingStandardLibrary
            ? kStandardLibraryModuleName
            : nil
    }
}

extension AbstractSyntaxTreeNode {
    // The parser gives us an AST with a TopLevel node at the root. This node
    // should be replaced by a Block node.
    fileprivate func replaceTopLevelWithBlock() -> AbstractSyntaxTreeNode {
        guard let top = self as? TopLevel else { return self }
        let block = Block(sourceAnchor: top.sourceAnchor,
                          symbols: SymbolTable(),
                          children: top.children)
        return block
    }
    
    // Insert an import statement for an implicit import
    fileprivate func withImplicitImport(moduleName: String?) -> AbstractSyntaxTreeNode? {
        if let moduleName, let top = self as? TopLevel {
            top.withChildren([Import(moduleName: moduleName)] + top.children)
        }
        else if let moduleName, let block = self as? Block {
            block.withChildren([Import(moduleName: moduleName)] + block.children)
        }
        else {
            self
        }
    }
    
    // Collect type declarations and variable declarations
    fileprivate func declPass(
        injectModules: [(String, String)],
        globalEnvironment: GlobalEnvironment,
        runtimeSupport: String?) throws -> AbstractSyntaxTreeNode? {
            
        try self
            .clearSymbols(globalEnvironment)?
            .declPass_(
                injectModules: injectModules,
                globalEnvironment: globalEnvironment,
                runtimeSupport: runtimeSupport)
    }
    
    fileprivate func declPass_(
        injectModules: [(String, String)],
        globalEnvironment: GlobalEnvironment,
        runtimeSupport: String?) throws -> AbstractSyntaxTreeNode? {
        
        let compiler = SnapAbstractSyntaxTreeCompilerDeclPass(
            injectModules: injectModules,
            globalEnvironment: globalEnvironment,
            runtimeSupport: runtimeSupport)
        return try compiler.run(self)
    }
}
