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
                    runtimeSupport: runtimeSupport,
                    globalEnvironment: globalEnvironment)?
                .forInPass(globalEnvironment)?
                .genericsPass(globalEnvironment)?
                .vtablesPass(globalEnvironment)?
                .implForPass(globalEnvironment)?
                .eraseMethodCalls(globalEnvironment)?
                .synthesizeTerminalReturnStatements(globalEnvironment)?
                .eraseImplPass(globalEnvironment)?
                .matchPass(globalEnvironment)?
                .assertPass(globalEnvironment)?
                .returnPass(globalEnvironment)?
                .whilePass(globalEnvironment)?
                .ifPass(globalEnvironment)?
                .implPass(globalEnvironment)?
                .flatten()
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
    public func replaceTopLevelWithBlock() -> AbstractSyntaxTreeNode {
        guard let top = self as? TopLevel else { return self }
        let block = Block(sourceAnchor: top.sourceAnchor,
                          symbols: SymbolTable(),
                          children: top.children)
        return block
    }
    
    // Insert an import statement for an implicit import
    public func withImplicitImport(moduleName: String?) -> AbstractSyntaxTreeNode? {
        guard let moduleName else { return self }
        let result = switch self {
        case let top as TopLevel:
            top.inserting(children: [Import(moduleName: moduleName)], at: 0)
        case let block as Block:
            block.inserting(children: [Import(moduleName: moduleName)], at: 0)
        case let module as Module:
            module.inserting(children: [Import(moduleName: moduleName)], at: 0)
        default:
            self
        }
        return result
    }
}
