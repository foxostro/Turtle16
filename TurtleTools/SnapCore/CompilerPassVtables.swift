//
//  CompilerPassTraits.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to emit vtable and such for traits
public class CompilerPassVtables: CompilerPassWithDeclScan {
    public override func visit(trait traitDecl0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        assert(!traitDecl0.isGeneric)
        let traitDecl1 = try super.visit(trait: traitDecl0) as! TraitDeclaration
        let decls = try TraitObjectDeclarationsBuilder().declarations(
            for: traitDecl1,
            symbols: symbols!)
        var children: [AbstractSyntaxTreeNode] = [
            traitDecl1,
            decls.vtableDecl,
            decls.traitObjectDecl
        ]
        if let traitObjectImpl = decls.traitObjectImpl {
            children.append(traitObjectImpl)
        }
        return Seq(children: children)
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to emit vtable and such for traits
    public func vtablesPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassVtables()
        .run(self)
    }
}
