//
//  CompilerPassMaterializationEscapeAnalysis.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/10/25.
//  Copyright © 2025 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Mark eligible variables with the "register" storage class
///
/// Variables with the "regsister" storage class are mapped directly to a Tack
/// register and are never directly stored or loaded from memory.
///
/// Variables are eligible for register storage if they have a primitive type,
/// and nothing takes their address at any point during their lifetime.
/// As policy, only temporary values introduced by the compiler are eligible.
/// All variables explicitly declared in the program being compiled are
/// materialized in memory.
///
/// This compiler pass must run after implicit conversions have been exposed.
/// We rely on being able to clearly and easily see which variables have their
/// addresses taken.
///
/// This compiler pass must run after VarDeclaration nodes have been lowered.
/// We rely on being able to cleary and easily see the type of each variable at
/// its declaration site.
public final class CompilerPassMaterializationEscapeAnalysis: CompilerPassWithDeclScan {
    private let tempPrefix = "__temp"

    /// Set of VarDeclaration nodes, by ID, for variables known to be escaping
    private var escapes = Set<AbstractSyntaxTreeNode.ID>()

    /// Rewrites VarDeclaration nodes
    private final class VarDeclRewriter: CompilerPass {
        let escapes: Set<AbstractSyntaxTreeNode.ID>

        init(_ escapes: Set<AbstractSyntaxTreeNode.ID>) {
            self.escapes = escapes
        }

        override func visit(
            varDecl node0: VarDeclaration
        ) throws -> AbstractSyntaxTreeNode? {
            let node1 = try super.visit(varDecl: node0)
            guard let node1 = node1 as? VarDeclaration else { return node1 }
            guard !escapes.contains(node1.id) else { return node1 }
            return node1.withStorage(.registerStorage(nil))
        }
    }

    public override func postProcess(
        _ node0: AbstractSyntaxTreeNode?
    ) throws -> AbstractSyntaxTreeNode? {
        try VarDeclRewriter(escapes).run(node0)
    }

    public override func visit(unary node: Unary) throws -> Expression? {
        // If we take the address of a variable then that variable is Escaping.
        if node.op == .ampersand,
           let ident = (node.child as? Identifier)?.identifier,
           let decl = symbols?.maybeResolve(identifier: ident)?.decl {
            escapes.insert(decl)
        }
        return try super.visit(unary: node)
    }

    public override func visit(
        varDecl node0: VarDeclaration
    ) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(varDecl: node0)

        // If we declare a variable of a non-eligible type then consider it to
        // be Escaping too.
        if let node1 = node1 as? VarDeclaration {
            let type = try rvalueContext.check(expression: node1.explicitType!)
            let isTemp = node1.identifier.identifier.hasPrefix(tempPrefix)
            if !(type.isPrimitive && isTemp) {
                escapes.insert(node0.id)
            }
        }

        return node1
    }
}

public extension AbstractSyntaxTreeNode {
    /// Mark eligible variables with the "register" storage class
    func escapeAnalysis() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassMaterializationEscapeAnalysis().run(self)
    }
}
