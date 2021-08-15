//
//  SnapSubcompilerIf.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerIf: NSObject {
    public func compile(if node: If, symbols: SymbolTable, labelMaker: LabelMaker) throws -> Seq {
        let s = node.sourceAnchor
        var children: [AbstractSyntaxTreeNode] = []
        let condition = Expression.As(sourceAnchor: node.condition.sourceAnchor,
                                              expr: node.condition,
                                              targetType: Expression.PrimitiveType(.bool))
        try RvalueExpressionTypeChecker(symbols: symbols).check(expression: condition)
        if let elseBranch = node.elseBranch {
            let labelElse = labelMaker.next()
            let labelTail = labelMaker.next()
            children += [
                GotoIfFalse(sourceAnchor: s,
                            condition: condition,
                            target: labelElse),
                node.thenBranch,
                Goto(sourceAnchor: s, target: labelTail),
                LabelDeclaration(sourceAnchor: s, identifier: labelElse),
                elseBranch,
                LabelDeclaration(sourceAnchor: s, identifier: labelTail)
            ]
        } else {
            let labelTail = labelMaker.next()
            children += [
                GotoIfFalse(sourceAnchor: s,
                            condition: condition,
                            target: labelTail),
                node.thenBranch,
                LabelDeclaration(sourceAnchor: s, identifier: labelTail)
            ]
        }
        return Seq(sourceAnchor: s, children: children)
    }
}
