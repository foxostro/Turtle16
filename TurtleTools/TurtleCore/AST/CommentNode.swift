//
//  CommentNode.swift
//  TurtleCore
//
//  Created by Andrew Fox on 7/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

// Sometimes, such as during source to source translation, we need to represent a comment in the AST.
public class CommentNode: AbstractSyntaxTreeNode {
    public let string: String
    
    public required init(sourceAnchor: SourceAnchor? = nil, string: String) {
        self.string = string
        super.init(sourceAnchor: sourceAnchor)
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> CommentNode {
        CommentNode(sourceAnchor: sourceAnchor, string: string)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? CommentNode else { return false }
        guard string == rhs.string else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(string)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
