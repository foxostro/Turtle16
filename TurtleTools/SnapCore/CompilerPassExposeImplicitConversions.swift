//
//  CompilerPassExposeImplicitConversions.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/9/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Insert explicit `As` expressions in places where implicit conversions occur.
/// TODO: exposeImplicitConversions() should insert `As` nodes in places where an implicit conversion occurs. It's most important to focus first on implicit conversions involving union types because this will unblock the eraseUnions() compiler pass. After that, insert explicit conversions for assignment expressions. After that, insert explicit conversions for the various implicit conversions which can occur in other expressions; there are many, and they're not clearly documents anywhere but in the code of the type checker class itself.
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
        guard returnExpressionType.correspondingConstType != enclosingFunctionType.returnType.correspondingConstType else {
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
        let node1 = node0.withArguments(
            try node0.arguments.map { arg0 in
                let member = try structTypeInfo.symbols.resolve(identifier: arg0.name)
                let ltype = member.type
                let arg1 = arg0.withExpr(
                    try conversion(expr: arg0.expr, to: ltype)
                )
                return arg1
            }
        )
        let node2 = try super.visit(structInitializer: node1)
        return node2
    }
    
    private func conversion(
        expr: Expression,
        to ltype: SymbolType
    ) throws -> Expression {
        let rtype = try rvalueContext.check(expression: expr)
        
        guard rtype != ltype else { return expr }
        
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
        let rexpr = try visit(expr: node0.rexpr)!
        let node1 = node0.withRexpr(
            try conversion(expr: rexpr, to: lvalueType)
        )
        return node1
    }
    
    public override func visit(get node0: Get) throws -> Expression {
        let objectType = try rvalueContext.check(expression: node0.expr)
        guard let typ = objectType.maybeUnwrapStructType() else { return node0 }
        
        // TODO: The compiler has special handling of Range.count but maybe it shouldn't
        if let member = node0.member as? Identifier,
           typ.name == "Range", member.identifier == "count" {
            
            return Binary(
                sourceAnchor: node0.sourceAnchor,
                op: .minus,
                left: Get(
                    sourceAnchor: node0.sourceAnchor,
                    expr: node0.expr,
                    member: Identifier("limit")
                ),
                right: Get(
                    sourceAnchor: node0.sourceAnchor,
                    expr: node0.expr,
                    member: Identifier("begin")
                )
            )
        }
        
        let node1 = node0.withExpr(
            try conversion(expr: node0.expr, to: .pointer(objectType))
        )
        return node1
    }
    
    public override func visit(binary node: Binary) throws -> Expression? {
        let rightType = try rvalueContext.check(expression: node.right)
        let leftType = try rvalueContext.check(expression: node.left)

        if leftType.isArithmeticType && rightType.isArithmeticType {
            return try visitBinaryArithmeticExpression(node)
        }
        else if leftType.isBooleanType && rightType.isBooleanType {
            return node
        }
        else {
            throw CompilerError(
                sourceAnchor: node.sourceAnchor,
                message: "internal compiler error: invalid binary expression should have been rejected before this point: \(node)"
            )
        }
    }
    
    private func visitBinaryArithmeticExpression(_ node: Binary) throws -> Binary {
        let rightType = try rvalueContext.check(expression: node.right)
        let leftType = try rvalueContext.check(expression: node.left)
        
        guard leftType != rightType else { return node }
        
        let leftTypeInfo = leftType.unwrapArithmeticType()
        let rightTypeInfo = rightType.unwrapArithmeticType()
        
        let targetType: SymbolType = .arithmeticType(
            ArithmeticTypeInfo.binaryResultType(
                left: leftTypeInfo,
                right: rightTypeInfo
            )!
        )
        
        return node
            .withLeft(
                try conversion(
                    expr: try visit(expr: node.left)!,
                    to: targetType
                )
            )
            .withRight(
                try conversion(
                    expr: try visit(expr: node.right)!,
                    to: targetType
                )
            )
    }
}

extension AbstractSyntaxTreeNode {
    /// Insert explicit `As` expressions in places where implicit conversions occur.
    public func exposeImplicitConversions() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassExposeImplicitConversions().run(self)
    }
}
