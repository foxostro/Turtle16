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
            try tryTransform(root)
        } catch let e {
            errors.append(e as! CompilerError)
        }
    }
    
    public func tryTransform(_ t0: AbstractSyntaxTreeNode) throws {
        let t1 = try SnapASTTransformerTopLevel().transform(t0)
        let t2 = try SnapASTTransformerAssert().transform(t1)
        let t3 = try testTransform(t2)
        let t4 = try SnapASTTransformerSymbolTables().transform(t3)
        guard let topLevel = t4 as? Block else {
            throw CompilerError(sourceAnchor: t0.sourceAnchor, message: "expected Block at root of tree after AST transformation")
        }
        ast = topLevel
    }
    
    func testTransform(_ input: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let testDeclarationTransformer = SnapASTTransformerTestDeclaration(shouldRunSpecificTest: shouldRunSpecificTest)
        let output = try testDeclarationTransformer.transform(input)
        testNames = testDeclarationTransformer.testNames
        return output
    }
}
