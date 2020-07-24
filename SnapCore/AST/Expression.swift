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
        return []
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? Expression else { return false }
        guard tokens == rhs.tokens else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(tokens)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
    
    public class LiteralWord: Expression {
        public let number: TokenNumber
        public override var tokens: [Token] {
            return [number]
        }
        
        public init(number: TokenNumber) {
            self.number = number
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else {
                return false
            }
            guard type(of: rhs!) == type(of: self) else {
                return false
            }
            guard let rhs = rhs as? LiteralWord else {
                return false
            }
            guard number == rhs.number else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(number)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: number=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          number.lexeme)
        }
    }
    
    public class LiteralBoolean: Expression {
        public let boolean: TokenBoolean
        public override var tokens: [Token] {
            return [boolean]
        }
        
        public init(boolean: TokenBoolean) {
            self.boolean = boolean
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? LiteralBoolean else { return false }
            guard boolean == rhs.boolean else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(boolean)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: boolean=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          boolean.lexeme)
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
            guard identifier == rhs.identifier else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(identifier)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: identifier='%@'>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          identifier.lexeme)
        }
    }
    
    public class Unary: Expression {
        public let op: TokenOperator
        public let child: Expression
        
        public override var tokens: [Token] {
            return [op] + child.tokens
        }
        
        public required init(op: TokenOperator, expression: Expression) {
            self.op = op
            self.child = expression
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Unary else { return false }
            guard op == rhs.op else { return false }
            guard child == rhs.child else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(op)
            hasher.combine(child)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: op='%@', expression=\n%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          op.lexeme,
                          child.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class Binary: Expression {
        public let op: TokenOperator
        public let left: Expression
        public let right: Expression
        
        public override var tokens: [Token] {
            return left.tokens + [op] + right.tokens
        }
        
        public required init(op: TokenOperator, left: Expression, right: Expression) {
            self.op = op
            self.left = left
            self.right = right
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Binary else { return false }
            guard op == rhs.op else { return false }
            guard left == rhs.left else { return false }
            guard right == rhs.right else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(op)
            hasher.combine(left)
            hasher.combine(right)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: op='%@',\n%@left=%@,\n%@right=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          op.lexeme,
                          makeIndent(depth: depth + 1),
                          left.makeIndentedDescription(depth: depth + 1),
                          makeIndent(depth: depth + 1),
                          right.makeIndentedDescription(depth: depth + 1))
        }
    }
    
    public class Assignment: Expression {
        public let identifier: TokenIdentifier
        public let child: Expression
        
        public override var tokens: [Token] {
            return [identifier] + child.tokens
        }
        
        public required init(identifier: TokenIdentifier,
                             expression: Expression) {
            self.identifier = identifier
            self.child = expression
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Assignment else { return false }
            guard identifier == rhs.identifier else { return false }
            guard child == rhs.child else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(identifier)
            hasher.combine(child)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: identifier='%@', children=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          identifier.lexeme,
                          child.makeIndentedDescription(depth: depth + 1))
        }
    }
    
    public class InitialAssignment: Assignment {}
    
    public class Call: Expression {
        public let callee: Expression
        public let arguments: [Expression]
        
        public override var tokens: [Token] {
            return callee.tokens + arguments.flatMap({$0.tokens})
        }
        
        public required init(callee: Expression, arguments: [Expression]) {
            self.callee = callee
            self.arguments = arguments
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Call else { return false }
            guard callee == rhs.callee else { return false }
            guard arguments == rhs.arguments else { return false }
            return true
        }
    }
    
    public class As: Expression {
        public let expr: Expression
        public let tokenAs: TokenAs
        public let targetType: SymbolType
        
        public override var tokens: [Token] {
            return expr.tokens + [tokenAs]
        }
        
        public required init(expr: Expression, tokenAs: TokenAs, targetType: SymbolType) {
            self.expr = expr
            self.tokenAs = tokenAs
            self.targetType = targetType
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? As else { return false }
            guard expr == rhs.expr else { return false }
            guard tokenAs == rhs.tokenAs else { return false }
            guard targetType == rhs.targetType else { return false }
            return true
        }
    }
    
    public class Subscript: Expression {
        public let tokenIdentifier: TokenIdentifier
        public let tokenBracketLeft: TokenSquareBracketLeft
        public let expr: Expression
        public let tokenBracketRight: TokenSquareBracketRight
        
        public override var tokens: [Token] {
            return [tokenIdentifier, tokenBracketLeft] + expr.tokens + [tokenBracketRight]
        }
        
        public required init(tokenIdentifier: TokenIdentifier,
                             tokenBracketLeft: TokenSquareBracketLeft,
                             expr: Expression,
                             tokenBracketRight: TokenSquareBracketRight) {
            self.tokenIdentifier = tokenIdentifier
            self.tokenBracketLeft = tokenBracketLeft
            self.expr = expr
            self.tokenBracketRight = tokenBracketRight
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Subscript else { return false }
            guard tokenIdentifier == rhs.tokenIdentifier else { return false }
            guard tokenBracketLeft == rhs.tokenBracketLeft else { return false }
            guard expr == rhs.expr else { return false }
            guard tokenBracketRight == rhs.tokenBracketRight else { return false }
            return true
        }
    }
    
    public class LiteralArray: Expression {
        public let tokenBracketLeft: TokenSquareBracketLeft
        public let elements: [Expression]
        public let tokenBracketRight: TokenSquareBracketRight
        public let explicitElementType: SymbolType?
        
        public override var tokens: [Token] {
            return [tokenBracketLeft] + elements.flatMap({$0.tokens}) + [tokenBracketRight]
        }
        
        public required init(tokenBracketLeft: TokenSquareBracketLeft,
                             elements: [Expression],
                             tokenBracketRight: TokenSquareBracketRight,
                             explicitElementType: SymbolType? = nil) {
            self.tokenBracketLeft = tokenBracketLeft
            self.elements = elements
            self.tokenBracketRight = tokenBracketRight
            self.explicitElementType = explicitElementType
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? LiteralArray else { return false }
            guard tokenBracketLeft == rhs.tokenBracketLeft else { return false }
            guard elements == rhs.elements else { return false }
            guard tokenBracketRight == rhs.tokenBracketRight else { return false }
            guard explicitElementType == rhs.explicitElementType else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(tokenBracketLeft)
            hasher.combine(elements)
            hasher.combine(tokenBracketRight)
            hasher.combine(explicitElementType)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            if let explicitElementType = explicitElementType {
                return String(format: "%@<%@ explicitElementType=%@, elements=[%@]>",
                              wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                              String(describing: type(of: self)),
                              explicitElementType.description,
                              elements.compactMap({$0.description}).joined(separator: ", "))
            } else {
                return String(format: "%@<%@ elements=[%@]>",
                              wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                              String(describing: type(of: self)),
                              elements.compactMap({$0.description}).joined(separator: ", "))
            }
        }
    }
    
    // Useful for testing
    public class UnsupportedExpression : Expression {}
}
