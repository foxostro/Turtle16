//
//  Expression.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class Expression: AbstractSyntaxTreeNode {
    public var tokens: [Token] {
        var result: [Token] = []
        for child in children {
            result += (child as! Expression).tokens
        }
        return result
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? Expression else { return false }
        guard isBaseClassPartEqual(rhs) else { return false }
        guard tokens == rhs.tokens else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(tokens)
        return hasher.finalize()
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
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Literal else { return false }
            guard isBaseClassPartEqual(rhs) else { return false }
            guard number == rhs.number else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(number)
            return hasher.finalize()
        }
    }
    
    public class Identifier: Expression {
        public let identifier: TokenIdentifier
        public override var tokens: [Token] {
            return [identifier]
        }
        
        public init(identifier: TokenIdentifier) {
            self.identifier = identifier
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Identifier else { return false }
            guard isBaseClassPartEqual(rhs) else { return false }
            guard identifier == rhs.identifier else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(identifier)
            return hasher.finalize()
        }
    }
    
    public class Unary: Expression {
        public let op: TokenOperator
        
        public var child: Expression {
            children.first as! Expression
        }
        
        public override var tokens: [Token] {
            return [op] + child.tokens
        }
        
        public required init(op: TokenOperator, expression: Expression) {
            self.op = op
            super.init(children: [expression])
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Unary else { return false }
            guard isBaseClassPartEqual(rhs) else { return false }
            guard op == rhs.op else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(op)
            return hasher.finalize()
        }
    }
}
