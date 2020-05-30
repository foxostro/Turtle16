//
//  If.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/30/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class If: AbstractSyntaxTreeNode {
    public var condition: Expression {
        children[0] as! Expression
    }
    
    public var thenBranch: AbstractSyntaxTreeNode {
        children[1]
    }
    
    public var elseBranch: AbstractSyntaxTreeNode? {
        if children.count <= 2 {
            return nil
        } else {
            return children[2]
        }
    }
    
    public required init(condition: Expression,
                         then thenBranch: AbstractSyntaxTreeNode,
                         else elseBranch: AbstractSyntaxTreeNode?) {
        if let elseBranch = elseBranch {
            super.init(children: [condition, thenBranch, elseBranch])
        } else {
            super.init(children: [condition, thenBranch])
        }
    }
}
