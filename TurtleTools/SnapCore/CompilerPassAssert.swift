//
//  CompilerPassAssert.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "assert" statements
public final class CompilerPassAssert: CompilerPassWithDeclScan {
    public override func visit(assert node0: Assert) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(assert: node0) as! Assert
        let s = node1.sourceAnchor
        let panic = Call(
            sourceAnchor: s,
            callee: Identifier("__panic"),
            arguments: [LiteralString(node1.finalMessage)]
        )
        let then = Block(
            symbols: Env(parent: symbols),
            children: [panic]
        )
        let condition = Binary(
            sourceAnchor: s,
            op: .eq,
            left: node1.condition,
            right: LiteralBool(false)
        )
        let node2 = If(
            sourceAnchor: s,
            condition: condition,
            then: then,
            else: nil
        )
        return node2
    }
}

public extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "assert" statements
    func assertPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassAssert().run(self)
    }
}
