//
//  StoreImmediateNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class StoreImmediateNode: AbstractSyntaxTreeNode {
    let destinationAddress: Token
    let immediate: Int
    
    public required init(destinationAddress: Token, immediate: Int) {
        assert(destinationAddress.type == .number)
        self.destinationAddress = destinationAddress
        self.immediate = immediate
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? StoreImmediateNode else { return false }
        guard destinationAddress == rhs.destinationAddress else { return false }
        guard immediate == rhs.immediate else { return false }
        return true
    }
}
