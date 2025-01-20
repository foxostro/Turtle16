//
//  CompilerPassReturn.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "return" statements
public class CompilerPassReturn: CompilerPassWithDeclScan {
    public override func visit(return node0: Return) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(return: node0) as! Return
        let subcompiler = SnapSubcompilerReturn(symbols!)
        let node2 = try subcompiler.compile(node1)
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "return" statements
    public func returnPass(
        staticStorageFrame: Frame = Frame(),
        memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyNull()
    ) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassReturn(
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .run(self)
    }
}
