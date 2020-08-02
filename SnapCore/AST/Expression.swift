//
//  Expression.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public class Expression: AbstractSyntaxTreeNode {
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard super.isEqual(rhs) else {
            return false
        }
        return true
    }
    
    // Useful for testing
    public class UnsupportedExpression : Expression {}
    
    public class LiteralWord: Expression {
        public let value: Int
        
        public init(sourceAnchor: SourceAnchor? = nil, value: Int) {
            self.value = value
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else {
                return false
            }
            guard type(of: rhs!) == type(of: self) else {
                return false
            }
            guard super.isEqual(rhs) else {
                return false
            }
            guard let rhs = rhs as? LiteralWord else {
                return false
            }
            guard value == rhs.value else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(value)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: value=%d>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          value)
        }
    }
    
    public class LiteralBoolean: Expression {
        public let value: Bool
        
        public init(sourceAnchor: SourceAnchor?, value: Bool) {
            self.value = value
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? LiteralBoolean else { return false }
            guard value == rhs.value else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(value)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: boolean=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          value ? "true" : "false")
        }
    }
    
    public class Identifier: Expression {
        public let identifier: String
        
        public init(sourceAnchor: SourceAnchor?, identifier: String) {
            self.identifier = identifier
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
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
                          identifier)
        }
    }
    
    public class Unary: Expression {
        public let op: TokenOperator.Operator
        public let child: Expression
        
        public init(sourceAnchor: SourceAnchor?, op: TokenOperator.Operator, expression: Expression) {
            self.op = op
            self.child = expression
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
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
                          String(describing: op),
                          child.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class Group: Expression {
        public let expression: Expression
        
        public init(sourceAnchor: SourceAnchor?, expression: Expression) {
            self.expression = expression
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Group else { return false }
            guard expression == rhs.expression else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(expression)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: expression=\n%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          expression.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class Binary: Expression {
        public let op: TokenOperator.Operator
        public let left: Expression
        public let right: Expression
        
        public init(sourceAnchor: SourceAnchor?,
                    op: TokenOperator.Operator,
                    left: Expression,
                    right: Expression) {
            self.op = op
            self.left = left
            self.right = right
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
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
                          String(describing: op),
                          makeIndent(depth: depth + 1),
                          left.makeIndentedDescription(depth: depth + 1),
                          makeIndent(depth: depth + 1),
                          right.makeIndentedDescription(depth: depth + 1))
        }
    }
    
    public class Assignment: Expression {
        public let lexpr: Expression
        public let rexpr: Expression
        
        public init(sourceAnchor: SourceAnchor?, lexpr: Expression, rexpr: Expression) {
            self.lexpr = lexpr
            self.rexpr = rexpr
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Assignment else { return false }
            guard lexpr == rhs.lexpr else { return false }
            guard rexpr == rhs.rexpr else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(lexpr)
            hasher.combine(rexpr)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: lexpr=%@, rexpr=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          lexpr.makeIndentedDescription(depth: depth + 1),
                          rexpr.makeIndentedDescription(depth: depth + 1))
        }
    }
    
    public class InitialAssignment: Assignment {}
    
    public class Call: Expression {
        public let callee: Expression
        public let arguments: [Expression]
        
        public init(sourceAnchor: SourceAnchor?, callee: Expression, arguments: [Expression]) {
            self.callee = callee
            self.arguments = arguments
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Call else { return false }
            guard callee == rhs.callee else { return false }
            guard arguments == rhs.arguments else { return false }
            return true
        }
    }
    
    public class As: Expression {
        public let expr: Expression
        public let targetType: SymbolType
        
        public init(sourceAnchor: SourceAnchor?, expr: Expression, targetType: SymbolType) {
            self.expr = expr
            self.targetType = targetType
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? As else { return false }
            guard expr == rhs.expr else { return false }
            guard targetType == rhs.targetType else { return false }
            return true
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@ convertingTo=%@ expr=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          targetType.description,
                          expr.makeIndentedDescription(depth: depth))
        }
    }
    
    public class Subscript: Expression {
        public let identifier: Expression.Identifier
        public let expr: Expression
        
        public init(sourceAnchor: SourceAnchor?, identifier: Expression.Identifier, expr: Expression) {
            self.identifier = identifier
            self.expr = expr
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Subscript else { return false }
            guard identifier == rhs.identifier else { return false }
            guard expr == rhs.expr else { return false }
            return true
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@ identifier=%@ argument=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          identifier.makeIndentedDescription(depth: depth),
                          expr.makeIndentedDescription(depth: depth))
        }
    }
    
    public class LiteralArray: Expression {
        public let explicitType: SymbolType
        public let explicitCount: Int?
        public let elements: [Expression]
        
        public init(sourceAnchor: SourceAnchor?,
                    explicitType: SymbolType,
                    explicitCount: Int?,
                    elements: [Expression] = []) {
            self.explicitType = explicitType
            self.explicitCount = explicitCount
            self.elements = elements
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? LiteralArray else { return false }
            guard explicitType == rhs.explicitType else { return false }
            guard explicitCount == rhs.explicitCount else { return false }
            guard elements == rhs.elements else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(explicitType)
            hasher.combine(explicitCount)
            hasher.combine(elements)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@ explicitType=%@, explicitCount=%@, elements=[\n%@\n]>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          explicitType.description,
                          explicitCount?.description ?? "nil",
                          elements.compactMap({$0.makeIndentedDescription(depth: depth+1, wantsLeadingWhitespace:  true)}).joined(separator: ",\n"))
        }
    }
    
    public class Get: Expression {
        public let expr: Expression
        public let member: Identifier
        
        public init(sourceAnchor: SourceAnchor?, expr: Expression, member: Identifier) {
            self.expr = expr
            self.member = member
            super.init(sourceAnchor: sourceAnchor)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Get else { return false }
            guard expr == rhs.expr else { return false }
            guard member == rhs.member else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(expr)
            hasher.combine(member)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@: expr=%@, member=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          expr.makeIndentedDescription(depth: depth+1),
                          member.makeIndentedDescription(depth: depth+1))
        }
    }
}
