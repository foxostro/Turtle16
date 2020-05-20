//
//  AbstractSyntaxTreeNode.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

open class AbstractSyntaxTreeNode : NSObject {
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
    
    open override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? AbstractSyntaxTreeNode else { return false }
        guard children == rhs.children else { return false }
        return true
    }
}

public func ==(lhs: AbstractSyntaxTreeNode, rhs: AbstractSyntaxTreeNode) -> Bool {
    return lhs.isEqual(rhs)
}
