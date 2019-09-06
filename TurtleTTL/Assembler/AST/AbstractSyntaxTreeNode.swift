//
//  AbstractSyntaxTreeNode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AbstractSyntaxTreeNode : NSObject {
    public let children: [AbstractSyntaxTreeNode]
    
    public init(children: [AbstractSyntaxTreeNode] = []) {
        self.children = children
    }
    
    public func iterate(closure: (AbstractSyntaxTreeNode) throws -> Void) throws {
        try closure(self)
        for child in children {
            try closure(child)
        }
    }
    
    public func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? AbstractSyntaxTreeNode {
            return self == rhs
        }
        return false
    }
}

public func ==(lhs: AbstractSyntaxTreeNode, rhs: AbstractSyntaxTreeNode) -> Bool {
    return lhs.children == rhs.children
}
