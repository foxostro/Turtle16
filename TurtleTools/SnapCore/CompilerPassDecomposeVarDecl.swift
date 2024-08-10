//
//  CompilerPassDecomposeVarDecl.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/5/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

// Split variable declarations from their initial assignments
public class CompilerPassDecomposeVarDecl: CompilerPass {
    fileprivate let globalEnvironment: GlobalEnvironment
    
    public init(symbols: SymbolTable? = nil, globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func visit(block block0: Block) throws -> AbstractSyntaxTreeNode? {
        let block1 = try super.visit(block: block0) as! Block
        let block2 = try block1.flatten()
        return block2
    }
    
    public override func visit(varDecl node0: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(varDecl: node0) as! VarDeclaration
        
        let expression = node1.expression
        let explicitType = node1.explicitType
        
        if expression != nil && explicitType != nil {
            return Seq(children: [
                node1
                    .withExpression(nil)
                    .withExplicitType(explicitType!),
                Expression.InitialAssignment(
                    sourceAnchor: node1.sourceAnchor,
                    lexpr: node1.identifier,
                    rexpr: expression!)
            ])
        }
        else if expression != nil && explicitType == nil {
            return Seq(children: [
                node1
                    .withExpression(nil)
                    .withExplicitType(Expression.TypeOf(expression!)),
                Expression.InitialAssignment(
                    sourceAnchor: node1.sourceAnchor,
                    lexpr: node1.identifier,
                    rexpr: expression!)
            ])
        }
        else if expression == nil && explicitType != nil {
            return node1
                .withExpression(nil)
                .withExplicitType(explicitType!)
        }
        else {
            throw CompilerError(
                sourceAnchor: node1.identifier.sourceAnchor,
                format: "unable to deduce type of %@ `%@'",
                node1.isMutable ? "variable" : "constant",
                node1.identifier.identifier)
        }
    }
}
