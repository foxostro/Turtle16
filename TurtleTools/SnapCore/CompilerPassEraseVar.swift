//
//  CompilerPassEraseVar.swift
//  SnapCore
//
//  Created by Andrew Fox on 1/1/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase VarDeclaration (e.g., var and let)
public class CompilerPassEraseVar: CompilerPassWithDeclScan {
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = VarDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: try visit(identifier: node0.identifier) as! Expression.Identifier,
            explicitType: try node0.explicitType.flatMap {
                try visit(expr: $0)
            },
            expression: try node0.expression.flatMap {
                try visit(expr: $0)
            },
            storage: node0.storage,
            isMutable: node0.isMutable,
            visibility: node0.visibility)
        let node2 = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
        .compile(node1)
        return node2
    }
    
    public override func visit(struct node0: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        nil
    }

    public override func visit(typealias node0: Typealias) throws -> AbstractSyntaxTreeNode? {
        nil
    }

    public override func visit(import node0: Import) throws -> AbstractSyntaxTreeNode? {
        nil
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase VarDeclaration (e.g., var and let)
    public func eraseVarPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseVar(globalEnvironment: globalEnvironment).run(self)
    }
}
