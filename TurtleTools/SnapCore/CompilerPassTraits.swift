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
        try super.scan(trait: node)
    }
    
    public override func visit(trait node0: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        assert(!node0.isGeneric)
        let node1 = try super.visit(trait: node0)
        return node1
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to emit vtable and such for traits
    public func traitsPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassTraits(globalEnvironment: globalEnvironment).run(self)
    }
}
