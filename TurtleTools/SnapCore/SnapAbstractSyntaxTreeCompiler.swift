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
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    public var shouldRunSpecificTest: String? = nil
    
    public private(set) var ast: Block = Block()
    public private(set) var testNames: [String] = []
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool {
        !errors.isEmpty
    }
    
    public init(_ memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtleTTL()) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
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
        // Erase test declarations and replace with a synthesized test runner.
        let testDeclarationTransformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: shouldRunSpecificTest)
        let t1 = try testDeclarationTransformer.compile(t0)
        testNames = testDeclarationTransformer.testNames
        
        return t1
        
        // Collect type declarations in a discrete pass
//        let t2 = try SnapAbstractSyntaxTreeCompilerDeclPass(memoryLayoutStrategy: memoryLayoutStrategy, symbols: nil).compile(t1)
        
        // Rewrite higher-level nodes in terms of trees of lower-level nodes.
//        let t3 = try SnapAbstractSyntaxTreeCompilerImplPass(memoryLayoutStrategy: memoryLayoutStrategy, symbols: nil).compile(t2)
//
//        return t3
    }
}
