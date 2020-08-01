//
//  While.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class While: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let body: AbstractSyntaxTreeNode
    
    public required init(sourceAnchor: SourceAnchor?, condition: Expression, body: AbstractSyntaxTreeNode) {
        self.condition = condition
        self.body = body
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? While else { return false }
        guard condition == rhs.condition else { return false }
        guard body == rhs.body else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(condition)
        hasher.combine(body)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@<%@: condition=\n%@, body=\n%@>",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      condition.makeIndentedDescription(depth: depth + 1),
                      body.makeIndentedDescription(depth: depth + 1))
    }
}
