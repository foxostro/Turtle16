//
//  LINode.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/22/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class LINode: AbstractSyntaxTreeNode {
    public let destination: RegisterName
    public let immediate: TokenNumber
    
    public required init(destination: RegisterName, immediate: TokenNumber) {
        self.destination = destination
        self.immediate = immediate
        super.init(children: [])
    }
    
    public override func accept(visitor: AbstractSyntaxTreeNodeVisitor) throws {
        try visitor.visit(node: self)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? LINode else { return false }
        guard destination == rhs.destination else { return false }
        guard immediate == rhs.immediate else { return false }
        return true
    }
}
