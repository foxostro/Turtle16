//
//  Expression.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class Expression: AbstractSyntaxTreeNode {
    public var tokens: [Token] {
        var result: [Token] = []
        for child in children {
            result += (child as! Expression).tokens
        }
        return result
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? Expression else { return false }
        guard tokens == rhs.tokens else { return false }
        return super.isEqual(rhs)
    }
    
    public class Literal: Expression {
        public let number: TokenNumber
        public override var tokens: [Token] {
            return [number]
        }
        
        public init(number: TokenNumber) {
            self.number = number
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard let rhs = rhs as? Literal else { return false }
            guard number == rhs.number else { return false }
            return super.isEqual(rhs)
        }
    }
}
