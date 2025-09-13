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
        let condition = try visit(expr: node0.condition)!
        let conditionType = try rvalueContext.check(expression: condition)
        guard conditionType.isBooleanType else {
            throw CompilerError(
                sourceAnchor: node0.condition.sourceAnchor,
                message: "cannot convert value of type `\(conditionType)' to type `bool'"
            )
        }
        let symbols = symbols!
        let s = node0.sourceAnchor
        let labelHead = symbols.nextLabel()
        let labelTail = symbols.nextLabel()
        let node1 = Seq(
            sourceAnchor: s,
            children: [
                LabelDeclaration(sourceAnchor: s, identifier: labelHead),
                GotoIfFalse(
                    sourceAnchor: s,
                    condition: condition,
                    target: labelTail
                ),
                try visit(node0.body)!,
                Goto(sourceAnchor: s, target: labelHead),
                LabelDeclaration(sourceAnchor: s, identifier: labelTail)
            ]
        )
        return node1
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "while" statements
    public func whilePass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassWhile().run(self)
    }
}
