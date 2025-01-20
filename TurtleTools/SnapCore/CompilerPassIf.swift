//
//  CompilerPassIf.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "if" statements
public class CompilerPassIf: CompilerPassWithDeclScan {
    public override func visit(if node0: If) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerIf().compile(
            if: node0,
            symbols: symbols!)
        let node2 = try super.visit(node1)
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "if" statements
    public func ifPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassIf(globalEnvironment: globalEnvironment).run(self)
    }
}
