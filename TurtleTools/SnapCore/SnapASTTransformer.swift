//
//  SnapASTTransformer.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformer: NSObject {
    public var shouldRunSpecificTest: String? = nil
    
    public private(set) var ast: Block = Block()
    public private(set) var testNames: [String] = []
    public private(set) var errors: [CompilerError] = []
    public var hasError: Bool {
        !errors.isEmpty
    }
    
    public func transform(_ root: AbstractSyntaxTreeNode) {
        do {
            guard let topLevel = try applyTopLevelMacros(root) as? Block else {
                throw CompilerError(message: "expected Block at root of tree after AST transformation")
            }
            ast = topLevel
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    public func applyTopLevelMacros(_ t0: AbstractSyntaxTreeNode) throws -> AbstractSyntaxTreeNode? {
        // Rewrite TopLevel to a Block so it can carry the global symbol table.
        let t1 = try SnapASTTransformerTopLevel().transform(t0)
        
        // Process Assert before tests since Assert needs to know about the
        // enclosing test to synthesize the error message.
        let t2 = try SnapASTTransformerAssert().transform(t1)
        
        // Erase test declarations and replace with a synthesized test runner.
        let t3 = try testTransform(t2)
        
        return t3
    }
    
    func testTransform(_ input: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let testDeclarationTransformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: shouldRunSpecificTest)
        let output = try testDeclarationTransformer.transform(input)
        testNames = testDeclarationTransformer.testNames
        return output
    }
}
