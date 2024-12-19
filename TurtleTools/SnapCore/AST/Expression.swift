//
//  Expression.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Expression: AbstractSyntaxTreeNode {
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard rhs is Expression else { return false }
        guard super.isEqual(rhs) else { return false }
        return true
    }
    
    public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Expression {
        fatalError("withSourceAnchor() is unimplemented for \(self)")
    }
    
    // Useful for testing
    public class UnsupportedExpression : Expression {
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> UnsupportedExpression {
            UnsupportedExpression(
                sourceAnchor: sourceAnchor,
                id: id)
        }
    }
    
    public class LiteralInt: Expression {
        public let value: Int
        
        public convenience init(_ value: Int) {
            self.init(sourceAnchor: nil, value: value)
        }
        
        public init(sourceAnchor: SourceAnchor?, value: Int, id: ID = ID()) {
            self.value = value
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> LiteralInt {
            LiteralInt(
                sourceAnchor: sourceAnchor,
                value: value,
                id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? LiteralInt else { return false }
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
            let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let result = "\(indent)\(value)"
            return result
        }
    }
    
    public class LiteralBool: Expression {
        public let value: Bool
        
        public convenience init(_ value: Bool) {
            self.init(sourceAnchor: nil, value: value)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    value: Bool,
                    id: ID = ID()) {
            self.value = value
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> LiteralBool {
            LiteralBool(sourceAnchor: sourceAnchor,
                        value: value,
                        id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? LiteralBool else { return false }
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
            let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let valStr = value ? "true" : "false"
            let result = "\(indent)\(valStr)"
            return result
        }
    }
    
    public class Identifier: Expression {
        public let identifier: String
        
        public convenience init(_ identifier: String) {
            self.init(identifier: identifier)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    identifier: String,
                    id: ID = ID()) {
            self.identifier = identifier
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Identifier {
            Identifier(sourceAnchor: sourceAnchor,
                       identifier: identifier,
                       id: id)
        }
        
        public func withIdentifier(_ identifier: String) -> Identifier {
            Identifier(sourceAnchor: sourceAnchor,
                       identifier: identifier,
                       id: id)
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
            let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let result = "\(indent)\(identifier)"
            return result
        }
    }
    
    public class Unary: Expression {
        public let op: TokenOperator.Operator
        public let child: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    op: TokenOperator.Operator,
                    expression: Expression,
                    id: ID = ID()) {
            self.op = op
            self.child = expression
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Unary {
            Unary(sourceAnchor: sourceAnchor,
                  op: op,
                  expression: child,
                  id: id)
        }
        
        public func withExpression(_ expression: Expression) -> Unary {
            Unary(sourceAnchor: sourceAnchor,
                  op: op,
                  expression: child,
                  id: id)
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
            String(format: "%@%@\n%@op: %@\n%@expr: %@",
                   wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                   String(describing: type(of: self)),
                   makeIndent(depth: depth+1),
                   String(describing: op),
                   makeIndent(depth: depth+1),
                   child.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class Group: Expression {
        public let expression: Expression
        
        public convenience init(_ expression: Expression) {
            self.init(sourceAnchor: nil, expression: expression)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    expression: Expression,
                    id: ID = ID()) {
            self.expression = expression
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Group {
            Group(sourceAnchor: sourceAnchor,
                  expression: expression,
                  id: id)
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
            String(format: "%@%@\n%@",
                   wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                   String(describing: type(of: self)),
                   expression.makeIndentedDescription(depth: depth+1, wantsLeadingWhitespace: true))
        }
    }
    
    // A linear sequence of expressions, the value of which is determined by the last expression
    public class Eseq: Expression {
        public let children: [Expression]
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    children: [Expression],
                    id: ID = ID()) {
            self.children = children
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Eseq {
            Eseq(sourceAnchor: sourceAnchor,
                 children: children,
                 id: id)
        }
        
        public func withChildren(_ children: [Expression]) -> Eseq {
            Eseq(sourceAnchor: sourceAnchor,
                 children: children,
                 id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Eseq else { return false }
            guard children == rhs.children else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(children)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            let leading = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            
            let typeDesc = String(describing: type(of: self))
            
            var childrenDesc = children.map {
                $0.makeIndentedDescription(depth: depth+1, wantsLeadingWhitespace: true)
            }.joined(separator: "\n")
            if children.count > 0 {
                childrenDesc = "\n" + childrenDesc
            }
            
            let result = leading + typeDesc + childrenDesc
            return result
        }
    }
    
    public class Binary: Expression {
        public let op: TokenOperator.Operator
        public let left: Expression
        public let right: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    op: TokenOperator.Operator,
                    left: Expression,
                    right: Expression,
                    id: ID = ID()) {
            self.op = op
            self.left = left
            self.right = right
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Binary {
            Binary(sourceAnchor: sourceAnchor,
                   op: op,
                   left: left,
                   right: right,
                   id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
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
            String(format: "%@%@\n%@op: %@\n%@left: %@\n%@right: %@",
                   wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                   String(describing: type(of: self)),
                   makeIndent(depth: depth + 1),
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
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    lexpr: Expression,
                    rexpr: Expression,
                    id: ID = ID()) {
            self.lexpr = lexpr
            self.rexpr = rexpr
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Assignment {
            Assignment(sourceAnchor: sourceAnchor,
                       lexpr: lexpr,
                       rexpr: rexpr,
                       id: id)
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
            String(format: "%@%@\n%@lexpr: %@\n%@rexpr: %@",
                   wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                   String(describing: type(of: self)),
                   makeIndent(depth: depth+1),
                   lexpr.makeIndentedDescription(depth: depth + 1),
                   makeIndent(depth: depth+1),
                   rexpr.makeIndentedDescription(depth: depth + 1))
        }
    }
    
    public class InitialAssignment: Assignment {
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> InitialAssignment {
            InitialAssignment(sourceAnchor: sourceAnchor,
                              lexpr: lexpr,
                              rexpr: rexpr,
                              id: id)
        }
    }
    
    public class Call: Expression {
        public let callee: Expression
        public let arguments: [Expression]
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    callee: Expression,
                    arguments: [Expression] = [],
                    id: ID = ID()) {
            self.callee = callee
            self.arguments = arguments
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Call {
            Call(sourceAnchor: sourceAnchor,
                 callee: callee,
                 arguments: arguments,
                 id: id)
        }
        
        public func withCallee(_ callee: Expression) -> Call {
            Call(sourceAnchor: sourceAnchor,
                 callee: callee,
                 arguments: arguments,
                 id: id)
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
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@callee: %@\n%@arguments: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth + 1),
                          callee.makeIndentedDescription(depth: depth + 1),
                          makeIndent(depth: depth + 1),
                          makeArgumentsDescription(depth: depth + 1))
        }
        
        private func makeArgumentsDescription(depth: Int) -> String {
            var result: String = ""
            if arguments.isEmpty {
                result = "none"
            } else {
                for i in 0..<arguments.count {
                    let argument = arguments[i]
                    result += "\n"
                    result += makeIndent(depth: depth + 1)
                    result += "\(i) -- "
                    result += argument.makeIndentedDescription(depth: depth + 1)
                }
            }
            return result
        }
    }
    
    public class As: Expression {
        public let expr: Expression
        public let targetType: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    expr: Expression,
                    targetType: Expression,
                    id: ID = ID()) {
            self.expr = expr
            self.targetType = targetType
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> As {
            As(sourceAnchor: sourceAnchor,
               expr: expr,
               targetType: targetType,
               id: id)
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
            return String(format: "%@%@\n%@convertingTo: %@\n%@expr: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          targetType.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          expr.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class Bitcast: Expression {
        public let expr: Expression
        public let targetType: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    expr: Expression,
                    targetType: Expression,
                    id: ID = ID()) {
            self.expr = expr
            self.targetType = targetType
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Bitcast {
            Bitcast(sourceAnchor: sourceAnchor,
                    expr: expr,
                    targetType: targetType,
                    id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Bitcast else { return false }
            guard expr == rhs.expr else { return false }
            guard targetType == rhs.targetType else { return false }
            return true
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@convertingTo: %@\n%@expr: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          targetType.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          expr.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class Is: Expression {
        public let expr: Expression
        public let testType: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    expr: Expression,
                    testType: Expression,
                    id: ID = ID()) {
            self.expr = expr
            self.testType = testType
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Is {
            Is(sourceAnchor: sourceAnchor,
               expr: expr,
               testType: testType,
               id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Is else { return false }
            guard expr == rhs.expr else { return false }
            guard testType == rhs.testType else { return false }
            return true
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@comparingWith: %@\n%@expr: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          testType.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          expr.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class Subscript: Expression {
        public let subscriptable: Expression
        public let argument: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    subscriptable: Expression,
                    argument: Expression,
                    id: ID = ID()) {
            self.subscriptable = subscriptable
            self.argument = argument
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Subscript {
            Subscript(sourceAnchor: sourceAnchor,
                      subscriptable: subscriptable,
                      argument: argument,
                      id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? Subscript else { return false }
            guard subscriptable == rhs.subscriptable else { return false }
            guard argument == rhs.argument else { return false }
            return true
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@subscriptable: %@\n%@argument: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          subscriptable.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          argument.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class LiteralArray: Expression {
        public let arrayType: Expression
        public let elements: [Expression]
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    arrayType: Expression,
                    elements: [Expression] = [],
                    id: ID = ID()) {
            self.arrayType = arrayType
            self.elements = elements
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> LiteralArray {
            LiteralArray(sourceAnchor: sourceAnchor,
                         arrayType: arrayType,
                         elements: elements,
                         id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? LiteralArray else { return false }
            guard arrayType == rhs.arrayType else { return false }
            guard elements == rhs.elements else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(arrayType)
            hasher.combine(elements)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@arrayType: %@\n%@elements: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          arrayType.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          makeElementsDescription(depth: depth+1))
        }
        
        private func makeElementsDescription(depth: Int) -> String {
            var result: String = ""
            if elements.isEmpty {
                result = "none"
            } else {
                for element in elements {
                    result += "\n"
                    result += element.makeIndentedDescription(depth: depth + 1, wantsLeadingWhitespace: true)
                }
            }
            return result
        }
    }
    
    public class Get: Expression {
        public let expr: Expression
        public let member: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    expr: Expression,
                    member: Expression,
                    id: ID = ID()) {
            self.expr = expr
            self.member = member
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> Get {
            Get(sourceAnchor: sourceAnchor,
                expr: expr,
                member: member,
                id: id)
        }
        
        public func withExpr(_ expr: Expression) -> Get {
            Get(sourceAnchor: sourceAnchor,
                expr: expr,
                member: member,
                id: id)
        }
        
        public func withMember(_ member: Expression) -> Get {
            Get(sourceAnchor: sourceAnchor,
                expr: expr,
                member: member,
                id: id)
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
            return String(format: "%@%@\n%@expr: %@\n%@member: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          expr.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          member.makeIndentedDescription(depth: depth+1))
        }
    }
    
    public class PrimitiveType: Expression {
        public let typ: SymbolType
        
        public convenience init(_ typ: SymbolType) {
            self.init(typ: typ)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    typ: SymbolType,
                    id: ID = ID()) {
            self.typ = typ
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> PrimitiveType {
            PrimitiveType(sourceAnchor: sourceAnchor,
                          typ: typ,
                          id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? PrimitiveType else { return false }
            guard typ == rhs.typ else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(typ)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          typ.description)
        }
    }
    
    public class DynamicArrayType: Expression {
        public let elementType: Expression
        
        public convenience init(_ elementType: Expression) {
            self.init(elementType: elementType)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    elementType: Expression,
                    id: ID = ID()) {
            self.elementType = elementType
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> DynamicArrayType {
            DynamicArrayType(sourceAnchor: sourceAnchor,
                             elementType: elementType,
                             id: id)
        }
        
        public func withElementType(_ elementType: Expression) -> DynamicArrayType {
            DynamicArrayType(sourceAnchor: sourceAnchor,
                             elementType: elementType,
                             id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? DynamicArrayType else { return false }
            guard elementType == rhs.elementType else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(elementType)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let selfDesc = String(describing: type(of: self))
            let result = "\(indent)\(selfDesc)(\(elementType))"
            return result
        }
    }
    
    public class ArrayType: Expression {
        public let count: Expression?
        public let elementType: Expression
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    count: Expression?,
                    elementType: Expression,
                    id: ID = ID()) {
            self.count = count
            self.elementType = elementType
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ArrayType {
            ArrayType(sourceAnchor: sourceAnchor,
                      count: count,
                      elementType: elementType,
                      id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? ArrayType else { return false }
            guard count == rhs.count else { return false }
            guard elementType == rhs.elementType else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(count)
            hasher.combine(elementType)
            hasher.combine(super.hash)
            return hasher.finalize()
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@count: %@\n%@elementType: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          count?.description ?? "nil",
                          makeIndent(depth: depth+1),
                          elementType.description)
        }
    }

    public class FunctionType: Expression {
        public let name: String?
        public let returnType: Expression
        public let arguments: [Expression]
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    name: String? = nil,
                    returnType: Expression,
                    arguments: [Expression],
                    id: ID = ID()) {
            self.name = name
            self.returnType = returnType
            self.arguments = arguments
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> FunctionType {
            FunctionType(sourceAnchor: sourceAnchor,
                         name: name,
                         returnType: returnType,
                         arguments: arguments,
                         id: id)
        }
        
        public func withName(_ name: String) -> FunctionType {
            FunctionType(sourceAnchor: sourceAnchor,
                         name: name,
                         returnType: returnType,
                         arguments: arguments,
                         id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@name: %@\n%@returnType: %@\n%@arguments: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          name ?? "none",
                          makeIndent(depth: depth+1),
                          returnType.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          makeArgumentsDescription(depth: depth+1))
        }
        
        private func makeArgumentsDescription(depth: Int) -> String {
            var result: String = ""
            if arguments.isEmpty {
                result = "none"
            } else {
                for i in 0..<arguments.count {
                    let argument = arguments[i]
                    result += "\n"
                    result += makeIndent(depth: depth + 1)
                    result += "\(i) -- "
                    result += argument.makeIndentedDescription(depth: depth + 1)
                }
            }
            return result
        }
        
        public static func ==(lhs: FunctionType, rhs: FunctionType) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? FunctionType else { return false }
            guard name == rhs.name else { return false }
            guard returnType == rhs.returnType else { return false }
            guard arguments == rhs.arguments else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(name)
            hasher.combine(returnType)
            hasher.combine(arguments)
            return hasher.finalize()
        }
    }

    // GenericFunctionType is a type function. It evaluates to a concrete
    // function type only when given type arguments to fulfill specified type
    // variables.
    public class GenericFunctionType: Expression {
        public let template: FunctionDeclaration
        public let enclosingImplId: AbstractSyntaxTreeNode.ID?
        
        public var name: String {
            template.identifier.identifier
        }
        
        public var typeArguments: [Expression.Identifier] {
            template.typeArguments.map {
                $0.identifier
            }
        }
        
        public var functionType: Expression.FunctionType {
            template.functionType
        }
        
        public var arguments: [Expression] {
            functionType.arguments
        }
        
        public var returnType: Expression {
            functionType.returnType
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    template: FunctionDeclaration,
                    enclosingImplId: AbstractSyntaxTreeNode.ID? = nil,
                    id: ID = ID()) {
            self.template = template
            self.enclosingImplId = enclosingImplId
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public func withTemplate(_ template: FunctionDeclaration) -> GenericFunctionType {
            GenericFunctionType(
                sourceAnchor: sourceAnchor,
                template: template,
                enclosingImplId: enclosingImplId,
                id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let typeArgumentsDescription = typeArguments.map({$0.description}).joined(separator: ", ")
            let argumentsDescription = zip(template.argumentNames, arguments).map({"\($0.0): \($0.1)"}).joined(separator: ", ")
            return "\(indent)func \(name)[\(typeArgumentsDescription)](\(argumentsDescription)) -> \(returnType)"
        }
        
        public static func ==(lhs: GenericFunctionType, rhs: GenericFunctionType) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? GenericFunctionType else { return false }
            guard template == rhs.template else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(template)
            return hasher.finalize()
        }
    }
    
    // GenericTypeApplication is a type expression. This applies the given
    // type arguments to the generic function type to yield a concrete function
    // type.
    public class GenericTypeApplication: Expression {
        public let identifier: Identifier
        public let arguments: [Expression]
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    identifier: Identifier,
                    arguments: [Expression],
                    id: ID = ID()) {
            self.identifier = identifier
            self.arguments = arguments
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> GenericTypeApplication {
            GenericTypeApplication(sourceAnchor: sourceAnchor,
                                   identifier: identifier,
                                   arguments: arguments,
                                   id: id)
        }
        
        public var shortDescription: String {
            let typeVariablesDescription = arguments.map({$0.description}).joined(separator: ", ")
            return "\(identifier)@[\(typeVariablesDescription)]"
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: """
                                  %@%@
                                  %@identifier: %@
                                  %@arguments: %@
                                  """,
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth+1),
                          identifier.makeIndentedDescription(depth: depth+1),
                          makeIndent(depth: depth+1),
                          makeTypeArgumentsDescription(depth: depth+1))
        }
        
        private func makeTypeArgumentsDescription(depth: Int) -> String {
            var result: String = ""
            if arguments.isEmpty {
                result = "none"
            } else {
                for i in 0..<arguments.count {
                    let arguments = arguments[i]
                    result += "\n"
                    result += makeIndent(depth: depth + 1)
                    result += "\(i) -- "
                    result += arguments.makeIndentedDescription(depth: depth + 1)
                }
            }
            return result
        }
        
        public static func ==(lhs: GenericTypeApplication, rhs: GenericTypeApplication) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? GenericTypeApplication else { return false }
            guard identifier == rhs.identifier else { return false }
            guard arguments == rhs.arguments else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(identifier)
            hasher.combine(arguments)
            return hasher.finalize()
        }
    }
    
    public class GenericTypeArgument: Expression {
        public let identifier: Identifier
        public let constraints: [Identifier]
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    identifier: Identifier,
                    constraints: [Identifier],
                    id: ID = ID()) {
            self.identifier = identifier
            self.constraints = constraints
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> GenericTypeArgument {
            GenericTypeArgument(sourceAnchor: sourceAnchor,
                                identifier: identifier,
                                constraints: constraints,
                                id: id)
        }
        
        public var shortDescription: String {
            if constraints.isEmpty {
                return "\(identifier)"
            }
            else {
                let argsDesc = constraints.map({$0.description}).joined(separator: " + ")
                return "\(identifier): \(argsDesc)"
            }
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            let leading = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let desc = String(describing: type(of: self))
            return "\(leading)\(desc): \(shortDescription)"
        }
        
        public static func ==(lhs: GenericTypeArgument, rhs: GenericTypeArgument) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? GenericTypeArgument else { return false }
            guard identifier == rhs.identifier else { return false }
            guard constraints == rhs.constraints else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(identifier)
            hasher.combine(constraints)
            return hasher.finalize()
        }
    }

    public class PointerType: Expression {
        public let typ: Expression
        
        public convenience init(_ typ: Expression) {
            self.init(sourceAnchor: nil, typ: typ)
        }
        
        public init(sourceAnchor: SourceAnchor?,
                    typ: Expression,
                    id: ID = ID()) {
            self.typ = typ
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> PointerType {
            PointerType(sourceAnchor: sourceAnchor,
                        typ: typ,
                        id: id)
        }
        
        public func withTyp(_ typ: Expression) -> PointerType {
            PointerType(sourceAnchor: sourceAnchor,
                        typ: typ,
                        id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@(%@)",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          typ.makeIndentedDescription(depth: depth+1))
        }
        
        public static func ==(lhs: PointerType, rhs: PointerType) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? PointerType else { return false }
            guard typ == rhs.typ else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(typ)
            return hasher.finalize()
        }
    }

    public class ConstType: Expression {
        public let typ: Expression
        
        public convenience init(_ typ: Expression) {
            self.init(sourceAnchor: nil, typ: typ)
        }
        
        public init(sourceAnchor: SourceAnchor?,
                    typ: Expression,
                    id: ID = ID()) {
            self.typ = typ
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> ConstType {
            ConstType(sourceAnchor: sourceAnchor,
                      typ: typ,
                      id: id)
        }
        
        public func withTyp(_ typ: Expression) -> ConstType {
            ConstType(sourceAnchor: sourceAnchor,
                      typ: typ,
                      id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@(%@)",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          typ.makeIndentedDescription(depth: depth+1))
        }
        
        public static func ==(lhs: ConstType, rhs: ConstType) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? ConstType else { return false }
            guard typ == rhs.typ else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(typ)
            return hasher.finalize()
        }
    }
    
    public class MutableType: Expression {
        public let typ: Expression
        
        public convenience init(_ typ: Expression) {
            self.init(sourceAnchor: nil, typ: typ)
        }
        
        public init(sourceAnchor: SourceAnchor?,
                    typ: Expression,
                    id: ID = ID()) {
            self.typ = typ
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> MutableType {
            MutableType(sourceAnchor: sourceAnchor,
                        typ: typ,
                        id: id)
        }
        
        public func withTyp(_ typ: Expression) -> MutableType {
            MutableType(sourceAnchor: sourceAnchor,
                        typ: typ,
                        id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            let indent = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let selfDesc = String(describing: type(of: self))
            let typDesc = typ.makeIndentedDescription(depth: depth+1)
            let result = "\(indent)\(selfDesc)(\(typDesc))"
            return result
        }
        
        public static func ==(lhs: MutableType, rhs: MutableType) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? MutableType else { return false }
            guard typ == rhs.typ else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(typ)
            return hasher.finalize()
        }
    }
    
    public class UnionType: Expression {
        public let members: [Expression]
        
        public convenience init(_ members: [Expression]) {
            self.init(members: members)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    members: [Expression],
                    id: ID = ID()) {
            self.members = members
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> UnionType {
            UnionType(sourceAnchor: sourceAnchor,
                      members: members,
                      id: id)
        }
        
        public func withMembers(_ members: [Expression]) -> UnionType {
            UnionType(sourceAnchor: sourceAnchor,
                      members: members,
                      id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            let indent0 = wantsLeadingWhitespace ? makeIndent(depth: depth) : ""
            let selfDesc = String(describing: type(of: self))
            let indent1 = makeIndent(depth: depth + 1)
            let membersDesc = makeMembersDescription(depth: depth + 1)
            let result = "\(indent0)\(selfDesc)\n\(indent1)members: \(membersDesc)"
            return result
        }
        
        private func makeMembersDescription(depth: Int) -> String {
            var result: String = ""
            if members.isEmpty {
                result = "none"
            } else {
                for member in members {
                    result += "\n"
                    result += makeIndent(depth: depth + 1)
                    result += member.makeIndentedDescription(depth: depth + 1)
                }
            }
            return result
        }
        
        public static func ==(lhs: UnionType, rhs: UnionType) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? UnionType else { return false }
            guard members == rhs.members else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(members)
            return hasher.finalize()
        }
    }

    public class StructInitializer: Expression {
        public class Argument: NSObject {
            public let name: String
            public let expr: Expression
            
            public init(name: String, expr: Expression) {
                self.name = name
                self.expr = expr
            }
            
            public static func ==(lhs: Argument, rhs: Argument) -> Bool {
                return lhs.isEqual(rhs)
            }
            
            public override func isEqual(_ rhs: Any?) -> Bool {
                guard rhs != nil else { return false }
                guard type(of: rhs!) == type(of: self) else { return false }
                guard let rhs = rhs as? Argument else { return false }
                guard name == rhs.name else { return false }
                guard expr == rhs.expr else { return false }
                return true
            }
            
            public override var hash: Int {
                var hasher = Hasher()
                hasher.combine(name)
                hasher.combine(expr)
                return hasher.finalize()
            }
            
            public override var description: String {
                return ".\(name) = \(expr)"
            }
        }
        
        public let expr: Expression
        public let arguments: [Argument]
        
        public convenience init(sourceAnchor: SourceAnchor? = nil,
                                identifier: Expression,
                                arguments: [Argument]) {
            self.init(sourceAnchor: sourceAnchor,
                      expr: identifier,
                      arguments: arguments)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    expr: Expression,
                    arguments: [Argument],
                    id: ID = ID()) {
            self.expr = expr
            self.arguments = arguments.map {
                Argument(name: $0.name, expr: $0.expr)
            }
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> StructInitializer {
            StructInitializer(sourceAnchor: sourceAnchor,
                              expr: expr,
                              arguments: arguments,
                              id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@\n%@expr: %@\n%@arguments: %@",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          makeIndent(depth: depth + 1),
                          expr.makeIndentedDescription(depth: depth + 1),
                          makeIndent(depth: depth + 1),
                          makeArgumentsDescription(depth: depth + 1))
        }
        
        private func makeArgumentsDescription(depth: Int) -> String {
            var result: String = ""
            if arguments.isEmpty {
                result = "none"
            } else {
                for i in 0..<arguments.count {
                    let argument = arguments[i]
                    result += "\n"
                    result += makeIndent(depth: depth + 1)
                    result += "\(i) -- "
                    result += "\(argument.name): "
                    result += argument.expr.makeIndentedDescription(depth: depth + 1)
                }
            }
            return result
        }
        
        public static func ==(lhs: StructInitializer, rhs: StructInitializer) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? StructInitializer else { return false }
            guard expr == rhs.expr else { return false }
            guard arguments == rhs.arguments else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(expr)
            hasher.combine(arguments)
            return hasher.finalize()
        }
    }
    
    public class LiteralString: Expression {
        public let value: String
        
        public convenience init(_ value: String) {
            self.init(sourceAnchor: nil, value: value)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    value: String,
                    id: ID = ID()) {
            self.value = value
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> LiteralString {
            LiteralString(sourceAnchor: sourceAnchor,
                          value: value,
                          id: id)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? LiteralString else { return false }
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
            return String(format: "%@\"%@\"",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          value)
        }
    }
    
    public class TypeOf: Expression {
        public let expr: Expression
        
        public convenience init(_ expr: Expression) {
            self.init(sourceAnchor: nil, expr: expr)
        }
        
        public init(sourceAnchor: SourceAnchor?,
                    expr: Expression,
                    id: ID = ID()) {
            self.expr = expr
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> TypeOf {
            TypeOf(sourceAnchor: sourceAnchor,
                   expr: expr,
                   id: id)
        }
        
        public func withExpr(_ expr: Expression) -> TypeOf {
            TypeOf(sourceAnchor: sourceAnchor,
                   expr: expr,
                   id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@(%@)",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          expr.makeIndentedDescription(depth: depth + 1))
        }
        
        public static func ==(lhs: TypeOf, rhs: TypeOf) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? TypeOf else { return false }
            guard expr == rhs.expr else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(expr)
            return hasher.finalize()
        }
    }
    
    public class SizeOf: Expression {
        public let expr: Expression
        
        public convenience init(_ expr: Expression) {
            self.init(expr: expr)
        }
        
        public init(sourceAnchor: SourceAnchor? = nil,
                    expr: Expression,
                    id: ID = ID()) {
            self.expr = expr
            super.init(sourceAnchor: sourceAnchor, id: id)
        }
        
        public override func withSourceAnchor(_ sourceAnchor: SourceAnchor?) -> SizeOf {
            SizeOf(sourceAnchor: sourceAnchor,
                   expr: expr,
                   id: id)
        }
        
        public func withExpr(_ expr: Expression) -> SizeOf {
            SizeOf(sourceAnchor: sourceAnchor,
                   expr: expr,
                   id: id)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@%@(%@)",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          expr.makeIndentedDescription(depth: depth + 1))
        }
        
        public static func ==(lhs: SizeOf, rhs: SizeOf) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard super.isEqual(rhs) else { return false }
            guard let rhs = rhs as? SizeOf else { return false }
            guard expr == rhs.expr else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(expr)
            return hasher.finalize()
        }
    }
}
