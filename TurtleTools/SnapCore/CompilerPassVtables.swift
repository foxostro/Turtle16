//
//  CompilerPassTraits.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/9/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to emit vtable and such for traits
// TODO: Add another compiler pass after the implForInPass() to erase traits. This one would rewrite expressions that refer to traits and would erase the trait declarations themselves.
public class CompilerPassVtables: CompilerPassWithDeclScan {
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
    public func vtablesPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassVtables(globalEnvironment: globalEnvironment).run(self)
    }
}
