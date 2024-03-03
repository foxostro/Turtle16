//
//  SnapASTTransformerBase.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerBase: NSObject {
    struct Environment {
        private var stack: [SymbolTable] = []
        
        var symbols: SymbolTable? {
            stack.last
        }
        
        mutating func push(_ newSymbols: SymbolTable) {
            stack.append(newSymbols)
        }
        
        @discardableResult mutating func pop() -> SymbolTable {
            stack.removeLast()
        }
    }
    var env = Environment()
    
    public var symbols: SymbolTable? {
        env.symbols
    }
    
    public init(_ symbols: SymbolTable? = nil) {
        if let symbols {
            env.push(symbols)
        }
    }
    
    public func compile(_ genericNode: AbstractSyntaxTreeNode?) throws -> AbstractSyntaxTreeNode? {
        let result: AbstractSyntaxTreeNode?
        switch genericNode {
        case let node as TopLevel:
            result = try compile(topLevel: node)
        case let node as Subroutine:
            result = try compile(subroutine: node)
        case let node as Seq:
            result = try compile(seq: node)
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
        case let node as Import:
            result = try compile(import: node)
        case let node as Asm:
            result = try compile(asm: node)
        case let node as Goto:
            result = try compile(goto: node)
        case let node as GotoIfFalse:
            result = try compile(gotoIfFalse: node)
        case let node as InstructionNode:
            result = try compile(instruction: node)
        case let node as TackInstructionNode:
            result = try compile(tack: node)
        default:
            result = genericNode
        }
        SymbolTablesReconnector(symbols, onlyCheck: true).reconnect(result)
        return result
    }
    
    public func compile(topLevel node: TopLevel) throws -> AbstractSyntaxTreeNode? {
        let children: [AbstractSyntaxTreeNode] = try node.children.compactMap { try compile($0) }
        return TopLevel(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    public func compile(subroutine node: Subroutine) throws -> AbstractSyntaxTreeNode? {
        let children: [AbstractSyntaxTreeNode] = try node.children.compactMap { try compile($0) }
        return Subroutine(sourceAnchor: node.sourceAnchor, identifier: node.identifier, children: children)
    }
    
    public func compile(seq node: Seq) throws -> AbstractSyntaxTreeNode? {
        let children: [AbstractSyntaxTreeNode] = try node.children.compactMap { try compile($0) }
        return Seq(sourceAnchor: node.sourceAnchor, children: children)
    }
    
    public func compile(varDecl node: VarDeclaration) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(expressionStatement node: Expression) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(if node: If) throws -> AbstractSyntaxTreeNode? {
        return If(sourceAnchor: node.sourceAnchor,
                  condition: node.condition,
                  then: try compile(node.thenBranch)!,
                  else: try node.elseBranch.flatMap { try compile($0) })
    }
    
    public func compile(while node: While) throws -> AbstractSyntaxTreeNode? {
        return While(sourceAnchor: node.sourceAnchor,
                     condition: node.condition,
                     body: try compile(node.body)!)
    }
    
    public func compile(forIn node: ForIn) throws -> AbstractSyntaxTreeNode? {
        return ForIn(sourceAnchor: node.sourceAnchor,
                     identifier: node.identifier,
                     sequenceExpr: node.sequenceExpr,
                     body: try compile(node.body) as! Block)
    }
    
    public func compile(block node: Block) throws -> AbstractSyntaxTreeNode? {
        env.push(node.symbols)
        let result = node.withChildren(try node.children.compactMap {
            try compile($0)
        })
        env.pop()
        if let symbols = symbols, node.symbols.stackFrameIndex == symbols.stackFrameIndex {
            symbols.highwaterMark = max(symbols.highwaterMark, node.symbols.highwaterMark)
        }
        return result
    }
    
    public func compile(return node: Return) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        env.push(node.symbols)
        let result = FunctionDeclaration(sourceAnchor: node.sourceAnchor,
                                         identifier: node.identifier,
                                         functionType: node.functionType,
                                         argumentNames: node.argumentNames,
                                         typeArguments: node.typeArguments,
                                         body: try compile(node.body) as! Block,
                                         visibility: node.visibility,
                                         symbols: node.symbols)
        env.pop()
        return result
    }
    
    public func compile(struct node: StructDeclaration) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(impl node: Impl) throws -> AbstractSyntaxTreeNode? {
        return Impl(sourceAnchor: node.sourceAnchor,
                    typeArguments: node.typeArguments,
                    structTypeExpr: node.structTypeExpr,
                    children: try node.children.map { try compile($0) as! FunctionDeclaration })
    }
    
    public func compile(implFor node: ImplFor) throws -> AbstractSyntaxTreeNode? {
        return ImplFor(sourceAnchor: node.sourceAnchor,
                       typeArguments: node.typeArguments,
                       traitTypeExpr: node.traitTypeExpr,
                       structTypeExpr: node.structTypeExpr,
                       children: try node.children.map { try compile($0) as! FunctionDeclaration })
    }
    
    public func compile(match node: Match) throws -> AbstractSyntaxTreeNode? {
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
    
    public func compile(assert node: Assert) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(trait node: TraitDeclaration) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(testDecl node: TestDeclaration) throws -> AbstractSyntaxTreeNode? {
        return TestDeclaration(sourceAnchor: node.sourceAnchor,
                               name: node.name,
                               body: try compile(node.body) as! Block)
    }
    
    public func compile(typealias node: Typealias) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(import node: Import) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(asm node: Asm) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(goto node: Goto) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(gotoIfFalse node: GotoIfFalse) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(instruction node: InstructionNode) throws -> AbstractSyntaxTreeNode? {
        return node
    }
    
    public func compile(tack node: TackInstructionNode) throws -> AbstractSyntaxTreeNode? {
        return node
    }
}
