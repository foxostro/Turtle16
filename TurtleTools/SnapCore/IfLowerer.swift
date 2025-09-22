//
//  IfLowerer.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public struct IfLowerer {
    public init() {}

    public func compile(if node: If, symbols: Env) throws -> Seq {
        let s = node.sourceAnchor
        var children: [AbstractSyntaxTreeNode] = []
        let condition = As(
            sourceAnchor: node.condition.sourceAnchor,
            expr: node.condition,
            targetType: PrimitiveType(.bool)
        )
        try RvalueExpressionTypeChecker(symbols: symbols).check(expression: condition)
        if let elseBranch = node.elseBranch {
            let labelElse = symbols.nextLabel()
            let labelTail = symbols.nextLabel()
            children += [
                GotoIfFalse(
                    sourceAnchor: s,
                    condition: condition,
                    target: labelElse
                ),
                node.thenBranch,
                Goto(sourceAnchor: s, target: labelTail),
                LabelDeclaration(sourceAnchor: s, identifier: labelElse),
                elseBranch,
                LabelDeclaration(sourceAnchor: s, identifier: labelTail)
            ]
        }
        else {
            let labelTail = symbols.nextLabel()
            children += [
                GotoIfFalse(
                    sourceAnchor: s,
                    condition: condition,
                    target: labelTail
                ),
                node.thenBranch,
                LabelDeclaration(sourceAnchor: s, identifier: labelTail)
            ]
        }
        return Seq(sourceAnchor: s, children: children)
    }
}