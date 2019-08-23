//
//  LabelDeclarationNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class LabelDeclarationNode: AbstractSyntaxTreeNode {
    public let identifier: Token
    
    public required init(identifier: Token) {
        self.identifier = identifier
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? LabelDeclarationNode else { return false }
        return identifier == rhs.identifier
    }
}
