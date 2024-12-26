//
//  CompilerPassEraseMethodCalls.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/25/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Method calls written in the dot syntax are rewritten to plain function calls
public class CompilerPassEraseMethodCalls: CompilerPassWithDeclScan {
#if false // TODO: enable this block of code after adopting vtablesPass() and implForPass()
    override func scan(trait node: TraitDeclaration) throws {
        // TODO: remove the scan(trait:) override when we change the super class to replace SnapSubcompilerTraitDeclaration with TraitScanner
        try TraitScanner(globalEnvironment: globalEnvironment, symbols: symbols!)
            .scan(trait: node)
    }
    
    override func scan(impl node: Impl) throws {
        // TODO: remove the scan(impl:) override when we change the super class to replace SnapSubcompilerImpl with ImplScanner
        try ImplScanner(globalEnvironment: globalEnvironment, symbols: symbols!)
            .scan(impl: node)
    }
    
    override func scan(implFor node: ImplFor) throws {
        // TODO: remove the scan(impl:) override when we change the super class to replace SnapSubcompilerImplFor with ImplForScanner
        try ImplForScanner(globalEnvironment: globalEnvironment, symbols: symbols!)
            .scan(implFor: node)
    }
#endif
    
    var typeChecker: RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
    }
    
    public override func visit(call node0: Expression.Call) throws -> Expression? {
        // A method call looks like a Call expression where the callee is a Get
        // expression, the Get expression itself resolves to a function on the
        // struct, the Get expression's object is an instance of a struct.
        guard let getExpr = node0.callee as? Expression.Get,
              !isTypeName(expr: getExpr.expr),
              let structTyp = try typeChecker.check(expression: getExpr.expr).maybeUnwrapStructType(),
              let fnTyp = try typeChecker.check(expression: getExpr).maybeUnwrapFunctionType() else {
            return node0
        }
        
        // Additional requirements for a rewritable method call are that the
        // number of arguments accepted by the function is exactly one more than
        // the number of arguments given in the call expression, (The object is
        // given by the Get expression.) and the object may be implicitly
        // converted to the type of the first function paramter.
        // TODO: While these requirements match those in StructMemberFunctionCallMatcher and rewriteStructMemberFunctionCallIfPossible, I'm not sure right now if that's the right approach to take. Maybe remove these conditions. Also, remove StructMemberFunctionCallMatcher and rewriteStructMemberFunctionCallIfPossible in favor of having this compiler pass do all struct method call erasure.
        guard fnTyp.arguments.count == (node0.arguments.count+1),
              typeChecker.areTypesAreConvertible(
                ltype: fnTyp.arguments[0],
                rtype: try typeChecker.check(expression: getExpr.expr),
                isExplicitCast: false) else {
            return node0
        }
        
        return node0
            .withCallee(Expression.Get(
                expr: Expression.Identifier(
                    sourceAnchor: node0.sourceAnchor,
                    identifier: structTyp.name),
                member: getExpr.member))
            .inserting(arguments: [getExpr.expr], at: 0)
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
}

extension AbstractSyntaxTreeNode {
    /// Method calls written in the dot syntax are rewritten to plain function calls
    public func eraseMethodCalls(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseMethodCalls(globalEnvironment: globalEnvironment).run(self)
    }
}
