//
//  CompilerPassForIn.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/10/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

// Discrete compiler pass to lower and erase ForIn statements
public class CompilerPassForIn: CompilerPass {
    public let globalEnvironment: GlobalEnvironment
    
    public init(symbols: SymbolTable? = nil,
                globalEnvironment: GlobalEnvironment) {
        self.globalEnvironment = globalEnvironment
        super.init(symbols)
    }
    
    public override func visit(forIn node0: ForIn) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(forIn: node0) as! ForIn
        
        let sequence = Expression.Identifier(sourceAnchor: node1.sourceAnchor, identifier: globalEnvironment.tempNameMaker.next(prefix: "__sequence"))
        let index = Expression.Identifier(sourceAnchor: node1.sourceAnchor, identifier: globalEnvironment.tempNameMaker.next(prefix: "__index"))
        let limit = Expression.Identifier(sourceAnchor: node1.sourceAnchor, identifier: globalEnvironment.tempNameMaker.next(prefix: "__limit"))
        let count = Expression.Identifier(sourceAnchor: node1.sourceAnchor, identifier: "count")
        let usize = Expression.PrimitiveType(.arithmeticType(.mutableInt(.u16))) // TODO: This should use `usize' instead of assuming `u16'.
        let zero = Expression.LiteralInt(sourceAnchor: node1.sourceAnchor, value: 0)
        let one = Expression.LiteralInt(sourceAnchor: node1.sourceAnchor, value: 1)
        
        let grandparent = SymbolTable(parent: symbols)
        let parent = SymbolTable(parent: grandparent)
        let inner = SymbolTable(parent: parent)
        
        let body = node1.body.withSymbols(inner)
        
        let ast = Block(
            sourceAnchor: node1.sourceAnchor,
            symbols: grandparent,
            children: [
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: sequence,
                    explicitType: nil,
                    expression: node1.sequenceExpr,
                    storage: .automaticStorage,
                    isMutable: false),
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: index,
                    explicitType: usize,
                    expression: zero,
                    storage: .automaticStorage,
                    isMutable: true),
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: limit,
                    explicitType: usize,
                    expression: Expression.Get(
                        expr: sequence,
                        member: count),
                    storage: .automaticStorage,
                    isMutable: false),
                VarDeclaration(
                    sourceAnchor: node1.sourceAnchor,
                    identifier: node1.identifier,
                    explicitType: Expression.TypeOf(
                        sourceAnchor: node1.sourceAnchor,
                        expr: Expression.MutableType(
                            sourceAnchor: node1.sourceAnchor,
                            typ: Expression.Subscript(
                                sourceAnchor: node1.sourceAnchor,
                                subscriptable: sequence,
                                argument: zero))),
                    expression: nil,
                    storage: .automaticStorage,
                    isMutable: true),
                While(
                    sourceAnchor: node1.sourceAnchor,
                    condition: Expression.Binary(
                        sourceAnchor: node1.sourceAnchor,
                        op: .ne,
                        left: index,
                        right: limit),
                      body: Block(
                        sourceAnchor: node1.sourceAnchor,
                        symbols: parent,
                        children: [
                            Expression.Assignment(
                                sourceAnchor: node1.sourceAnchor,
                                lexpr: node1.identifier,
                                rexpr: Expression.Subscript(
                                    sourceAnchor: node1.sourceAnchor,
                                    subscriptable: sequence,
                                    argument: index)),
                            body,
                            Expression.Assignment(
                                sourceAnchor: node1.sourceAnchor,
                                lexpr: index,
                                rexpr: Expression.Binary(
                                    op: .plus,
                                    left: index,
                                    right: one)),
                        ]))
        ])
        
        return ast.reconnect(parent: symbols)
    }
}

extension AbstractSyntaxTreeNode {
    /// Lower and rewrite ForIn statements
    public func forInPass(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassForIn(globalEnvironment: globalEnvironment).run(self)
    }
}
