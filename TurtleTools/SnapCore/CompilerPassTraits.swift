//
//  CompilerPassTraits.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to emit vtable and such for traits
// TODO: This compiler pass ought also rewrite expressions to erase traits completely
public class CompilerPassTraits: CompilerPassWithDeclScan {
    override func scan(trait node: TraitDeclaration) throws {
        // TODO: remove the scan(trait:) override when we change the super class to replace SnapSubcompilerTraitDeclaration with TraitScanner
        let scanner = TraitScanner(globalEnvironment: globalEnvironment, symbols: symbols!)
        try scanner.scan(trait: node)
    }
    
    public override func visit(trait traitDecl0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        assert(!traitDecl0.isGeneric)
        let traitDecl1 = try super.visit(trait: traitDecl0) as! TraitDeclaration
        let traitType = try symbols!.resolveType(identifier: traitDecl1.identifier.identifier).unwrapTraitType()
        let vtableDecl = traitType
            .vtableStructDeclaration
            .withSourceAnchor(traitDecl1.sourceAnchor)
            .withVisibility(traitDecl1.visibility)
        let voidPtr = Expression.PointerType(Expression.PrimitiveType(.void))
        let vtableType = Expression.PointerType(Expression.ConstType(Expression.Identifier(traitDecl1.nameOfVtableType)))
        let traitObjectDecl = StructDeclaration(
            sourceAnchor: traitDecl1.sourceAnchor,
            identifier: Expression.Identifier(
                sourceAnchor: traitDecl1.identifier.sourceAnchor,
                identifier: traitDecl1.nameOfTraitObjectType),
            members: [
                StructDeclaration.Member(name: "object", type: voidPtr),
                StructDeclaration.Member(name: "vtable", type: vtableType)
            ],
            visibility: traitDecl1.visibility,
            isConst: true)
        let seq = Seq(children: [
            traitDecl1,
            vtableDecl,
            traitObjectDecl
        ])
        return seq
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to emit vtable and such for traits
    public func traitsPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassTraits(globalEnvironment: globalEnvironment).run(self)
    }
}
