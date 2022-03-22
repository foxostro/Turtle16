//
//  SnapSubcompilerForIn.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerForIn: NSObject {
    public let symbols: SymbolTable
    
    public init(_ symbols: SymbolTable) {
        self.symbols = symbols
    }
    
    public func compile(_ node: ForIn) throws -> Block {
        let result: Block
        
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
        let sequenceType = try typeChecker.check(expression: node.sequenceExpr)
        switch sequenceType {
        case .constStructType(let typ), .structType(let typ):
            guard typ.name == "Range" else {
                throw CompilerError(sourceAnchor: node.sequenceExpr.sourceAnchor, message: "for-in loop requires iterable sequence")
            }
            result = try compileForInRange(node)
        case .array, .constDynamicArray, .dynamicArray:
            result = try compileForInArray(node)
        default:
            throw CompilerError(sourceAnchor: node.sequenceExpr.sourceAnchor, message: "for-in loop requires iterable sequence")
        }
        
        return result
    }
    
    func compileForInRange(_ stmt: ForIn) throws -> Block {
        let sequence = Expression.Identifier("__sequence")
        let limit = Expression.Identifier("__limit")
        
        let grandparent = SymbolTable(parent: symbols)
        let parent = SymbolTable(parent: grandparent)
        let inner = SymbolTable(parent: parent)
        
        let body = Block(sourceAnchor: stmt.body.sourceAnchor,
                         symbols: inner,
                         children: stmt.body.children)
        
        let ast = Block(symbols: grandparent, children: [
            VarDeclaration(identifier: sequence,
                           explicitType: nil,
                           expression: stmt.sequenceExpr,
                           storage: .automaticStorage,
                           isMutable: false),
            VarDeclaration(identifier: limit,
                           explicitType: nil,
                           expression: Expression.Get(expr: sequence, member: Expression.Identifier("limit")),
                           storage: .automaticStorage,
                           isMutable: false),
            VarDeclaration(identifier: stmt.identifier,
                           explicitType: Expression.TypeOf(limit),
                           expression: Expression.LiteralInt(0),
                           storage: .automaticStorage,
                           isMutable: true),
            While(condition: Expression.Binary(op: .ne, left: stmt.identifier, right: limit),
                  body: Block(symbols: SymbolTable(parent: grandparent),
                              children: [body, Expression.Assignment(lexpr: stmt.identifier, rexpr: Expression.Binary(op: .plus, left: stmt.identifier, right: Expression.LiteralInt(1)))]))
        ])
        
        return ast
    }
    
    func compileForInArray(_ stmt: ForIn) throws -> Block {
        let sequence = Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "__sequence")
        let index = Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "__index")
        let limit = Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "__limit")
        
        let grandparent = SymbolTable(parent: symbols)
        let parent = SymbolTable(parent: grandparent)
        let inner = SymbolTable(parent: parent)
        
        let body = Block(sourceAnchor: stmt.body.sourceAnchor,
                         symbols: inner,
                         children: stmt.body.children)
        
        let ast = Block(sourceAnchor: stmt.sourceAnchor, symbols: grandparent, children: [
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: sequence,
                           explicitType: nil,
                           expression: stmt.sequenceExpr,
                           storage: .automaticStorage,
                           isMutable: false),
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: index,
                           explicitType: Expression.PrimitiveType(.u16),
                           expression: Expression.LiteralInt(sourceAnchor: stmt.sourceAnchor, value: 0),
                           storage: .automaticStorage,
                           isMutable: true),
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: limit,
                           explicitType: Expression.PrimitiveType(.u16),
                           expression: Expression.Get(expr: sequence, member: Expression.Identifier(sourceAnchor: stmt.sourceAnchor, identifier: "count")),
                           storage: .automaticStorage,
                           isMutable: false),
            VarDeclaration(sourceAnchor: stmt.sourceAnchor,
                           identifier: stmt.identifier,
                           explicitType: Expression.PrimitiveType(sourceAnchor: stmt.sourceAnchor, typ: try RvalueExpressionTypeChecker(symbols: symbols).check(expression: stmt.sequenceExpr).arrayElementType.correspondingMutableType),
                           expression: nil,
                           storage: .automaticStorage,
                           isMutable: true),
            While(sourceAnchor: stmt.sourceAnchor,
                  condition: Expression.Binary(sourceAnchor: stmt.sourceAnchor,
                                               op: .ne, left: index, right: limit),
                  body: Block(sourceAnchor: stmt.sourceAnchor,
                              symbols: parent,
                              children: [
                    Expression.Assignment(sourceAnchor: stmt.sourceAnchor,
                                          lexpr: stmt.identifier,
                                          rexpr: Expression.Subscript(sourceAnchor: stmt.sourceAnchor,
                                                                      subscriptable: sequence,
                                                                      argument: index)),
                    body,
                    Expression.Assignment(sourceAnchor: stmt.sourceAnchor,
                                          lexpr: index,
                                          rexpr: Expression.Binary(op: .plus,
                                                                   left: index,
                                                                   right: Expression.LiteralInt(sourceAnchor: stmt.sourceAnchor, value: 1))),
                  ]))
        ])
        
        return ast
    }
}
