//
//  ADDNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class ADDNode: AbstractSyntaxTreeNode {
    public let destination: RegisterName
    
    public required init(destination: RegisterName) {
        self.destination = destination
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? ADDNode else { return false }
        return destination == rhs.destination
    }
}
