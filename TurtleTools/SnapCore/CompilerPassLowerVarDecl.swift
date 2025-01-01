//
//  CompilerPassLowerVarDecl.swift
//  SnapCore
//
//  Created by Andrew Fox on 1/1/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase VarDeclaration (e.g., var and let)
public class CompilerPassLowerVarDecl: CompilerPassWithDeclScan {
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        // Our super class wants to return the VarDeclaration unmodified after
        // scanning it and updating the environment with the new symbol. Here,
        // however, we need to lower the node to include the appropriate
        // assignment expression.
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
        let assignment = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            globalEnvironment: globalEnvironment)
            .compile(node1)
        var children: [AbstractSyntaxTreeNode] = [
            node1.withExpression(nil)
        ]
        if let assignment {
            children.append(assignment)
        }
        let seq = Seq(sourceAnchor: node0.sourceAnchor, children: children)
        return seq
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase VarDeclaration (e.g., var and let)
    public func lowerVarDeclPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassLowerVarDecl(globalEnvironment: globalEnvironment).run(self)
    }
}
