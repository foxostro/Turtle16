//
//  CompilerPassAssert.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "assert" statements
public class CompilerPassAssert: CompilerPassWithDeclScan {
    public override func visit(assert node0: Assert) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(assert: node0) as! Assert
        let node2 = try SnapSubcompilerAssert().compile(symbols, node1)
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "assert" statements
    public func assertPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassAssert(globalEnvironment: globalEnvironment).run(self)
    }
}
