//
//  If.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// An `if` statement with a then branch and an else branch
public final class If: AbstractSyntaxTreeNode {
    public let condition: Expression
    public let thenBranch: AbstractSyntaxTreeNode
    public let elseBranch: AbstractSyntaxTreeNode?
    
    public required init(sourceAnchor: SourceAnchor? = nil,
                         condition: Expression,
                         then thenBranch: AbstractSyntaxTreeNode,
                         else elseBranch: AbstractSyntaxTreeNode? = nil,
                         id: ID = ID()) {
        // TODO: There's no good reason to modify the source anchors here in `If'
        self.condition = condition.withSourceAnchor(sourceAnchor)
        self.thenBranch = thenBranch.withSourceAnchor(sourceAnchor)
        self.elseBranch = elseBranch?.withSourceAnchor(sourceAnchor)
        super.init(sourceAnchor: sourceAnchor, id: id)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> If {
        If(sourceAnchor: sourceAnchor,
           condition: condition,
           then: thenBranch,
           else: elseBranch,
           id: id)
    }
    
    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? If else { return false }
        guard condition == rhs.condition else { return false }
        guard thenBranch == rhs.thenBranch else { return false }
        guard elseBranch == rhs.elseBranch else { return false }
        return true
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(condition)
        hasher.combine(thenBranch)
        hasher.combine(elseBranch)
    }
    
    public override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
        String(format: "%@%@\n%@condition: %@\n%@then: %@\n%@else: %@",
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
