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
    
    public func transform(_ genericNode: AbstractSyntaxTreeNode) throws -> AbstractSyntaxTreeNode {
        switch genericNode {
        case let node as VarDeclaration:
            return try transform(varDecl: node)
        case let node as Expression:
            return try transform(expressionStatement: node)
        case let node as If:
            return try transform(if: node)
        case let node as While:
            return try transform(while: node)
        case let node as ForIn:
            return try transform(forIn: node)
        case let node as Block:
            return try transform(block: node)
        case let node as Return:
            return try transform(return: node)
        case let node as FunctionDeclaration:
            return try transform(func: node)
        case let node as Impl:
            return try transform(impl: node)
        case let node as ImplFor:
            return try transform(implFor: node)
        case let node as Match:
            return try transform(match: node)
        case let node as Assert:
            return try transform(assert: node)
        case let node as TraitDeclaration:
            return try transform(trait: node)
        case let node as TestDeclaration:
            return try transform(testDecl: node)
        default:
            return genericNode
        }
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
                  then: try transform(node.thenBranch),
                  else: try node.elseBranch.flatMap { try transform($0) })
    }
    
    public func transform(while node: While) throws -> AbstractSyntaxTreeNode {
        return While(sourceAnchor: node.sourceAnchor,
                     condition: node.condition,
                     body: try transform(node.body))
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
                           children: try node.children.map { try transform($0) })
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
                     elseClause: try node.elseClause.flatMap { try transform($0) as? Block })
    }
    
    public func transform(assert node: Assert) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode {
        return TestDeclaration(sourceAnchor: node.sourceAnchor,
                               name: node.name,
                               body: try transform(node.body) as! Block)
    }
}
