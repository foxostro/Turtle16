//
//  StoreNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/23/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class StoreNode: AbstractSyntaxTreeNode {
    let destinationAddress: TokenNumber
    let source: RegisterName
    
    public required init(destinationAddress: TokenNumber, source: RegisterName) {
        self.destinationAddress = destinationAddress
        self.source = source
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? StoreNode else { return false }
        guard destinationAddress == rhs.destinationAddress else { return false }
        guard source == rhs.source else { return false }
        return true
    }
}
