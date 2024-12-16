//
//  CompilerPassImplFor.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Snap compiler pass to erase ImplFor declarations
/// ImplFor declarations are erased and rewritten in terms of lower-level
/// concepts. The ImplFor AST node is replaced with an appropriate Impl node
/// and an appropriate vtable declaration.
public class CompilerPassImplFor: CompilerPassWithDeclScan {
    /// Each ImplFor node is transformed to an Impl node
    public override func visit(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        Impl(
            sourceAnchor: node.sourceAnchor,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            structTypeExpr: try visit(expr: node.structTypeExpr)!,
            children: try node.children.compactMap {
                try visit($0) as? FunctionDeclaration
            },
            id: node.id)
    }
}

extension AbstractSyntaxTreeNode {
    /// Erase impl-for declarations, rewriting in terms of lower-level concepts
    public func implForPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassImplFor(globalEnvironment: globalEnvironment).run(self)
    }
}
