//
//  MOVNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class MOVNode: AbstractSyntaxTreeNode {
    public let destination: String
    public let source: String
    
    public required init(destination: String, source: String) {
        self.destination = destination
        self.source = source
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? MOVNode else { return false }
        guard destination == rhs.destination else { return false }
        guard source == rhs.source else { return false }
        return true
    }
}
