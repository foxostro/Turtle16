//
//  SnapSubcompilerAssert.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerAssert: NSObject {
    public func compile(_ symbols: SymbolTable?, _ node: Assert) throws -> If {
        let s = node.sourceAnchor
        let panic = Expression.Call(
            sourceAnchor: s,
            callee: Expression.Identifier("__panic"),
            arguments: [Expression.LiteralString(node.finalMessage)])
        let then = Block(
            symbols: SymbolTable(parent: symbols),
            children: [panic])
        let condition = Expression.Binary(
            sourceAnchor: s,
            op: .eq,
            left: node.condition,
            right: Expression.LiteralBool(false))
        let result = If(
            sourceAnchor: s,
            condition: condition,
            then: then,
            else: nil)
        return result
    }
}
