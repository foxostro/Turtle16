//
//  Expression.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class Expression: AbstractSyntaxTreeNode {
    public let token: Token
    
    public init(token: Token) {
        self.token = token
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? Expression else { return false }
        guard token == rhs.token else { return false }
        return super.isEqual(rhs)
    }
    
    public class Literal: Expression {
        public let number: TokenNumber
        
        public init(number: TokenNumber) {
            self.number = number
            super.init(token: number)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard let rhs = rhs as? Literal else { return false }
            guard number == rhs.number else { return false }
            return super.isEqual(rhs)
        }
    }
}
