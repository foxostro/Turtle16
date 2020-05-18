//
//  Expression.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class Expression: AbstractSyntaxTreeNode {
    public let lineNumber: Int
    
    public init(lineNumber: Int) {
        self.lineNumber = lineNumber
        super.init(children: [])
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? Expression else { return false }
        guard lineNumber == rhs.lineNumber else { return false }
        return true
    }
    
    public class Literal: Expression {
        public let number: TokenNumber
        
        public init(lineNumber: Int, number: TokenNumber) {
            self.number = number
            super.init(lineNumber: lineNumber)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard let rhs = rhs as? Literal else { return false }
            guard number == rhs.number else { return false }
            return super.isEqual(rhs)
        }
    }
}
