//
//  SnapAbstractSyntaxTreeCompilerImplPass.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

// Compiles an Abstract Syntax Tree to another, simpler AST and symbol table.
// Accepts an AST and walks the tree. For each matched node, it may rewrite
// that node in terms of simpler concepts, and it may update the symbol table
// to record additional information derived from the program.
//
// SnapAbstractSyntaxTreeCompilerImplPass delegates most the specific work to
// various subcompilers classes.
public class SnapAbstractSyntaxTreeCompilerImplPass: CompilerPassWithDeclScan {
    public override func visit(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        try RvalueExpressionTypeChecker(symbols: symbols!, globalEnvironment: globalEnvironment).check(expression: node)
        return node
    }
    
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
    
    public override func visit(if node0: If) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerIf().compile(
            if: node0,
            symbols: symbols!,
            labelMaker: globalEnvironment.labelMaker)
        let node2 = try super.visit(node1)
        return node2
    }
    
    public override func visit(while node0: While) throws -> AbstractSyntaxTreeNode? {
        let node1 = try SnapSubcompilerWhile().compile(
            while: node0,
            symbols: symbols!,
            labelMaker: globalEnvironment.labelMaker)
        let node2 = try super.visit(node1)
        return node2
    }
    
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        node // We defer compilation of the function body until later.
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
    // Rewrite higher-level nodes in terms of trees of lower-level nodes
    public func implPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        let result = try SnapAbstractSyntaxTreeCompilerImplPass(globalEnvironment: globalEnvironment).run(self)
        return result
    }
}
