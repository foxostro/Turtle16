//
//  GotoIfFalse.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Conditional branch: jump to the target if the condition is false
public final class GotoIfFalse: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let target: String
    
    public init(sourceAnchor: SourceAnchor? = nil,
                condition: Expression,
                target: String,
                id: ID = ID()) {
        self.condition = condition.withSourceAnchor(sourceAnchor)
        self.target = target
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> GotoIfFalse {
        GotoIfFalse(sourceAnchor: sourceAnchor,
                    condition: condition,
                    target: target,
                    id: id)
    }
    
    public func withCondition(_ condition: Expression) -> GotoIfFalse {
        GotoIfFalse(sourceAnchor: sourceAnchor,
                    condition: condition,
                    target: target,
                    id: id)
    }
    
    public func withTarget(_ target: String) -> GotoIfFalse {
        GotoIfFalse(sourceAnchor: sourceAnchor,
                    condition: condition,
                    target: target,
                    id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard condition == rhs.condition else { return false }
        guard target == rhs.target else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(condition)
        hasher.combine(target)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        let expr = condition.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: false)
        return "\(indent)ifFalse goto \(target)\n\(indent1)condition: \(expr)"
    }
}
