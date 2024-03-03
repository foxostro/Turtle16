//
//  SnapAbstractSyntaxTreeCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Accepts a parse / syntax tree and returns an abstract syntax tree.
// This is generally a contraction and rewriting of the parse tree, simplifying,
// removing extraneous nodes, and rewriting nodes to express high-level concepts
// in terms simpler ones.
public class SnapAbstractSyntaxTreeCompiler: NSObject {
    public private(set) var ast: Block = Block()
    public private(set) var testNames: [String] = []
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool {
        !errors.isEmpty
    }
    
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
                globalEnvironment: GlobalEnvironment) {
        self.shouldRunSpecificTest = shouldRunSpecificTest
        self.injectModules = injectModules
        self.isUsingStandardLibrary = isUsingStandardLibrary
        self.runtimeSupport = runtimeSupport
        self.sandboxAccessManager = sandboxAccessManager
        self.globalEnvironment = globalEnvironment
    }
    
    public func compile(_ root: AbstractSyntaxTreeNode?) {
        guard let root = root else {
            return
        }
        do {
            guard let topLevel = try tryCompile(root) as? Block else {
                throw CompilerError(message: "expected Block at root of tree after AST transformation")
            }
            ast = topLevel
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    func tryCompile(_ t0: AbstractSyntaxTreeNode) throws -> AbstractSyntaxTreeNode? {
        try t0
            .desugarTestDeclarations(
                testNames: &testNames,
                globalEnvironment: globalEnvironment,
                shouldRunSpecificTest: shouldRunSpecificTest,
                isUsingStandardLibrary: isUsingStandardLibrary,
                runtimeSupport: runtimeSupport)?
            .declPass(
                injectModules: injectModules,
                globalEnvironment: globalEnvironment,
                runtimeSupport: runtimeSupport)?
            .implPass(globalEnvironment: globalEnvironment)
    }
}

extension AbstractSyntaxTreeNode {
    // Erase test declarations and replace with a synthesized test runner.
    fileprivate func desugarTestDeclarations(
        testNames: inout [String],
        globalEnvironment: GlobalEnvironment,
        shouldRunSpecificTest: String?,
        isUsingStandardLibrary: Bool,
        runtimeSupport: String?) throws -> AbstractSyntaxTreeNode? {
        
        let testDeclarationTransformer = SnapASTTransformerTestDeclaration(
            globalEnvironment: globalEnvironment,
            shouldRunSpecificTest: shouldRunSpecificTest,
            isUsingStandardLibrary: isUsingStandardLibrary,
            runtimeSupport: runtimeSupport)
        let result = try testDeclarationTransformer.compile(self)
        testNames = testDeclarationTransformer.testNames
        return result
    }
    
    // Collect type declarations in a discrete pass
    fileprivate func declPass(
        injectModules: [(String, String)],
        globalEnvironment: GlobalEnvironment,
        runtimeSupport: String?) throws -> AbstractSyntaxTreeNode? {
        
        try SnapAbstractSyntaxTreeCompilerDeclPass(
            injectModules: injectModules,
            globalEnvironment: globalEnvironment,
            runtimeSupport: runtimeSupport)
        .compile(self)
    }
    
    // Rewrite higher-level nodes in terms of trees of lower-level nodes.
    fileprivate func implPass(globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try SnapAbstractSyntaxTreeCompilerImplPass(globalEnvironment: globalEnvironment)
            .compile(self)
    }
}
