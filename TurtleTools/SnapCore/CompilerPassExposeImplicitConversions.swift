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
        // the corresponding arguent of the struct initializer expression is not
        // exactly the same type. This ensures the compiler inserts the correct
        // conversion to the union value needed to initialize the struct field.
        let structTypeInfo = try rvalueContext.check(expression: node0.expr).unwrapStructType()
        let node1 = node0.withArguments(
            try node0.arguments.map { arg0 in
                let rtype = try rvalueContext.check(expression: arg0.expr)
                let member = try structTypeInfo.symbols.resolve(identifier: arg0.name)
                let ltype = member.type
                let arg1: StructInitializer.Argument =
                    if rtype == ltype {
                        arg0
                    }
                    else {
                        arg0.withExpr(
                            As(
                                sourceAnchor: arg0.expr.sourceAnchor,
                                expr: arg0.expr,
                                targetType: ltype.lift
                            )
                        )
                    }
                return arg1
            }
        )
        let node2 = try super.visit(structInitializer: node1)
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Insert explicit `As` expressions in places where implicit conversions occur.
    public func exposeImplicitConversions() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassExposeImplicitConversions().run(self)
    }
}
