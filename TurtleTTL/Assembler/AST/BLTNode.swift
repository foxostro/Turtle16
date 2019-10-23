//
//  BLTNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class BLTNode: AbstractSyntaxTreeNode {
    public let destination: RegisterName
    public let source: RegisterName
    
    public required init(destination: RegisterName, source: RegisterName) {
        self.destination = destination
        self.source = source
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? BLTNode else { return false }
        guard destination == rhs.destination else { return false }
        guard source == rhs.source else { return false }
        return true
    }
}
