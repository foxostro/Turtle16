//
//  SymbolTablesReconnector.swift
//  SnapCore
//
//  Created by Andrew Fox on 7/29/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public final class SymbolTablesReconnector {
    var symbols: Env? = nil
    let onlyCheck: Bool

    public init(_ symbols: Env? = nil, onlyCheck: Bool = false) {
        self.symbols = symbols
        self.onlyCheck = onlyCheck
    }

    public func reconnect(_ genericNode: AbstractSyntaxTreeNode?) {
        switch genericNode {
        case let node as If:
            reconnect(if: node)
        case let node as While:
            reconnect(while: node)
        case let node as ForIn:
            reconnect(forIn: node)
        case let node as TopLevel:
            reconnect(topLevel: node)
        case let node as Seq:
            reconnect(seq: node)
        case let node as Block:
            reconnect(block: node)
        case let node as FunctionDeclaration:
            reconnect(func: node)
        case let node as Impl:
            reconnect(impl: node)
        case let node as ImplFor:
            reconnect(implFor: node)
        case let node as Match:
            reconnect(match: node)
        case let node as TestDeclaration:
            reconnect(testDecl: node)
        case let node as Module:
            reconnect(module: node)
        default:
            break
        }
    }

    func reconnect(if node: If) {
        reconnect(node.thenBranch)
        reconnect(node.elseBranch)
    }

    func reconnect(while node: While) {
        reconnect(node.body)
    }

    func reconnect(forIn node: ForIn) {
        reconnect(node.body)
    }

    func reconnect(topLevel node: TopLevel) {
        for child in node.children {
            reconnect(child)
        }
    }

    func reconnect(seq node: Seq) {
        for child in node.children {
            reconnect(child)
        }
    }

    func reconnect(block node: Block) {
        let parent = symbols

        if onlyCheck {
            assert(node.symbols.parent === parent)
            assert(node.symbols.frameLookupMode == .inherit)
        }
        else {
            node.symbols.parent = parent
        }

        symbols = node.symbols
        for child in node.children {
            reconnect(child)
        }
        symbols = parent
    }

    func reconnect(func node: FunctionDeclaration) {
        let parent = symbols

        if onlyCheck {
            assert(node.symbols.parent === parent)
            assert(node.symbols.frameLookupMode == .set(Frame(growthDirection: .down)))
            assert(node.symbols.frame == Frame(growthDirection: .down))
        }
        else {
            node.symbols.parent = parent
            node.symbols.frameLookupMode = .set(Frame(growthDirection: .down))
        }

        symbols = node.symbols
        reconnect(node.body)
        symbols = parent
    }

    func reconnect(impl node: Impl) {
        for child in node.children {
            reconnect(child)
        }
    }

    func reconnect(implFor node: ImplFor) {
        for child in node.children {
            reconnect(child)
        }
    }

    func reconnect(match node: Match) {
        for clause in node.clauses {
            reconnect(clause.block)
        }
        reconnect(node.elseClause)
    }

    func reconnect(testDecl node: TestDeclaration) {
        reconnect(node.body)
    }

    func reconnect(module node: Module) {
        let oldSymbols = symbols
        symbols = nil
        reconnect(block: node.block)
        symbols = oldSymbols
    }
}

extension AbstractSyntaxTreeNode {
    // Perform a reconnect to ensure the symbol table tree is topologically
    // connected to correspond to the lexical structure of the program.
    public func reconnect(parent: Env?) -> Self {
        SymbolTablesReconnector(parent).reconnect(self)
        return self
    }
}
