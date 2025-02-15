//
//  Match.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Match: AbstractSyntaxTreeNode {
    public struct Clause: Hashable {
        public let sourceAnchor: SourceAnchor?
        public let valueIdentifier: Expression.Identifier
        public let valueType: Expression
        public let block: Block
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    valueIdentifier: Expression.Identifier,
                    valueType: Expression,
                    block: Block) {
            self.sourceAnchor = sourceAnchor
            self.valueIdentifier = valueIdentifier
            self.valueType = valueType
            self.block = block
        }
    }
    
    public let expr: Expression
    public let clauses: [Clause]
    public let elseClause: Block?
    
    public init(sourceAnchor: SourceAnchor? = nil,
                expr: Expression,
                clauses: [Clause],
                elseClause: Block?,
                id: ID = ID()) {
        self.expr = expr
        self.clauses = clauses
        self.elseClause = elseClause
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Match {
        Match(sourceAnchor: sourceAnchor,
              expr: expr,
              clauses: clauses,
              elseClause: elseClause,
              id: id)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Match else { return false }
        guard sourceAnchor == rhs.sourceAnchor else { return false }
        guard expr == rhs.expr else { return false }
        guard clauses == rhs.clauses else { return false }
        guard elseClause == rhs.elseClause else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(sourceAnchor)
        hasher.combine(expr)
        hasher.combine(clauses)
        hasher.combine(elseClause)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        String(format: "%@%@\n%@expr: %@\n%@clauses: %@\n%@elseClause: %@",
               wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
               String(describing: type(of: self)),
               makeIndent(depth: depth + 1),
               expr.makeIndentedDescription(depth: depth + 1),
               makeIndent(depth: depth + 1),
               makeClausesDescription(depth: depth + 1),
               makeIndent(depth: depth + 1),
               elseClause==nil ? "nil" : elseClause!.makeIndentedDescription(depth: depth + 1))
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
