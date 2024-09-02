//
//  CompilerPassWhile.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "while" statements
public class CompilerPassWhile: CompilerPassWithDeclScan {
    public override func visit(while node0: While) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerWhile().compile(
            while: node0,
            symbols: symbols!,
            labelMaker: globalEnvironment.labelMaker)
        let node2 = try super.visit(node1)
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "while" statements
    public func whilePass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassWhile(globalEnvironment: globalEnvironment).run(self)
    }
}
