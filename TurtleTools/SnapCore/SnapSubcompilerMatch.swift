//
//  SnapSubcompilerMatch.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Lowers a Match statement
public struct SnapSubcompilerMatch {
    public let symbols: Env
    public let memoryLayoutStrategy: MemoryLayoutStrategy

    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: Env) {
        self.symbols = symbols
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }

    public func compile(_ match: Match) throws -> AbstractSyntaxTreeNode {
        let outer = Env(parent: symbols)

        let matchExprType = try RvalueExpressionTypeChecker(symbols: symbols).check(
            expression: match.expr
        )

        // Get the list of types this match statement is expected to contain.
        let expectedTypes: NSOrderedSet
        switch matchExprType {
        case .unionType(let typ):
            expectedTypes = NSOrderedSet(array: typ.members.map({ $0.correspondingMutableType }))
        default:
            expectedTypes = NSOrderedSet(array: [matchExprType.correspondingMutableType])
        }

        // Check that the expected and provided types match.
        let valueTypes = NSOrderedSet(
            array: try match.clauses.map({
                (
                    $0,
                    try RvalueExpressionTypeChecker(symbols: symbols).check(
                        expression: $0.valueType
                    )
                )
            })
        )
        let extraneousTypes = valueTypes.filter { (element_: Any) -> Bool in
            let element = element_ as! (Match.Clause, SymbolType)
            let isIncluded = !expectedTypes.contains(element.1)
            return isIncluded
        }
        guard extraneousTypes.count == 0 else {
            let what = extraneousTypes.map({ "\(($0 as! (Match.Clause, SymbolType)).1)" }).joined(
                separator: ", "
            )
            let clauseStr = extraneousTypes.count == 1 ? "clause" : "clauses"
            let badClause = (extraneousTypes.first as? (Match.Clause, SymbolType))?.0
            let sourceAnchor = badClause?.valueIdentifier.sourceAnchor?.union(
                badClause?.valueType.sourceAnchor
            )
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "extraneous \(clauseStr) in match statement: \(what)"
            )
        }
        let missingTypes = (expectedTypes.mutableCopy() as! NSMutableOrderedSet)
        missingTypes.minus(
            NSOrderedSet(
                array: valueTypes.map {
                    ($0 as! (Match.Clause, SymbolType)).1
                }
            )
        )
        guard missingTypes.count == 0 || match.elseClause != nil else {
            let what =
                missingTypes
                .map { "\($0)" }
                .joined(separator: ", ")
            let clauseStr = missingTypes.count == 1 ? "clause" : "clauses"
            let sourceAnchor = match.expr.sourceAnchor
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "match statement is not exhaustive. Missing \(clauseStr): \(what)"
            )
        }

        // Generate an AST for if-else tree to evaluate the clauses.
        var stmts: [AbstractSyntaxTreeNode] = []
        if !match.clauses.isEmpty {
            stmts.append(
                VarDeclaration(
                    identifier: Identifier("__index"),
                    explicitType: nil,
                    expression: match.expr,
                    storage: .automaticStorage(offset: nil),
                    isMutable: true
                )
            )
            stmts.append(compileMatchClause(match, match.clauses, outer))
        }
        else if let elseClause = match.elseClause {
            let rewrittenElseClause = Block(
                sourceAnchor: elseClause.sourceAnchor,
                symbols: Env(parent: outer),
                children: elseClause.children
            )
            stmts.append(rewrittenElseClause)
        }

        let block0 = Block(
            sourceAnchor: match.sourceAnchor,
            symbols: outer,
            children: stmts
        )

        return block0
    }

    private func compileMatchClause(_ match: Match, _ clauses: [Match.Clause], _ symbols: Env) -> If
    {
        assert(!clauses.isEmpty)

        let clause = clauses.last!
        let index = Identifier("__index")

        guard clauses.count == 1 else {
            let outerSymbols = Env(parent: symbols)
            return If(
                condition: Is(expr: index, testType: clause.valueType),
                then: Block(
                    symbols: outerSymbols,
                    children: [
                        VarDeclaration(
                            identifier: clause.valueIdentifier,
                            explicitType: nil,
                            expression: As(expr: index, targetType: clause.valueType),
                            storage: .automaticStorage(offset: nil),
                            isMutable: false
                        ),
                        Block(
                            sourceAnchor: clause.block.sourceAnchor,
                            symbols: Env(parent: outerSymbols),
                            children: clause.block.children
                        )
                    ]
                ),
                else: compileMatchClause(match, clauses.dropLast(), symbols)
            )
        }
        let clauseElseBlock: Block?
        if match.elseClause == nil {
            clauseElseBlock = nil
        }
        else {
            clauseElseBlock = Block(
                sourceAnchor: match.elseClause!.sourceAnchor,
                symbols: Env(parent: symbols),
                children: match.elseClause!.children
            )
        }

        let outerSymbols = Env(parent: symbols)

        return If(
            condition: Is(expr: index, testType: clause.valueType),
            then: Block(
                symbols: outerSymbols,
                children: [
                    VarDeclaration(
                        identifier: clause.valueIdentifier,
                        explicitType: nil,
                        expression: As(expr: index, targetType: clause.valueType),
                        storage: .automaticStorage(offset: nil),
                        isMutable: false
                    ),
                    Block(
                        sourceAnchor: clause.block.sourceAnchor,
                        symbols: Env(parent: outerSymbols),
                        children: clause.block.children
                    )
                ]
            ),
            else: clauseElseBlock
        )
    }
}
