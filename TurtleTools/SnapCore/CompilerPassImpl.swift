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
        let node2 = Seq(sourceAnchor: node1.sourceAnchor,
            children: try node1.children.map { child in
            let mangledName = try typ.symbols.resolve(identifier: child.identifier.identifier).type.unwrapFunctionType().mangledName!
            return child.withIdentifier(mangledName)
        })
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
              objectType.isStructType,
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
        try CompilerPassImpl(globalEnvironment: globalEnvironment).run(self)
    }
}
