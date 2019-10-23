//
//  JALRNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 10/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class JALRNode: AbstractSyntaxTreeNode {
    public let identifier: TokenIdentifier
    
    public init(token identifier: TokenIdentifier) {
        self.identifier = identifier
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? JALRNode else { return false }
        return identifier == rhs.identifier
    }
}
