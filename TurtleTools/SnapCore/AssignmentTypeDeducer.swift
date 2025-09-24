//
//  AssignmentTypeDeducer.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/10/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Determine the explicitType of the expression inferred for a var decl
/// If this expression were to be attached to a VarDeclaration then this would
/// be the appropriate explicitType inferred for the variable.
struct AssignmentTypeDeducer {
    let typeChecker: TypeChecker

    init(_ typeChecker: TypeChecker) {
        self.typeChecker = typeChecker
    }

    func explicitTypeExpression(
        varDecl node: VarDeclaration
    ) throws -> Expression {
        let explicitType = try maybeExplicitTypeExpression(varDecl: node)
        guard let explicitType else { throw unableToDeduceType(varDecl: node) }
        return explicitType
    }

    private func unableToDeduceType(varDecl node: VarDeclaration) -> CompilerError {
        CompilerError(
            sourceAnchor: node.identifier.sourceAnchor,
            format: "unable to deduce type of %@ `%@'",
            node.isMutable ? "variable" : "constant",
            node.identifier.identifier
        )
    }

    private func maybeExplicitTypeExpression(
        varDecl node: VarDeclaration
    ) throws -> Expression? {
        let rtypeExpr = try rtypeExpr(varDecl: node)

        guard let ltypeExpr0 = node.explicitType else {
            return rtypeExpr
        }

        let ltype0 = try typeChecker.check(expression: ltypeExpr0)
        let ltypeExpr1 =
            if ltype0.isArrayType, ltype0.arrayCount == nil {
                rtypeExpr
            }
            else {
                ltypeExpr0
            }

        return ltypeExpr1
    }

    private func rtypeExpr(varDecl node: VarDeclaration) throws -> Expression? {
        guard let expr = node.expression else { return nil }

        // Simplify the type expression where we can obviously avoid a TypeOf
        // expression. This avoids issues where the argument to TypeOf no longer
        // type checks after various lowering steps have been applied. We do not
        // necessarily want to lower the argument to TypeOf itself, though, as
        // this may introduce temporary variables in a context which is only
        // evaluated at compile-time.
        let type0: Expression =
            switch expr {
            case let expr as StructInitializer:
                expr.expr
            case let expr as As where !(expr.targetType is ArrayType):
                expr.targetType
            default:
                try typeChecker.check(
                    expression: TypeOf(
                        sourceAnchor: expr.sourceAnchor,
                        expr: expr
                    )
                )
                .lift
            }

        // The explicit type must account for immutability of the variable too.
        let type1 =
            if node.isMutable {
                type0
            }
            else {
                type0.withConstType()
            }
        return type1
    }
}

private extension Expression {
    func withConstType() -> ConstType {
        if let self = self as? ConstType {
            self
        }
        else {
            ConstType(
                sourceAnchor: sourceAnchor,
                typ: self
            )
        }
    }
}

public extension VarDeclaration {
    func inferExplicitType(
        _ typeChecker: TypeChecker
    ) throws -> VarDeclaration {
        if explicitType == nil {
            try withExplicitType(
                AssignmentTypeDeducer(typeChecker)
                    .explicitTypeExpression(
                        varDecl: self
                    )
            )
        }
        else {
            self
        }
    }

    func breakOutInitialAssignment() -> Seq {
        if let expression {
            Seq(
                sourceAnchor: sourceAnchor,
                children: [
                    withExpression(nil),
                    Assignment(
                        sourceAnchor: sourceAnchor,
                        lexpr: identifier,
                        rexpr: expression
                    )
                ]
            )
        }
        else {
            Seq(sourceAnchor: sourceAnchor, children: [self])
        }
    }
}
