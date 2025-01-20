//
//  SnapSubcompilerWhile.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerWhile: NSObject {
    public func compile(while node: While, symbols: SymbolTable) throws -> Seq {
        let s = node.sourceAnchor
        let condition = Expression.As(sourceAnchor: node.condition.sourceAnchor,
                                              expr: node.condition,
                                      targetType: Expression.PrimitiveType(.bool))
        try RvalueExpressionTypeChecker(symbols: symbols).check(expression: condition)
        let labelHead = symbols.nextLabel()
        let labelTail = symbols.nextLabel()
        return Seq(sourceAnchor: s, children: [
            LabelDeclaration(sourceAnchor: s, identifier: labelHead),
            GotoIfFalse(sourceAnchor: s,
                        condition: condition,
                        target: labelTail),
            node.body,
            Goto(sourceAnchor: s, target: labelHead),
            LabelDeclaration(sourceAnchor: s, identifier: labelTail)
        ])
    }
}
