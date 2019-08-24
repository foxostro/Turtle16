//
//  LoadNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class LoadNode: AbstractSyntaxTreeNode {
    let destination: String
    let sourceAddress: Token
    
    public required init(destination: String, sourceAddress: Token) {
        assert(sourceAddress.type == .number)
        self.destination = destination
        self.sourceAddress = sourceAddress
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? LoadNode else { return false }
        guard destination == rhs.destination else { return false }
        guard sourceAddress == rhs.sourceAddress else { return false }
        return true
    }
}
