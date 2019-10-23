//
//  INXYNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class INXYNode: AbstractSyntaxTreeNode {
    public required init() {
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let _ = rhs as? INXYNode else { return false }
        return true
    }
}
