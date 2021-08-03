//
//  SnapASTContractionStep.swift
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
public class SnapASTContractionStep: NSObject {
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
            guard let topLevel = try applyTopLevelMacros(root) as? Block else {
                throw CompilerError(message: "expected Block at root of tree after AST transformation")
            }
            ast = topLevel
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    func applyTopLevelMacros(_ t0: AbstractSyntaxTreeNode) throws -> AbstractSyntaxTreeNode? {
        // Rewrite TopLevel to a Block so it can carry the global symbol table.
        let t1 = try SnapASTTransformerTopLevel().compile(t0)
        
        // Process Assert before tests since Assert needs to know about the
        // enclosing test to synthesize the error message.
        let t2 = try SnapASTTransformerAssert().compile(t1)
        
        // Erase test declarations and replace with a synthesized test runner.
        let testDeclarationTransformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: shouldRunSpecificTest)
        let t3 = try testDeclarationTransformer.compile(t2)
        testNames = testDeclarationTransformer.testNames
        
        return t3
        
        // Some AST contraction steps both need to be aware of symbols and
        // themselves create new symbols. Both of those steps have to be
        // performed together, in one pass over the tree.
//        let t4 = try SnapAbstractSyntaxTreeCompiler(memoryLayoutStrategy: memoryLayoutStrategy, symbols: nil).compile(t3)
//
//        return t4
    }
}
