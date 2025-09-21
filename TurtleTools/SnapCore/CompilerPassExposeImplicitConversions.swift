//
//  CompilerPassExposeImplicitConversions.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/9/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Insert explicit `As` expressions in places where implicit conversions occur.
/// TODO: exposeImplicitConversions() should insert `As` nodes in places for the various implicit
/// conversions which can occur expressions; there are many, and they're not clearly documented
/// anywhere but in the code of the type checker class itself.
public final class CompilerPassExposeImplicitConversions: CompilerPassWithDeclScan {
    public override func visit(return node0: Return) throws -> AbstractSyntaxTreeNode? {
        guard let symbols else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: "internal compiler error: no symbols"
            )
        }

        guard let enclosingFunctionType = symbols.enclosingFunctionType else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: "return is invalid outside of a function"
            )
        }

        let node1 = try super.visit(return: node0)
        guard let node1 = node1 as? Return else {
            throw CompilerError(
                sourceAnchor: node0.sourceAnchor,
                message: """
                    internal compiler error: expected node0 to lower to a Return node
                        node0: \(String(describing: node0))
                        node1: \(String(describing: node1))
                    """
            )
        }

        guard let expr = node1.expression else {
            guard enclosingFunctionType.returnType == .void else {
                throw CompilerError(
                    sourceAnchor: node1.sourceAnchor,
                    message: "non-void function should return a value"
                )
            }

            return node1
        }

        guard enclosingFunctionType.returnType != .void else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "unexpected non-void return value in void function"
            )
        }

        // If the return value has a type that exactly matches the function
        // return type then return the node unmodified.
        let returnExpressionType = try rvalueContext.check(expression: expr)
        guard
            returnExpressionType.correspondingConstType
            != enclosingFunctionType.returnType.correspondingConstType
        else {
            return node1
        }

        // If the type of the return value does not exactly match the function
        // return type then ensure it is implicitly convertible to the return
        // type.
        try rvalueContext.checkTypesAreConvertibleInAssignment(
            ltype: enclosingFunctionType.returnType,
            rtype: returnExpressionType,
            sourceAnchor: node1.sourceAnchor,
            messageWhenNotConvertible: "cannot convert return expression of type `\(returnExpressionType)' to return type `\(enclosingFunctionType.returnType)'"
        )

        let node2 = node1.withExpression(
            As(
                sourceAnchor: expr.sourceAnchor,
                expr: expr,
                targetType: enclosingFunctionType.returnType.lift
            )
        )

        return node2
    }

    public override func visit(structInitializer node0: StructInitializer) throws -> Expression? {
        // First, make sure the struct initializer expression is well-formed.
        _ = try rvalueContext.check(structInitializer: node0)

        // Insert an `As` expression if the struct field has a union type and
        // the corresponding argument of the struct initializer expression isn't
        // exactly the same type. This ensures the compiler inserts the correct
        // conversion to the union value needed to initialize the struct field.
        let structTypeInfo = try rvalueContext.check(expression: node0.expr).unwrapStructType()
        let node1 = try node0.withArguments(
            node0.arguments.map { arg0 in
                let member = try structTypeInfo.symbols.resolve(identifier: arg0.name)
                let ltype = member.type
                let arg1 = try visit(expr: arg0.expr)!
                let arg2 = try arg0.withExpr(conversion(expr: arg1, to: ltype))
                return arg2
            }
        )
        return node1
    }

    private func conversion(
        expr: Expression,
        to ltype: SymbolType
    ) throws -> Expression {
        let rtype = try rvalueContext.check(expression: expr)

        guard rtype != ltype, rtype.correspondingConstType != ltype else {
            return expr
        }

        // In places where we perform an implicit conversion from an object to a
        // pointer to that object, we insert an AddressOf operator instead of an
        // As conversion operator.
        if let pointeeType = ltype.maybeUnwrapPointerType(), pointeeType == rtype {
            return Unary(
                sourceAnchor: expr.sourceAnchor,
                op: .ampersand,
                expression: expr
            )
        }

        return As(
            sourceAnchor: expr.sourceAnchor,
            expr: expr,
            targetType: ltype.lift
        )
    }

    public override func visit(assignment node0: Assignment) throws -> Expression? {
        let lexpr = try visit(expr: node0.lexpr)!
        let lvalueType = try lvalueContext.check(expression: lexpr)!
        guard !lvalueType.isUnionType else { return node0 }
        let node1 = try node0
            .withLexpr(lexpr)
            .withRexpr(
                conversion(
                    expr: visit(expr: node0.rexpr)!,
                    to: lvalueType
                )
            )
        return node1
    }

    public override func visit(get node0: Get) throws -> Expression {
        let objectType = try rvalueContext.check(expression: node0.expr)

        switch objectType {
        case let .structType(typ),
             let .constStructType(typ):
            // TODO: The compiler has special handling of Range.count but maybe it shouldn't
            if let member = node0.member as? Identifier,
               typ.name == "Range", member.identifier == "count" {
                return Binary(
                    sourceAnchor: node0.sourceAnchor,
                    op: .minus,
                    left: Get(
                        sourceAnchor: node0.sourceAnchor,
                        expr: Unary(
                            sourceAnchor: node0.sourceAnchor,
                            op: .ampersand,
                            expression: node0.expr
                        ),
                        member: Identifier("limit")
                    ),
                    right: Get(
                        sourceAnchor: node0.sourceAnchor,
                        expr: Unary(
                            sourceAnchor: node0.sourceAnchor,
                            op: .ampersand,
                            expression: node0.expr
                        ),
                        member: Identifier("begin")
                    )
                )
            }

            let node1 = try node0.withExpr(
                conversion(expr: node0.expr, to: .pointer(objectType))
            )
            return node1

        case .dynamicArray,
             .constDynamicArray:
            let node1 = try node0.withExpr(
                conversion(expr: node0.expr, to: .pointer(objectType))
            )
            return node1

        default:
            return node0
        }
    }

    public override func visit(binary node0: Binary) throws -> Expression? {
        let rightType = try rvalueContext.check(expression: node0.right)
        let leftType = try rvalueContext.check(expression: node0.left)

        guard leftType != rightType else { return node0 }
        guard leftType.isArithmeticType, rightType.isArithmeticType else { return node0 }

        let leftTypeInfo = leftType.unwrapArithmeticType()
        let rightTypeInfo = rightType.unwrapArithmeticType()

        let targetType: SymbolType = .arithmeticType(
            ArithmeticTypeInfo.binaryResultType(
                left: leftTypeInfo,
                right: rightTypeInfo
            )!
        )

        let node1 = try node0
            .withLeft(
                conversion(
                    expr: visit(expr: node0.left)!,
                    to: targetType
                )
            )
            .withRight(
                conversion(
                    expr: visit(expr: node0.right)!,
                    to: targetType
                )
            )

        return node1
    }

    /// Replace each VarDeclaration with 1) a VarDeclaration that has no
    /// expression and simply updates the symbol table, and 2) an assignment if
    /// there was an expression.
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try VarDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: visit(identifier: node0.identifier) as! Identifier,
            explicitType: try node0.explicitType.flatMap {
                try visit(expr: $0)
            },
            expression: node0.expression.flatMap {
                try visit(expr: $0)
            },
            storage: node0.storage,
            isMutable: node0.isMutable,
            visibility: node0.visibility
        )

        let assignmentExpr0 = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(node1)

        if let assignmentExpr0 {
            _ = try rvalueContext.check(assignment: assignmentExpr0)
        }

        let explicitType = try explicitTypeExpression(varDecl: node1)

        let node2 = node1
            .withExpression(nil)
            .withExplicitType(explicitType)

        if let assignmentExpr0 {
            let assignmentExpr1 = try visit(assignment: assignmentExpr0)!
            return Seq(
                sourceAnchor: node2.sourceAnchor,
                children: [
                    node2,
                    assignmentExpr1
                ]
            )
        }
        else {
            return node2
        }
    }

    private func explicitTypeExpression(varDecl node: VarDeclaration) throws -> Expression {
        try AssignmentTypeDeducer(rvalueContext).explicitTypeExpression(varDecl: node)
    }
}

public extension AbstractSyntaxTreeNode {
    /// Insert explicit `As` expressions in places where implicit conversions occur.
    func exposeImplicitConversions() throws -> AbstractSyntaxTreeNode? {
        let result = try CompilerPassExposeImplicitConversions().run(self)
        return result
    }
}
