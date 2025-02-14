//
//  CompilerPassWhile.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "while" statements
public final class CompilerPassWhile: CompilerPassWithDeclScan {
    public override func visit(while node0: While) throws -> AbstractSyntaxTreeNode? {
        let symbols = symbols!
        let s = node0.sourceAnchor
        let condition = Expression.As(
            sourceAnchor: node0.condition.sourceAnchor,
            expr: node0.condition,
            targetType: Expression.PrimitiveType(.bool))
        try rvalueContext.check(expression: condition)
        let labelHead = symbols.nextLabel()
        let labelTail = symbols.nextLabel()
        let node1 = Seq(sourceAnchor: s, children: [
            LabelDeclaration(sourceAnchor: s, identifier: labelHead),
            GotoIfFalse(sourceAnchor: s,
                        condition: condition,
                        target: labelTail),
            node0.body,
            Goto(sourceAnchor: s, target: labelHead),
            LabelDeclaration(sourceAnchor: s, identifier: labelTail)
        ])
        let node2 = try super.visit(node1)
        return node2
    }
    
    private func rvalueContext() -> RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "while" statements
    public func whilePass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassWhile().run(self)
    }
}
