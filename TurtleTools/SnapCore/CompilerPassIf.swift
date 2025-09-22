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
        let node1 = try node0
            .withCondition(condition)
            .withThenBranch(visit(node0.thenBranch)!)
            .withElseBranch(visit(node0.elseBranch))
        let node2 = try IfLowerer().compile(
            if: node1,
            symbols: symbols!
        )
        return node2
    }
}

public extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "if" statements
    func ifPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassIf().run(self)
    }
}
