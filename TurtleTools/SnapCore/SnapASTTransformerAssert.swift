//
//  SnapASTTransformerAssert.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerAssert: SnapASTTransformerBase {
    var currentTest: TestDeclaration? = nil
    
    public override func compile(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        currentTest = node
        defer { currentTest = nil }
        return try super.compile(testDecl: node)
    }
    
    public override func compile(assert node: Assert) throws -> AbstractSyntaxTreeNode {
        let s = node.sourceAnchor
        let message: String
        if let currentTest = currentTest {
            message = "\(node.message) in test \"\(currentTest.name)\""
        } else {
            message = node.message
        }
        let panic = Expression.Call(sourceAnchor: s, callee: Expression.Identifier("panic"), arguments: [
            Expression.LiteralString(message)
        ])
        let condition = Expression.Binary(sourceAnchor: s, op: .eq, left: node.condition, right: Expression.LiteralBool(false))
        let result = If(sourceAnchor: s,
                        condition: condition,
                        then: Block(children: [ panic ]),
                        else: nil)
        return result
    }
}
