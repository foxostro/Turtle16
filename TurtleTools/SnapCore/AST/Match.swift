//
//  Match.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// A match statement is like a switch on the type of an expression
public final class Match: AbstractSyntaxTreeNode {
    public struct Clause: Hashable {
        public let sourceAnchor: SourceAnchor?
        public let valueIdentifier: Identifier
        public let valueType: Expression
        public let block: Block

        public init(
            sourceAnchor: SourceAnchor? = nil,
            valueIdentifier: Identifier,
            valueType: Expression,
            block: Block
        ) {
            self.sourceAnchor = sourceAnchor
            self.valueIdentifier = valueIdentifier
            self.valueType = valueType
            self.block = block
        }
    }

    public let expr: Expression
    public let clauses: [Clause]
    public let elseClause: Block?

    public init(
        sourceAnchor: SourceAnchor? = nil,
        expr: Expression,
        clauses: [Clause],
        elseClause: Block?,
        id: ID = ID()
    ) {
        self.expr = expr
        self.clauses = clauses
        self.elseClause = elseClause
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Match {
        Match(
            sourceAnchor: sourceAnchor,
            expr: expr,
            clauses: clauses,
            elseClause: elseClause,
            id: id
        )
    }
    
    public func withExpr(_ expr: Expression) -> Match {
        Match(
            sourceAnchor: sourceAnchor,
            expr: expr,
            clauses: clauses,
            elseClause: elseClause,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard sourceAnchor == rhs.sourceAnchor else { return false }
        guard expr == rhs.expr else { return false }
        guard clauses == rhs.clauses else { return false }
        guard elseClause == rhs.elseClause else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(sourceAnchor)
        hasher.combine(expr)
        hasher.combine(clauses)
        hasher.combine(elseClause)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        let elseDesc =
            elseClause == nil ? "nil" : elseClause!.makeIndentedDescription(depth: depth + 1)
        return """
            \(indent0)\(selfDesc)
            \(indent1)expr: \(expr.makeIndentedDescription(depth: depth + 1))
            \(indent1)clauses: \(makeClausesDescription(depth: depth + 1))
            \(indent1)elseClause: \(elseDesc)
            """
    }

    private func makeClausesDescription(depth: Int) -> String {
        var result = ""
        for clause in clauses {
            result += "\n"
            result += makeIndent(depth: depth + 1)
            result += "\(clause)"
        }
        return result
    }
}
