//
//  SnapASTTransformerBase.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerBase: NSObject {
    var symbols: SymbolTable? = nil
    
    public func transform(_ genericNode: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let result: AbstractSyntaxTreeNode?
        switch genericNode {
        case let node as VarDeclaration:
            result = try transform(varDecl: node)
        case let node as Expression:
            result = try transform(expressionStatement: node)
        case let node as If:
            result = try transform(if: node)
        case let node as While:
            result = try transform(while: node)
        case let node as ForIn:
            result = try transform(forIn: node)
        case let node as Block:
            result = try transform(block: node)
        case let node as Return:
            result = try transform(return: node)
        case let node as FunctionDeclaration:
            result = try transform(func: node)
        case let node as Impl:
            result = try transform(impl: node)
        case let node as ImplFor:
            result = try transform(implFor: node)
        case let node as Match:
            result = try transform(match: node)
        case let node as Assert:
            result = try transform(assert: node)
        case let node as TraitDeclaration:
            result = try transform(trait: node)
        case let node as TestDeclaration:
            result = try transform(testDecl: node)
        default:
            result = genericNode
        }
        reconnect(result)
        return result
    }
    
    public func transform(varDecl node: VarDeclaration) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(if node: If) throws -> AbstractSyntaxTreeNode {
        return If(sourceAnchor: node.sourceAnchor,
                  condition: node.condition,
                  then: try transform(node.thenBranch)!,
                  else: try node.elseBranch.flatMap { try transform($0) })
    }
    
    public func transform(while node: While) throws -> AbstractSyntaxTreeNode {
        return While(sourceAnchor: node.sourceAnchor,
                     condition: node.condition,
                     body: try transform(node.body)!)
    }
    
    public func transform(forIn node: ForIn) throws -> AbstractSyntaxTreeNode {
        return ForIn(sourceAnchor: node.sourceAnchor,
                     identifier: node.identifier,
                     sequenceExpr: node.sequenceExpr,
                     body: try transform(node.body) as! Block)
    }
    
    public func transform(block node: Block) throws -> AbstractSyntaxTreeNode {
        let parent = symbols
        symbols = node.symbols
        let result = Block(sourceAnchor: node.sourceAnchor,
                           symbols: node.symbols,
                           children: try node.children.compactMap { try transform($0) })
        symbols = parent
        return result
    }
    
    public func transform(return node: Return) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode {
        let parent = symbols
        symbols = node.symbols
        let result = FunctionDeclaration(sourceAnchor: node.sourceAnchor,
                                         identifier: node.identifier,
                                         functionType: node.functionType,
                                         argumentNames: node.argumentNames,
                                         body: try transform(node.body) as! Block,
                                         visibility: node.visibility,
                                         symbols: node.symbols)
        symbols = parent
        return result
    }
    
    public func transform(impl node: Impl) throws -> AbstractSyntaxTreeNode {
        return Impl(sourceAnchor: node.sourceAnchor,
                    identifier: node.identifier,
                    children: try node.children.map { try transform($0) as! FunctionDeclaration })
    }
    
    public func transform(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode {
        return ImplFor(sourceAnchor: node.sourceAnchor,
                       traitIdentifier: node.traitIdentifier,
                       structIdentifier: node.structIdentifier,
                       children: try node.children.map { try transform($0) as! FunctionDeclaration })
    }
    
    public func transform(match node: Match) throws -> AbstractSyntaxTreeNode {
        return Match(sourceAnchor: node.sourceAnchor,
                     expr: node.expr,
                     clauses: try node.clauses.map {
                        Match.Clause(sourceAnchor: $0.sourceAnchor,
                                            valueIdentifier: $0.valueIdentifier,
                                            valueType: $0.valueType,
                                            block: try transform(block: $0.block) as! Block)
                     },
                     elseClause: try transform(node.elseClause) as? Block)
    }
    
    public func transform(assert node: Assert) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        return TestDeclaration(sourceAnchor: node.sourceAnchor,
                               name: node.name,
                               body: try transform(node.body) as! Block)
    }
    
    fileprivate func reconnect(_ node: AbstractSyntaxTreeNode?) {
        SymbolTablesReconnector(symbols).reconnect(node)
    }
}
