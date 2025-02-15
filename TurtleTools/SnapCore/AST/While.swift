//
//  While.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// A class `while` loop
public final class While: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let body: AbstractSyntaxTreeNode
    
    public init(sourceAnchor: SourceAnchor? = nil,
                condition: Expression,
                body: AbstractSyntaxTreeNode,
                id: ID = ID()) {
        self.condition = condition.withSourceAnchor(sourceAnchor)
        self.body = body.withSourceAnchor(sourceAnchor)
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> While {
        While(sourceAnchor: sourceAnchor,
              condition: condition,
              body: body,
              id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard condition == rhs.condition else { return false }
        guard body == rhs.body else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(condition)
        hasher.combine(body)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        String(format: "%@%@\n%@condition: %@\n%@body: %@",
               wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
               String(describing: type(of: self)),
               makeIndent(depth: depth + 1),
               condition.makeIndentedDescription(depth: depth + 1),
               makeIndent(depth: depth + 1),
               body.makeIndentedDescription(depth: depth + 1))
    }
}
