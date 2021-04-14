//
//  Assert.swift
//  SnapCore
//
//  Created by Andrew Fox on 10/1/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Assert: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let message: String
    
    public convenience init(condition: Expression, message: String) {
        self.init(sourceAnchor: nil,
                  condition: condition,
                  message: message)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         condition: Expression,
                         message: String) {
        self.condition = condition
        self.message = message
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Assert else { return false }
        guard condition == rhs.condition else { return false }
        guard message == rhs.message else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(condition)
        hasher.combine(message)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@condition: %@\n%@message: %@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      makeIndent(depth: depth + 1),
                      condition.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      message)
    }
}
