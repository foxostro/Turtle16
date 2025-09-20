//
//  CompilerPassForIn.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/10/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Discrete compiler pass to lower and erase ForIn statements
public final class CompilerPassForIn: CompilerPass {
    public override func visit(forIn node0: ForIn) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(forIn: node0) as! ForIn

        let sequence = Identifier(
            sourceAnchor: node1.sourceAnchor,
            identifier: symbols!.tempName(prefix: "__sequence")
        )
        let index = Identifier(
            sourceAnchor: node1.sourceAnchor,
            identifier: symbols!.tempName(prefix: "__index")
        )
        let limit = Identifier(
            sourceAnchor: node1.sourceAnchor,
            identifier: symbols!.tempName(prefix: "__limit")
        )
        let count = Identifier(sourceAnchor: node1.sourceAnchor, identifier: "count")
        let usize = PrimitiveType(.u16) // TODO: This should use `usize' instead of assuming `u16'.
        let zero = LiteralInt(sourceAnchor: node1.sourceAnchor, value: 0)
        let one = LiteralInt(sourceAnchor: node1.sourceAnchor, value: 1)

        let grandparent = Env(parent: symbols)
        let parent = Env(parent: grandparent)
        let inner = Env(parent: parent)

        let body = node1.body.withSymbols(inner)

        let ast = Block(
            sourceAnchor: node1.sourceAnchor,
            symbols: grandparent,
            children: [
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: sequence,
                    explicitType: nil,
                    expression: node1.sequenceExpr,
                    storage: .automaticStorage(offset: nil),
                    isMutable: false
                ),
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: index,
                    explicitType: usize,
                    expression: zero,
                    storage: .automaticStorage(offset: nil),
                    isMutable: true
                ),
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: limit,
                    explicitType: usize,
                    expression: Get(
                        expr: sequence,
                        member: count
                    ),
                    storage: .automaticStorage(offset: nil),
                    isMutable: true
                ),
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: node1.identifier,
                    explicitType: MutableType(
                        sourceAnchor: node1.sourceAnchor,
                        typ: TypeOf(
                            sourceAnchor: node1.sourceAnchor,
                            expr: Subscript(
                                sourceAnchor: node1.sourceAnchor,
                                subscriptable: sequence,
                                argument: zero
                            )
                        )
                    ),
                    expression: nil,
                    storage: .automaticStorage(offset: nil),
                    isMutable: true
                ),
                While(
                    sourceAnchor: node1.sourceAnchor,
                    condition: Binary(
                        sourceAnchor: node1.sourceAnchor,
                        op: .ne,
                        left: index,
                        right: limit
                    ),
                    body: Block(
                        sourceAnchor: node1.sourceAnchor,
                        symbols: parent,
                        children: [
                            Assignment(
                                sourceAnchor: node1.sourceAnchor,
                                lexpr: node1.identifier,
                                rexpr: Subscript(
                                    sourceAnchor: node1.sourceAnchor,
                                    subscriptable: sequence,
                                    argument: index
                                )
                            ),
                            body,
                            Assignment(
                                sourceAnchor: node1.sourceAnchor,
                                lexpr: index,
                                rexpr: Binary(
                                    op: .plus,
                                    left: index,
                                    right: one
                                )
                            )
                        ]
                    )
                )
            ]
        )

        return ast.reconnect(parent: symbols)
    }
}

public extension AbstractSyntaxTreeNode {
    /// Lower and rewrite ForIn statements
    func forInPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassForIn().run(self)
    }
}
