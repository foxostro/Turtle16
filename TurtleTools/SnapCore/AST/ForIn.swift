//
//  ForIn.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/18/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class ForIn: AbstractSyntaxTreeNode {
    public let identifier: Expression.Identifier
    public let sequenceExpr: Expression
    public let body: Block
    
    public init(sourceAnchor: SourceAnchor? = nil,
                identifier: Expression.Identifier,
                sequenceExpr: Expression,
                body: Block,
                id: ID = ID()) {
        self.identifier = identifier.withSourceAnchor(sourceAnchor)
        self.sequenceExpr = sequenceExpr.withSourceAnchor(sourceAnchor)
        self.body = body.withSourceAnchor(sourceAnchor)
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ForIn {
        ForIn(sourceAnchor: sourceAnchor,
              identifier: identifier,
              sequenceExpr: sequenceExpr,
              body: body,
              id: id)
    }
    
    public static func ==(lhs: ForIn, rhs: ForIn) -> Bool {
        lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? ForIn else { return false }
        guard identifier == rhs.identifier else { return false }
        guard sequenceExpr == rhs.sequenceExpr else { return false }
        guard body == rhs.body else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(sequenceExpr)
        hasher.combine(body)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        String(format: "%@%@\n%@identifier: %@\n%@sequenceExpr: %@\n%@body: %@",
               wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
               String(describing: type(of: self)),
               makeIndent(depth: depth + 1),
               identifier.makeIndentedDescription(depth: depth + 1),
               makeIndent(depth: depth + 1),
               sequenceExpr.makeIndentedDescription(depth: depth + 1),
               makeIndent(depth: depth + 1),
               body.makeIndentedDescription(depth: depth + 1))
    }
}
