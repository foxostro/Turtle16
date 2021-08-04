//
//  SnapASTTransformerBase.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerBase: NSObject {
    public private(set) var symbols: SymbolTable? = nil
    
    public init(_ symbols: SymbolTable? = nil) {
        self.symbols = symbols
    }
    
    public func compile(_ genericNode: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let result: AbstractSyntaxTreeNode?
        switch genericNode {
        case let node as VarDeclaration:
            result = try compile(varDecl: node)
        case let node as Expression:
            result = try compile(expressionStatement: node)
        case let node as If:
            result = try compile(if: node)
        case let node as While:
            result = try compile(while: node)
        case let node as ForIn:
            result = try compile(forIn: node)
        case let node as Block:
            result = try compile(block: node)
        case let node as Return:
            result = try compile(return: node)
        case let node as FunctionDeclaration:
            result = try compile(func: node)
        case let node as StructDeclaration:
            result = try compile(struct: node)
        case let node as Impl:
            result = try compile(impl: node)
        case let node as ImplFor:
            result = try compile(implFor: node)
        case let node as Match:
            result = try compile(match: node)
        case let node as Assert:
            result = try compile(assert: node)
        case let node as TraitDeclaration:
            result = try compile(trait: node)
        case let node as TestDeclaration:
            result = try compile(testDecl: node)
        case let node as Typealias:
            result = try compile(typealias: node)
        default:
            result = genericNode
        }
        reconnect(result)
        return result
    }
    
    public func compile(varDecl node: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func compile(if node: If) throws -> AbstractSyntaxTreeNode {
        return If(sourceAnchor: node.sourceAnchor,
                  condition: node.condition,
                  then: try compile(node.thenBranch)!,
                  else: try node.elseBranch.flatMap { try compile($0) })
    }
    
    public func compile(while node: While) throws -> AbstractSyntaxTreeNode {
        return While(sourceAnchor: node.sourceAnchor,
                     condition: node.condition,
                     body: try compile(node.body)!)
    }
    
    public func compile(forIn node: ForIn) throws -> AbstractSyntaxTreeNode {
        return ForIn(sourceAnchor: node.sourceAnchor,
                     identifier: node.identifier,
                     sequenceExpr: node.sequenceExpr,
                     body: try compile(node.body) as! Block)
    }
    
    public func compile(block node: Block) throws -> AbstractSyntaxTreeNode {
        let parent = symbols
        symbols = node.symbols
        let result = Block(sourceAnchor: node.sourceAnchor,
                           symbols: node.symbols,
                           children: try node.children.compactMap { try compile($0) })
        symbols = parent
        return result
    }
    
    public func compile(return node: Return) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func compile(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode {
        let parent = symbols
        symbols = node.symbols
        let result = FunctionDeclaration(sourceAnchor: node.sourceAnchor,
                                         identifier: node.identifier,
                                         functionType: node.functionType,
                                         argumentNames: node.argumentNames,
                                         body: try compile(node.body) as! Block,
                                         visibility: node.visibility,
                                         symbols: node.symbols)
        symbols = parent
        return result
    }
    
    public func compile(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(impl node: Impl) throws -> AbstractSyntaxTreeNode {
        return Impl(sourceAnchor: node.sourceAnchor,
                    identifier: node.identifier,
                    children: try node.children.map { try compile($0) as! FunctionDeclaration })
    }
    
    public func compile(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode {
        return ImplFor(sourceAnchor: node.sourceAnchor,
                       traitIdentifier: node.traitIdentifier,
                       structIdentifier: node.structIdentifier,
                       children: try node.children.map { try compile($0) as! FunctionDeclaration })
    }
    
    public func compile(match node: Match) throws -> AbstractSyntaxTreeNode {
        return Match(sourceAnchor: node.sourceAnchor,
                     expr: node.expr,
                     clauses: try node.clauses.map {
                        Match.Clause(sourceAnchor: $0.sourceAnchor,
                                            valueIdentifier: $0.valueIdentifier,
                                            valueType: $0.valueType,
                                            block: try compile(block: $0.block) as! Block)
                     },
                     elseClause: try compile(node.elseClause) as? Block)
    }
    
    public func compile(assert node: Assert) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func compile(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func compile(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        return TestDeclaration(sourceAnchor: node.sourceAnchor,
                               name: node.name,
                               body: try compile(node.body) as! Block)
    }
    
    public func compile(typealias node: Typealias) throws -> AbstractSyntaxTreeNode {
        return node
    }
    
    public func reconnect(_ node: AbstractSyntaxTreeNode?) {
        SymbolTablesReconnector(symbols).reconnect(node)
    }
}
