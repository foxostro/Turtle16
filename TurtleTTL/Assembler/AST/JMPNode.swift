//
//  JMPNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 10/21/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class JMPNode: AbstractSyntaxTreeNode {
    public init() {
        super.init(children: [])
    }

    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let _ = rhs as? JMPNode else { return false }
        return true
    }
}
