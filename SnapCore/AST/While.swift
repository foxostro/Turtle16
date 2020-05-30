//
//  While.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class While: AbstractSyntaxTreeNode {
    public var condition: Expression {
        children[0] as! Expression
    }
    
    public var body: AbstractSyntaxTreeNode {
        children[1]
    }
    
    public required init(condition: Expression, body: AbstractSyntaxTreeNode) {
        super.init(children: [condition, body])
    }
}
