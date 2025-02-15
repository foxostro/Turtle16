//
//  SnapSubcompilerAssert.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public struct SnapSubcompilerAssert {
    public init() {}
    
    public func compile(_ symbols: Env?, _ node: Assert) throws -> If {
        let s = node.sourceAnchor
        let panic = Call(
            sourceAnchor: s,
            callee: Identifier("__panic"),
            arguments: [LiteralString(node.finalMessage)])
        let then = Block(
            symbols: Env(parent: symbols),
            children: [panic])
        let condition = Binary(
            sourceAnchor: s,
            op: .eq,
            left: node.condition,
            right: LiteralBool(false))
        let result = If(
            sourceAnchor: s,
            condition: condition,
            then: then,
            else: nil)
        return result
    }
}
