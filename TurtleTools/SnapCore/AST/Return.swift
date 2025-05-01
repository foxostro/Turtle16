//
//  Return.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Return statement, optionally returning a value
public final class Return: AbstractSyntaxTreeNode {
    public let expression: Expression?

    public convenience init(_ expr: Expression?) {
        self.init(expression: expr)
    }

    public init(
        sourceAnchor: SourceAnchor? = nil,
        expression: Expression? = nil,
        id: ID = ID()
    ) {
        self.expression = expression
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Return {
        Return(
            sourceAnchor: sourceAnchor,
            expression: expression,
            id: id
        )
    }

    public func withExpression(_ expression: Expression?) -> Return {
        Return(
            sourceAnchor: sourceAnchor,
            expression: expression,
            id: id
        )
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard expression == rhs.expression else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(expression)
    }

    public override func makeIndentedDescription(
        depth: Int,
        wantsLeadingWhitespace: Bool = false
    ) -> String {
        let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        let exprDesc = expression?.makeIndentedDescription(depth: depth + 1) ?? "nil"
        return """
            \(indent0)\(selfDesc)
            \(indent1)expr: \(exprDesc)
            """
    }
}
