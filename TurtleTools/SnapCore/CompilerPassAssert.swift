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
    
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(node0) as! VarDeclaration
        let subcompiler = SnapSubcompilerVarDeclaration(symbols: symbols!, globalEnvironment: globalEnvironment)
        let node2 = try subcompiler.compile(node1)
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "assert" statements
    public func assertPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        let node1 = try clearSymbols(globalEnvironment)
        let node2 = try CompilerPassAssert(globalEnvironment: globalEnvironment).run(node1)
        return node2
    }
}
