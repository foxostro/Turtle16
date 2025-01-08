//
//  CompilerPassImpl.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/24/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase Impl blocks
public class CompilerPassImpl: CompilerPassWithDeclScan {
    
    var typeChecker: RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
    }
    
    public override func visit(impl node0: Impl) throws -> AbstractSyntaxTreeNode? {
        assert(!node0.isGeneric)
        let node1 = try super.visit(impl: node0) as! Impl
        guard let typ = try typeChecker.check(expression: node1.structTypeExpr).maybeUnwrapStructType() else {
            throw CompilerError(
                sourceAnchor: node1.sourceAnchor,
                message: "unsupported expression: \(node1)")
        }
        let children1 = node1.children
        let children2 = try children1
            .map { child0 in
                let mangledName = try typ.symbols.resolve(identifier: child0.identifier.identifier).type.unwrapFunctionType().mangledName!
                let child1 = child0
                    .withIdentifier(mangledName)
                    .withFunctionType(child0.functionType.withName(mangledName))
                return child1
            }
        try children2
            .forEach { child in
                try FunctionScanner(
                    globalEnvironment: globalEnvironment,
                    symbols: symbols!,
                    enclosingImplId: nil)
                .scan(func: child)
            }
        let node2 = Seq(sourceAnchor: node1.sourceAnchor, children: children2)
        return node2
    }
    
    public override func visit(get node0: Expression.Get) throws -> Expression? {
        // If the object is the name of a struct type, and the member is one of
        // the struct's methods, then return a direct reference to the function
        // through the mangled function identifier.
        guard let objectIdent = node0.expr as? Expression.Identifier,
              let objectType = symbols!.maybeResolveType(
                sourceAnchor: objectIdent.sourceAnchor,
                identifier: objectIdent.identifier),
              let structType = objectType.maybeUnwrapStructType(),
              !structType.isModule,
              node0.member is Expression.Identifier,
              let functionType = try typeChecker.check(expression: node0).maybeUnwrapFunctionType(),
              let mangledName = functionType.mangledName else {
            return node0
        }
        return Expression.Identifier(
            sourceAnchor: node0.sourceAnchor,
            identifier: mangledName)
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase Impl blocks
    public func eraseImplPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        let result = try CompilerPassImpl(globalEnvironment: globalEnvironment).run(self)
        return result
    }
}
