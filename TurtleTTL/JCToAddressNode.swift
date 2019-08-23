//
//  JCToAddressNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class JCToAddressNode: AbstractSyntaxTreeNode {
    public let address: Int
    
    public init(address: Int) {
        self.address = address
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? JCToAddressNode else { return false }
        return address == rhs.address
    }
}
