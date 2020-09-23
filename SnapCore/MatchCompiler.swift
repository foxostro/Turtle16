//
//  MatchCompiler.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

// Accepts a Match statement and produces an AST which implements it in terms
// of other nodes.
public class MatchCompiler: NSObject {
    public func compile(match: Match, symbols: SymbolTable) throws -> AbstractSyntaxTreeNode {
        let matchExprType = try RvalueExpressionTypeChecker(symbols: symbols).check(expression: match.expr)
        
        // Get the list of types this match statement is expected to contain.
        let expectedTypes: NSOrderedSet
        switch matchExprType {
        case .unionType(let typ):
            expectedTypes = NSOrderedSet(array: typ.members.map({ $0.correspondingMutableType }))
        default:
            expectedTypes = NSOrderedSet(array: [matchExprType.correspondingMutableType])
        }
        
        // Check that the expected and provided types match.
        let valueTypes = NSOrderedSet(array: try match.clauses.map({
            ($0, try RvalueExpressionTypeChecker(symbols: symbols).check(expression: $0.valueType))
        }))
        let extraneousTypes = valueTypes.filter { (element_: Any) -> Bool in
            let element = element_ as! (Match.Clause, SymbolType)
            let isIncluded = !expectedTypes.contains(element.1)
            return isIncluded
        }
        guard extraneousTypes.count == 0 else {
            let what = extraneousTypes.map({"\(($0 as! (Match.Clause, SymbolType)).1)"}).joined(separator: ", ")
            let clauseStr = extraneousTypes.count == 1 ? "clause" : "clauses"
            let badClause = (extraneousTypes.first as? (Match.Clause, SymbolType))?.0
            let sourceAnchor = badClause?.valueIdentifier.sourceAnchor?.union(badClause?.valueType.sourceAnchor)
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "extraneous \(clauseStr) in match statement: \(what)")
        }
        let missingTypes = (expectedTypes.mutableCopy() as! NSMutableOrderedSet)
        missingTypes.minus(NSOrderedSet(array: valueTypes.map {
            ($0 as! (Match.Clause, SymbolType)).1
        }))
        guard missingTypes.count == 0 || match.elseClause != nil else {
            let what = missingTypes.map({"\($0)"}).joined(separator: ", ")
            let clauseStr = missingTypes.count == 1 ? "clause" : "clauses"
            let sourceAnchor = match.expr.sourceAnchor
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "match statement is not exhaustive. Missing \(clauseStr): \(what)")
        }
        
        // Generate an AST for if-else tree to evaluate the clauses.
        var stmts: [AbstractSyntaxTreeNode] = []
        if !match.clauses.isEmpty {
            stmts.append(VarDeclaration(identifier: Expression.Identifier("__index"),
                                        explicitType: nil,
                                        expression: match.expr,
                                        storage: .stackStorage,
                                        isMutable: true))
            stmts.append(compileMatchClause(match, match.clauses))
        }
        else if let elseClause = match.elseClause {
            stmts.append(elseClause)
        }
        
        let block = Block(sourceAnchor: match.sourceAnchor, children: stmts)
        return block
    }
    
    private func compileMatchClause(_ match: Match, _ clauses: [Match.Clause]) -> If {
        assert(!clauses.isEmpty)
        let clause = clauses.last!
        let index = Expression.Identifier("__index")
        if clauses.count == 1 {
            return If(condition: Expression.Is(expr: index, testType: clause.valueType),
                      then: Block(children: [
                        VarDeclaration(identifier: clause.valueIdentifier,
                                       explicitType: nil,
                                       expression: Expression.As(expr: index, targetType: clause.valueType),
                                       storage: .stackStorage,
                                       isMutable: false),
                        clause.block
                      ]),
                      else: match.elseClause)
        } else {
            return If(condition: Expression.Is(expr: index, testType: clause.valueType),
                      then: Block(children: [
                        VarDeclaration(identifier: clause.valueIdentifier,
                                       explicitType: nil,
                                       expression: Expression.As(expr: index, targetType: clause.valueType),
                                       storage: .stackStorage,
                                       isMutable: false),
                        clause.block
                      ]),
                      else: compileMatchClause(match, clauses.dropLast()))
        }
    }
}
