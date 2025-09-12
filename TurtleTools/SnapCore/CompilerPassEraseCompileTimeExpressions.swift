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
        As(
            sourceAnchor: node.sourceAnchor,
            expr: LiteralInt(
                sourceAnchor: node.sourceAnchor,
                value: memoryLayoutStrategy.sizeof(
                    type: try rvalueContext.check(
                        expression: node.expr
                    )
                )
            ),
            targetType: PrimitiveType(
                sourceAnchor: node.sourceAnchor,
                typ: .u16
            )
        )
    }
    
    public override func visit(expr: Expression) throws -> Expression? {
        if context == .type || context == .value {
            let resultType = try rvalueContext.check(expression: expr)
            switch resultType {
            case .arithmeticType(let typ):
                if case .compTimeInt(let value) = typ {
                    return LiteralInt(
                        sourceAnchor: expr.sourceAnchor,
                        value: value
                    )
                }
            case .booleanType(let typ):
                if case .compTimeBool(let value) = typ {
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
}

extension AbstractSyntaxTreeNode {
    /// Erase expressions which are to be evaluated at compile-time
    /// This includes `Is`, `TypeOf`, and `SizeOf` nodes.
    public func eraseCompileTimeExpressions(
        _ m: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) throws -> AbstractSyntaxTreeNode? {
        let result = try CompilerPassEraseCompileTimeExpressions(
            memoryLayoutStrategy: m
        )
            .run(self)
        return result
    }
}
