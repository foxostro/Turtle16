//
//  GotoIfFalse.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class GotoIfFalse: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let target: String
    
    public init(sourceAnchor: SourceAnchor? = nil,
                condition: Expression,
                target: String) {
        self.condition = condition.withSourceAnchor(sourceAnchor)
        self.target = target
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> GotoIfFalse {
        if (self.sourceAnchor != nil) || (self.sourceAnchor == sourceAnchor) {
            return self
        }
        return GotoIfFalse(sourceAnchor: sourceAnchor,
                           condition: condition,
                           target: target)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? GotoIfFalse else { return false }
        guard condition == rhs.condition else { return false }
        guard target == rhs.target else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(condition)
        hasher.combine(target)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
        let indent1 = makeIndent(depth: depth + 1)
        let expr = condition.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: false)
        return "\(indent)ifFalse goto \(target)\n\(indent1)condition: \(expr)"
    }
}
