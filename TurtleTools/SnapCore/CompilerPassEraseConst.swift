//
//  CompilerPassEraseConst.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/13/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

public final class CompilerPassEraseConst: CompilerPassWithDeclScan {
    public override func visit(constType e: ConstType) throws -> Expression? {
        try visit(expr: e.typ)
    }
    
    public override func visit(
        primitiveType expr0: PrimitiveType
    ) throws -> Expression? {
        let expr1 = try super.visit(primitiveType: expr0)
        guard let expr1 = expr1 as? PrimitiveType else { return expr1 }
        let expr2 = expr1.withType(expr1.typ.eraseConst())
        return expr2
    }
    
    public override func visit(
        varDecl node0: VarDeclaration
    ) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(varDecl: node0)
        guard let node1 = node1 as? VarDeclaration else { return node1 }
        let node2 = node1.withMutable(true)
        return node2
    }
    
    public override func visit(
        struct node0: StructDeclaration
    ) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(struct: node0)
        guard let node1 = node1 as? StructDeclaration else { return node1 }
        let node2 = node1.withConst(false)
        return node2
    }
}

extension AbstractSyntaxTreeNode {
    /// Rewrite the program to erase all Const types
    /// We assume the program has been type checked before this point and
    /// contains no const-related type checking errors.
    public func eraseConst() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassEraseConst().run(self)
    }
}

