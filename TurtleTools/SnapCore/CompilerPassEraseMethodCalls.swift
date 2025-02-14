//
//  CompilerPassEraseMethodCalls.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/25/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Method calls written in the dot syntax are rewritten to plain function calls
public final class CompilerPassEraseMethodCalls: CompilerPassWithDeclScan {
    var typeChecker: RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
    }
    
    public override func visit(get node0: Expression.Get) throws -> Expression? {
        guard !isTypeName(expr: node0.expr),
              let structTyp = try maybeUnwrapStructType(node0),
              let _ = try typeChecker.check(expression: node0).maybeUnwrapFunctionType() else {
            return node0
        }
        let node1 = Expression.Get(
            sourceAnchor: node0.sourceAnchor,
            expr: Expression.Identifier(
                sourceAnchor: node0.sourceAnchor,
                identifier: structTyp.name),
            member: node0.member)
        return node1
    }
    
    public override func visit(call node0: Expression.Call) throws -> Expression? {
        // A method call looks like a Call expression where the callee is a Get
        // expression, the Get expression itself resolves to a function on the
        // struct, the Get expression's object is an instance of a struct.
        guard let getExpr = node0.callee as? Expression.Get else {
            return node0
        }
        guard !isTypeName(expr: getExpr.expr),
              let structTyp = try maybeUnwrapStructType(getExpr),
              !structTyp.isModule,
              let fnTyp = try typeChecker.check(expression: getExpr).maybeUnwrapFunctionType() else {
            return node0
        }
        
        let node1 = node0
            .withCallee(Expression.Get(
                expr: Expression.Identifier(
                    sourceAnchor: node0.sourceAnchor,
                    identifier: structTyp.name),
                member: getExpr.member))
        
        // Additional requirements for a method call are that the number of
        // arguments accepted by the function is exactly one more than the
        // number of arguments given in the call expression, (The object is
        // given by the Get expression.) and the object may be implicitly
        // converted to the type of the first function paramter.
        // TODO: While these requirements match those in StructMemberFunctionCallMatcher and rewriteStructMemberFunctionCallIfPossible, I'm not sure right now if that's the right approach to take. Maybe remove these conditions. Also, remove StructMemberFunctionCallMatcher and rewriteStructMemberFunctionCallIfPossible in favor of having this compiler pass do all struct method call erasure.
        guard fnTyp.arguments.count == (node0.arguments.count+1),
              typeChecker.areTypesAreConvertible(
                ltype: fnTyp.arguments[0],
                rtype: try typeChecker.check(expression: getExpr.expr),
                isExplicitCast: false) else {
            return node1
        }
        
        let node2 = node1.inserting(arguments: [getExpr.expr], at: 0)
        return node2
    }
    
    func isTypeName(expr: Expression) -> Bool {
        if let ident = expr as? Expression.Identifier,
           let symbols = symbols,
           let _ = symbols.maybeResolveType(identifier: ident.identifier) {
            true
        }
        else {
            false
        }
    }
    
    func maybeUnwrapStructType(_ getExpr: Expression.Get) throws -> StructType? {
        switch try typeChecker.check(expression: getExpr.expr) {
        case .constStructType(let typ), .structType(let typ),
             .constPointer(.constStructType(let typ)), .constPointer(.structType(let typ)),
             .pointer(.constStructType(let typ)), .pointer(.structType(let typ)):
            typ
            
        default:
            nil
        }
    }
}

extension AbstractSyntaxTreeNode {
    /// Method calls written in the dot syntax are rewritten to plain function calls
    public func eraseMethodCalls() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseMethodCalls().run(self)
    }
}
