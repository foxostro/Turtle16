//
//  ReturnNode.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class ReturnNode: AbstractSyntaxTreeNode {
    public let lineNumber: Int
    
    public required init(lineNumber: Int) {
        self.lineNumber = lineNumber
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? ReturnNode else { return false }
        guard lineNumber == rhs.lineNumber else { return false }
        return true
    }
}
