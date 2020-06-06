//
//  ForLoop.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/6/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class ForLoop: AbstractSyntaxTreeNode {
    public var initializerClause: AbstractSyntaxTreeNode {
        children[0]
    }
    
    public var conditionClause: AbstractSyntaxTreeNode {
        children[1]
    }
    
    public var incrementClause: AbstractSyntaxTreeNode {
        children[2]
    }
    
    public var body: AbstractSyntaxTreeNode {
        children[3]
    }
    
    public required init(initializerClause: AbstractSyntaxTreeNode,
                         conditionClause: AbstractSyntaxTreeNode,
                         incrementClause: AbstractSyntaxTreeNode,
                         body: AbstractSyntaxTreeNode) {
        super.init(children: [initializerClause,
                              conditionClause,
                              incrementClause,
                              body])
    }
}
