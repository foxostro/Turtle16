//
//  CompilerPassIf.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "if" statements
public final class CompilerPassIf: CompilerPassWithDeclScan {
    public override func visit(if node0: If) throws -> AbstractSyntaxTreeNode? {
        let condition = try visit(expr: node0.condition)!
        let conditionType = try rvalueContext.check(expression: condition)
        guard conditionType.isBooleanType else {
            throw CompilerError(
                sourceAnchor: node0.condition.sourceAnchor,
                message: "cannot convert value of type `\(conditionType)' to type `bool'"
            )
        }
        let node1 = node0
            .withCondition(condition)
            .withThenBranch(try visit(node0.thenBranch)!)
            .withElseBranch(try visit(node0.elseBranch))
        let node2 = try SnapSubcompilerIf().compile(
            if: node1,
            symbols: symbols!
        )
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "if" statements
    public func ifPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassIf().run(self)
    }
}
