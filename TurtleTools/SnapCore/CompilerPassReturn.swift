//
//  CompilerPassReturn.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "return" statements
public final class CompilerPassReturn: CompilerPassWithDeclScan {
    public override func visit(return node0: Return) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(return: node0) as! Return
        let subcompiler = SnapSubcompilerReturn(symbols!)
        let node2 = try subcompiler.compile(node1)
        return node2
    }
}

public extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "return" statements
    func returnPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassReturn().run(self)
    }
}
