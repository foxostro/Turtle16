//
//  CompilerPassLowerVarDecl.swift
//  SnapCore
//
//  Created by Andrew Fox on 1/1/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase VarDeclaration (e.g., var and let)
public final class CompilerPassLowerVarDecl: CompilerPassWithDeclScan {
    
    /// Replace each VarDeclaration with 1) a VarDeclaration that has no
    /// expression and simply updates the symbol table, and 2) an assignment if
    /// there was an expression.
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = VarDeclaration(
            sourceAnchor: node0.sourceAnchor,
            identifier: try visit(identifier: node0.identifier) as! Identifier,
            explicitType: try node0.explicitType.flatMap {
                try visit(expr: $0)
            },
            expression: try node0.expression.flatMap {
                try visit(expr: $0)
            },
            storage: node0.storage,
            isMutable: node0.isMutable,
            visibility: node0.visibility)
        
        let assignmentExpr = try SnapSubcompilerVarDeclaration(
            symbols: symbols!,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy)
        .compile(node1)
        
        if let assignmentExpr {
            _ = try rvalueContext.check(assignment: assignmentExpr)
        }
        
        guard let explicitType = try explicitTypeExpression(varDecl: node1) else {
            throw unableToDeduceType(varDecl: node1)
        }
        
        let node2 = node1
            .withExpression(nil)
            .withExplicitType(explicitType)
        
        var children: [AbstractSyntaxTreeNode] = [
            node2
        ]
        if let assignmentExpr {
            children.append(assignmentExpr)
        }
        let seq = Seq(sourceAnchor: node0.sourceAnchor, children: children)
        return seq
    }
    
    fileprivate func unableToDeduceType(varDecl node: VarDeclaration) -> CompilerError {
        CompilerError(
            sourceAnchor: node.identifier.sourceAnchor,
            format: "unable to deduce type of %@ `%@'",
            node.isMutable ? "variable" : "constant",
            node.identifier.identifier)
    }
    
    fileprivate func explicitTypeExpression(varDecl node: VarDeclaration) throws -> Expression? {
        let rtypeExpr = rtypeExpr(varDecl: node)
        
        guard let ltypeExpr0 = node.explicitType else {
            return rtypeExpr
        }
        
        let ltype0 = try typeContext.check(expression: ltypeExpr0)
        let ltypeExpr1 = if ltype0.isArrayType && ltype0.arrayCount == nil {
            rtypeExpr
        }
        else {
            ltypeExpr0
        }
        
        return ltypeExpr1
    }
    
    fileprivate func rtypeExpr(varDecl node: VarDeclaration) -> Expression? {
        guard let expr = node.expression else { return nil }
        let type0 = TypeOf(
            sourceAnchor: expr.sourceAnchor,
            expr: expr)
        let type1 = if node.isMutable {
            type0
        } else {
            ConstType(
                sourceAnchor: type0.sourceAnchor,
                typ: type0)
        }
        return type1
    }
}

extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase VarDeclaration (e.g., var and let)
    public func lowerVarDeclPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassLowerVarDecl().run(self)
    }
}
