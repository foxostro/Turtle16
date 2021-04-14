//
//  If.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class If: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let thenBranch: AbstractSyntaxTreeNode
    public let elseBranch: AbstractSyntaxTreeNode?
    
    public convenience init(condition: Expression,
                            then thenBranch: AbstractSyntaxTreeNode,
                            else elseBranch: AbstractSyntaxTreeNode?) {
        self.init(sourceAnchor: nil,
                  condition: condition,
                  then: thenBranch,
                  else: elseBranch)
    }
    
    public required init(sourceAnchor: SourceAnchor?,
                         condition: Expression,
                         then thenBranch: AbstractSyntaxTreeNode,
                         else elseBranch: AbstractSyntaxTreeNode?) {
        self.condition = condition
        self.thenBranch = thenBranch
        self.elseBranch = elseBranch
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? If else { return false }
        guard condition == rhs.condition else { return false }
        guard thenBranch == rhs.thenBranch else { return false }
        guard elseBranch == rhs.elseBranch else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(condition)
        hasher.combine(thenBranch)
        hasher.combine(elseBranch)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        return String(format: "%@%@\n%@condition: %@\n%@then: %@\n%@else: %@",
                      wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                      String(describing: type(of: self)),
                      makeIndent(depth: depth + 1),
                      condition.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      thenBranch.makeIndentedDescription(depth: depth + 1),
                      makeIndent(depth: depth + 1),
                      elseBranch?.makeIndentedDescription(depth: depth + 1) ?? "nil")
    }
}
