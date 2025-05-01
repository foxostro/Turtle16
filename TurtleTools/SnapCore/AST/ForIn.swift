//
//  ForIn.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/18/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// A for-in statement iterates elements of a sequence expression
public final class ForIn: AbstractSyntaxTreeNode {
    public let identifier: Identifier
    public let sequenceExpr: Expression
    public let body: Block

    public init(
        sourceAnchor: SourceAnchor? = nil,
        identifier: Identifier,
        sequenceExpr: Expression,
        body: Block,
        id: ID = ID()
    ) {
        self.identifier = identifier.withSourceAnchor(sourceAnchor)
        self.sequenceExpr = sequenceExpr.withSourceAnchor(sourceAnchor)
        self.body = body.withSourceAnchor(sourceAnchor)
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ForIn {
        ForIn(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            sequenceExpr: sequenceExpr,
            body: body,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard identifier == rhs.identifier else { return false }
        guard sequenceExpr == rhs.sequenceExpr else { return false }
        guard body == rhs.body else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(identifier)
        hasher.combine(sequenceExpr)
        hasher.combine(body)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        return """
            \(indent0)\(selfDesc)
            \(indent0)identifier: \(identifier.makeIndentedDescription(depth: depth+1))
            \(indent1)sequenceExpr: \(sequenceExpr.makeIndentedDescription(depth: depth + 1))
            \(indent1)body: \(body.makeIndentedDescription(depth: depth + 1))
            """
    }
}
