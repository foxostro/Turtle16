//
//  Match.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Match: AbstractSyntaxTreeNode {
    public class Clause: NSObject {
        public let sourceAnchor: SourceAnchor?
        public let valueIdentifier: Expression.Identifier
        public let valueType: Expression
        public let block: Block
        
        public convenience init(valueIdentifier: Expression.Identifier,
                                valueType: Expression,
                                block: Block) {
            self.init(sourceAnchor: nil,
                      valueIdentifier: valueIdentifier,
                      valueType: valueType,
                      block: block)
        }
        
        public init(sourceAnchor: SourceAnchor?,
                    valueIdentifier: Expression.Identifier,
                    valueType: Expression,
                    block: Block) {
            self.sourceAnchor = sourceAnchor
            self.valueIdentifier = valueIdentifier
            self.valueType = valueType
            self.block = block
        }
        
        public static func ==(lhs: Clause, rhs: Clause) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else {
                return false
            }
            guard let rhs = rhs as? Clause else {
                return false
            }
            guard sourceAnchor == rhs.sourceAnchor else {
                return false
            }
            guard valueIdentifier == rhs.valueIdentifier else {
                return false
            }
            guard valueType == rhs.valueType else {
                return false
            }
            guard block == rhs.block else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(sourceAnchor)
            hasher.combine(valueIdentifier)
            hasher.combine(valueType)
            hasher.combine(block)
            return hasher.finalize()
        }
    }
    
    public let expr: Expression
    public let clauses: [Clause]
    public let elseClause: Block?
    
    public convenience init(expr: Expression,
                            clauses: [Clause],
                            elseClause: Block?) {
        self.init(sourceAnchor: nil,
                  expr: expr,
                  clauses: clauses,
                  elseClause: elseClause)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         expr: Expression,
                         clauses: [Clause],
                         elseClause: Block?) {
        self.expr = expr
        self.clauses = clauses
        self.elseClause = elseClause
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard super.isEqual(rhs) else {
            return false
        }
        guard let rhs = rhs as? Match else {
            return false
        }
        guard sourceAnchor == rhs.sourceAnchor else {
            print("lhs sourceAnchor: \(String(describing: sourceAnchor))")
            print("rhs sourceAnchor: \(String(describing: rhs.sourceAnchor))")
            return false
        }
        guard expr == rhs.expr else {
            return false
        }
        guard clauses == rhs.clauses else {
            return false
        }
        guard elseClause == rhs.elseClause else {
            return false
        }
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
        return String(format: "%@%@\n%@expr: %@\n%@clauses: %@\n%@elseClause: %@",
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
