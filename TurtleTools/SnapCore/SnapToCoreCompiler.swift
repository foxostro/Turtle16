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
    
    public init(shouldRunSpecificTest: String? = nil,
                injectModules: [(String, String)] = [],
                isUsingStandardLibrary: Bool = false,
                runtimeSupport: String? = nil,
                sandboxAccessManager: SandboxAccessManager? = nil) {
        self.shouldRunSpecificTest = shouldRunSpecificTest
        self.injectModules = injectModules
        self.isUsingStandardLibrary = isUsingStandardLibrary
        self.runtimeSupport = runtimeSupport
        self.sandboxAccessManager = sandboxAccessManager
    }
    
    public func run(_ root: AbstractSyntaxTreeNode) throws -> (Block, testNames: [String]) {
        let core = try root
            .withImplicitImport(moduleName: standardLibraryName)?
            .withImplicitImport(
                moduleName: runtimeSupport,
                intoGlobalNamespace: true)?
            .replaceTopLevelWithBlock()
            .reconnect(parent: nil)
            .desugarTestDeclarations(
                testNames: &testNames,
                shouldRunSpecificTest: shouldRunSpecificTest)?
            .importPass(
                injectModules: injectModules,
                runtimeSupport: runtimeSupport)?
            .forInPass()?
            .genericsPass()?
            .vtablesPass()?
            .implForPass()?
            .eraseMethodCalls()?
            .synthesizeTerminalReturnStatements()?
            .eraseImplPass()?
            .matchPass()?
            .assertPass()?
            .returnPass()?
            .whilePass()?
            .ifPass()?
            .lowerVarDeclPass()?
            .flatten()
        guard let block = core as? Block else {
            throw CompilerError(message: "internal compiler error: expected Block after lowering Snap to the core language representation")
        }
        return (block, testNames)
    }
    
    var standardLibraryName: String? {
        isUsingStandardLibrary
            ? kStandardLibraryModuleName
            : nil
    }
}

extension AbstractSyntaxTreeNode {
    /// The parser gives us an AST with a TopLevel node at the root. This node
    /// should be replaced by a Block node.
    public func replaceTopLevelWithBlock() -> AbstractSyntaxTreeNode {
        guard let top = self as? TopLevel else { return self }
        let block = Block(sourceAnchor: top.sourceAnchor,
                          symbols: SymbolTable(),
                          children: top.children)
        return block
    }
    
    /// Insert an import statement for an implicit import
    public func withImplicitImport(
        moduleName: String?,
        intoGlobalNamespace global: Bool = false
    ) -> AbstractSyntaxTreeNode? {
        guard let moduleName else { return self }
        let importStmt = Import(moduleName: moduleName, intoGlobalNamespace: global)
        let result = switch self {
        case let top as TopLevel:
            top.inserting(children: [importStmt], at: 0)
        case let block as Block:
            block.inserting(children: [importStmt], at: 0)
        case let module as Module:
            module.inserting(children: [importStmt], at: 0)
        default:
            self
        }
        return result
    }
    
    /// Lower a Snap program to an equivalent representation which uses only a small core of the language
    public func snapToCore(
        shouldRunSpecificTest: String? = nil,
        injectModules: [(String, String)] = [],
        isUsingStandardLibrary: Bool = false,
        runtimeSupport: String? = nil,
        sandboxAccessManager: SandboxAccessManager? = nil
    ) throws -> (Block, testNames: [String]) {
        let compiler = SnapToCoreCompiler(
            shouldRunSpecificTest: shouldRunSpecificTest,
            injectModules: injectModules,
            isUsingStandardLibrary: isUsingStandardLibrary,
            runtimeSupport: runtimeSupport,
            sandboxAccessManager: sandboxAccessManager)
        return try compiler.run(self)
    }
}
