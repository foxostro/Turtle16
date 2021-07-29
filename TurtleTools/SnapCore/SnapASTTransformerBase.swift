//
//  SnapASTTransformerBase.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerBase: NSObject {
    public func transform(_ genericNode: AbstractSyntaxTreeNode) -> AbstractSyntaxTreeNode {
        switch genericNode {
        case let node as VarDeclaration:
            return transform(varDecl: node)
        case let node as Expression:
            return transform(expressionStatement: node)
        case let node as If:
            return transform(if: node)
        case let node as While:
            return transform(while: node)
        case let node as ForIn:
            return transform(forIn: node)
        case let node as Block:
            return transform(block: node)
        case let node as Return:
            return transform(return: node)
        case let node as FunctionDeclaration:
            return transform(func: node)
        case let node as Impl:
            return transform(impl: node)
        case let node as ImplFor:
            return transform(implFor: node)
        case let node as Match:
            return transform(match: node)
        case let node as Assert:
            return transform(assert: node)
        case let node as TraitDeclaration:
            return transform(trait: node)
        case let node as TestDeclaration:
            return transform(testDecl: node)
        default:
            return genericNode
        }
    }
    
    public func transform(varDecl node: VarDeclaration) -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(expressionStatement node: Expression) -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(if node: If) -> AbstractSyntaxTreeNode {
        return If(sourceAnchor: node.sourceAnchor,
                  condition: node.condition,
                  then: transform(node.thenBranch),
                  else: node.elseBranch.flatMap { transform($0) })
    }
    
    public func transform(while node: While) -> AbstractSyntaxTreeNode {
        return While(sourceAnchor: node.sourceAnchor,
                     condition: node.condition,
                     body: transform(node.body))
    }
    
    public func transform(forIn node: ForIn) -> AbstractSyntaxTreeNode {
        return ForIn(sourceAnchor: node.sourceAnchor,
                     identifier: node.identifier,
                     sequenceExpr: node.sequenceExpr,
                     body: transform(node.body) as! Block)
    }
    
    public func transform(block node: Block) -> AbstractSyntaxTreeNode {
        return Block(sourceAnchor: node.sourceAnchor,
                     symbols: node.symbols,
                     children: node.children.map { transform($0) })
    }
    
    public func transform(return node: Return) -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(func node: FunctionDeclaration) -> AbstractSyntaxTreeNode {
        return FunctionDeclaration(sourceAnchor: node.sourceAnchor,
                                   identifier: node.identifier,
                                   functionType: node.functionType,
                                   argumentNames: node.argumentNames,
                                   body: transform(node.body) as! Block,
                                   visibility: node.visibility)
    }
    
    public func transform(impl node: Impl) -> AbstractSyntaxTreeNode {
        return Impl(sourceAnchor: node.sourceAnchor,
                    identifier: node.identifier,
                    children: node.children.map { transform($0) as! FunctionDeclaration })
    }
    
    public func transform(implFor node: ImplFor) -> AbstractSyntaxTreeNode {
        return ImplFor(sourceAnchor: node.sourceAnchor,
                       traitIdentifier: node.traitIdentifier,
                       structIdentifier: node.structIdentifier,
                       children: node.children.map { transform($0) as! FunctionDeclaration })
    }
    
    public func transform(match node: Match) -> AbstractSyntaxTreeNode {
        return Match(sourceAnchor: node.sourceAnchor,
                     expr: node.expr,
                     clauses: node.clauses.map {
                        Match.Clause(sourceAnchor: $0.sourceAnchor,
                                            valueIdentifier: $0.valueIdentifier,
                                            valueType: $0.valueType,
                                            block: transform(block: $0.block) as! Block)
                     },
                     elseClause: node.elseClause.flatMap { transform($0) as? Block })
    }
    
    public func transform(assert node: Assert) -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(trait node: TraitDeclaration) -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func transform(testDecl node: TestDeclaration) -> AbstractSyntaxTreeNode {
        return TestDeclaration(sourceAnchor: node.sourceAnchor,
                               name: node.name,
                               body: transform(node.body) as! Block)
    }
}
