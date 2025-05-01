//
//  CommentNode.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

// Sometimes, such as during source to source translation, we need to represent a comment in the AST.
public final class CommentNode: AbstractSyntaxTreeNode {
    public let string: String

    public required init(
        sourceAnchor: SourceAnchor? = nil,
        string: String,
        id: ID = ID()
    ) {
        self.string = string
        super.init(sourceAnchor: sourceAnchor, id: id)
    }

    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> CommentNode {
        CommentNode(sourceAnchor: sourceAnchor, string: string)
    }

    public override func isEqual(_ rhs: AbstractSyntaxTreeNode) -> Bool {
        guard super.isEqual(rhs) else { return false }
        guard let rhs = rhs as? Self else { return false }
        guard string == rhs.string else { return false }
        return true
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(string)
    }
}
