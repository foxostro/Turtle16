//
//  CompilerPassEraseCompileTimeExpressions.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/11/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Erase expressions which are to be evaluated at compile-time
/// This includes `Is`, `TypeOf`, and `SizeOf` nodes.
public final class CompilerPassEraseCompileTimeExpressions: CompilerPassWithDeclScan {
    private let usize: SymbolType =
        .u16 // TODO: The type to use for `usize` should be determined by policy at a higher level

    public override func visit(is node: Is) throws -> Expression? {
        let exprType = try rvalueContext.check(expression: node.expr)

        // `Is` compiles to a dynamic type check in a subsequent compiler pass
        // when applied to a union type.
        guard !exprType.isUnionType else { return node }

        let testType = try typeContext.check(expression: node.testType)
        let result = LiteralBool(
            sourceAnchor: node.sourceAnchor,
            value: exprType == testType
        )
        return result
    }

    public override func visit(typeof node: TypeOf) throws -> Expression? {
        try rvalueContext.check(expression: node)
            .lift
            .withSourceAnchor(node.sourceAnchor)
    }

    public override func visit(sizeof node: SizeOf) throws -> Expression? {
        try As(
            sourceAnchor: node.sourceAnchor,
            expr: LiteralInt(
                sourceAnchor: node.sourceAnchor,
                value: memoryLayoutStrategy.sizeof(
                    type: rvalueContext.check(
                        expression: node.expr
                    )
                )
            ),
            targetType: PrimitiveType(
                sourceAnchor: node.sourceAnchor,
                typ: usize
            )
        )
    }

    public override func visit(expr: Expression) throws -> Expression? {
        if context == .type || context == .value {
            let resultType = try rvalueContext.check(expression: expr)
            switch resultType {
            case let .arithmeticType(typ):
                if case let .compTimeInt(value) = typ {
                    return LiteralInt(
                        sourceAnchor: expr.sourceAnchor,
                        value: value
                    )
                }
            case let .booleanType(typ):
                if case let .compTimeBool(value) = typ {
                    return LiteralBool(
                        sourceAnchor: expr.sourceAnchor,
                        value: value
                    )
                }
            default:
                break
            }
        }
        return try super.visit(expr: expr)
    }

    public override func visit(get node0: Get) throws -> Expression? {
        switch try rvalueContext.check(expression: node0.expr) {
        case .array(let count, elementType: _) where count != nil:
            As(
                sourceAnchor: node0.expr.sourceAnchor,
                expr: LiteralInt(
                    sourceAnchor: node0.expr.sourceAnchor,
                    value: count!
                ),
                targetType: PrimitiveType(
                    sourceAnchor: node0.expr.sourceAnchor,
                    typ: usize
                )
            )

        default:
            node0
        }
    }
}

public extension AbstractSyntaxTreeNode {
    /// Erase expressions which are to be evaluated at compile-time
    /// This includes `Is`, `TypeOf`, and `SizeOf` nodes.
    func eraseCompileTimeExpressions(
        _ m: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) throws -> AbstractSyntaxTreeNode? {
        let result = try CompilerPassEraseCompileTimeExpressions(
            memoryLayoutStrategy: m
        )
        .run(self)
        return result
    }
}
