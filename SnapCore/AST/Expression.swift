//
//  Expression.swift
//  SnapCore
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public class Expression: AbstractSyntaxTreeNode {
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard rhs is Expression else {
            return false
        }
        guard super.isEqual(rhs) else {
            return false
        }
        return true
    }
    
    // Useful for testing
    public class UnsupportedExpression : Expression {}
    
    public class LiteralInt: Expression {
        public let value: Int
        
        public convenience init(_ value: Int) {
            self.init(sourceAnchor: nil, value: value)
        }
        
        public init(sourceAnchor: SourceAnchor?, value: Int) {
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
            guard let rhs = rhs as? LiteralInt else {
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
    
    public class LiteralBool: Expression {
        public let value: Bool
        
        public convenience init(_ value: Bool) {
            self.init(sourceAnchor: nil, value: value)
        }
        
        public init(sourceAnchor: SourceAnchor?, value: Bool) {
            self.value = value
            super.init(sourceAnchor: sourceAnchor)
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
            return String(format: "%@<%@: boolean=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          value ? "true" : "false")
        }
    }
    
    public class Identifier: Expression {
        public let identifier: String
        
        public convenience init(_ identifier: String) {
            self.init(sourceAnchor: nil, identifier: identifier)
        }
        
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
        
        public convenience init(op: TokenOperator.Operator, expression: Expression) {
            self.init(sourceAnchor: nil, op: op, expression: expression)
        }
        
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
        
        public convenience init(_ expression: Expression) {
            self.init(sourceAnchor: nil, expression: expression)
        }
        
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
        
        public convenience init(op: TokenOperator.Operator,
                    left: Expression,
                    right: Expression) {
            self.init(sourceAnchor: nil, op: op, left: left, right: right)
        }
        
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
            guard rhs != nil else {
                return false
            }
            guard super.isEqual(rhs) else {
                return false
            }
            guard let rhs = rhs as? Binary else {
                return false
            }
            guard op == rhs.op else {
                return false
            }
            guard left == rhs.left else {
                return false
            }
            guard right == rhs.right else {
                return false
            }
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
        
        public convenience init(lexpr: Expression, rexpr: Expression) {
            self.init(sourceAnchor: nil, lexpr: lexpr, rexpr: rexpr)
        }
        
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
        
        public convenience init(callee: Expression, arguments: [Expression]) {
            self.init(sourceAnchor: nil, callee: callee, arguments: arguments)
        }
        
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
        public let targetType: Expression
        
        public convenience init(expr: Expression, targetType: Expression) {
            self.init(sourceAnchor: nil, expr: expr, targetType: targetType)
        }
        
        public init(sourceAnchor: SourceAnchor?, expr: Expression, targetType: Expression) {
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
                          targetType.makeIndentedDescription(depth: depth),
                          expr.makeIndentedDescription(depth: depth))
        }
    }
    
    public class Subscript: Expression {
        public let identifier: Expression.Identifier
        public let expr: Expression
        
        public convenience init(identifier: Expression.Identifier, expr: Expression) {
            self.init(sourceAnchor: nil, identifier: identifier, expr: expr)
        }
        
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
        public let arrayType: Expression
        public let elements: [Expression]
        
        public convenience init(arrayType: Expression,
                                elements: [Expression] = []) {
            self.init(sourceAnchor: nil,
                      arrayType: arrayType,
                      elements: elements)
        }
        
        public init(sourceAnchor: SourceAnchor?,
                    arrayType: Expression,
                    elements: [Expression] = []) {
            self.arrayType = arrayType
            self.elements = elements
            super.init(sourceAnchor: sourceAnchor)
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
            return String(format: "%@<%@ arrayType=%@, elements=[\n%@\n]>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          arrayType.makeIndentedDescription(depth: depth),
                          elements.compactMap({$0.makeIndentedDescription(depth: depth+1, wantsLeadingWhitespace:  true)}).joined(separator: ",\n"))
        }
    }
    
    public class Get: Expression {
        public let expr: Expression
        public let member: Identifier
        
        public convenience init(expr: Expression, member: Identifier) {
            self.init(sourceAnchor: nil, expr: expr, member: member)
        }
        
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
    
    public class PrimitiveType: Expression {
        public let typ: SymbolType
        
        public convenience init(_ typ: SymbolType) {
            self.init(sourceAnchor: nil, typ: typ)
        }
        
        public init(sourceAnchor: SourceAnchor?, typ: SymbolType) {
            self.typ = typ
            super.init(sourceAnchor: sourceAnchor)
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
            return String(format: "%@<%@ typ=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          typ.description)
        }
    }
    
    public class DynamicArrayType: Expression {
        public let elementType: Expression
        
        public convenience init(_ elementType: Expression) {
            self.init(sourceAnchor: nil, elementType: elementType)
        }
        
        public init(sourceAnchor: SourceAnchor?, elementType: Expression) {
            self.elementType = elementType
            super.init(sourceAnchor: sourceAnchor)
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
            return String(format: "%@<%@ elementType=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          elementType.description)
        }
    }
    
    public class ArrayType: Expression {
        public let count: Expression?
        public let elementType: Expression
        
        public convenience init(count: Expression?, elementType: Expression) {
            self.init(sourceAnchor: nil, count: count, elementType: elementType)
        }
        
        public init(sourceAnchor: SourceAnchor?, count: Expression?, elementType: Expression) {
            self.count = count
            self.elementType = elementType
            super.init(sourceAnchor: sourceAnchor)
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
            return String(format: "%@<%@ count=%@, elementType=%@>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          count?.description ?? "nil",
                          elementType.description)
        }
    }

    public class FunctionType: Expression {
        public class Argument: NSObject {
            public let name: String
            public let argumentType: Expression
            
            public init(name: String, type: Expression) {
                self.name = name
                self.argumentType = type
            }
            
            public static func ==(lhs: Argument, rhs: Argument) -> Bool {
                return lhs.isEqual(rhs)
            }
            
            public override func isEqual(_ rhs: Any?) -> Bool {
                guard rhs != nil else { return false }
                guard type(of: rhs!) == type(of: self) else { return false }
                guard let rhs = rhs as? Argument else { return false }
                guard name == rhs.name else { return false }
                guard argumentType == rhs.argumentType else { return false }
                return true
            }
            
            public override var hash: Int {
                var hasher = Hasher()
                hasher.combine(name)
                hasher.combine(argumentType)
                return hasher.finalize()
            }
        }
        
        public let returnType: Expression
        public let arguments: [Argument]
        
        public convenience init(returnType: Expression, arguments: [Argument]) {
            self.init(sourceAnchor: nil,
                      returnType: returnType,
                      arguments: arguments)
        }
        
        public init(sourceAnchor: SourceAnchor?, returnType: Expression, arguments: [Argument]) {
            self.returnType = returnType
            self.arguments = arguments
            super.init(sourceAnchor: sourceAnchor)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@ returnType=%@, arguments={%@}>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          returnType.makeIndentedDescription(depth: depth+1),
                          makeArgumentsDescription())
        }
        
        public func makeArgumentsDescription() -> String {
            let result = arguments.map({"\($0.name): \($0.argumentType)"}).joined(separator: ", ")
            return result
        }
        
        public static func ==(lhs: FunctionType, rhs: FunctionType) -> Bool {
            return lhs.isEqual(rhs)
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
            guard let rhs = rhs as? FunctionType else {
                return false
            }
            guard returnType == rhs.returnType else {
                return false
            }
            guard arguments == rhs.arguments else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(returnType)
            hasher.combine(arguments)
            return hasher.finalize()
        }
    }

    public class PointerType: Expression {
        public let typ: Expression
        
        public convenience init(_ typ: Expression) {
            self.init(sourceAnchor: nil, typ: typ)
        }
        
        public init(sourceAnchor: SourceAnchor?, typ: Expression) {
            self.typ = typ
            super.init(sourceAnchor: sourceAnchor)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@ typ=%@}>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          typ.makeIndentedDescription(depth: depth))
        }
        
        public static func ==(lhs: PointerType, rhs: PointerType) -> Bool {
            return lhs.isEqual(rhs)
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
            guard let rhs = rhs as? PointerType else {
                return false
            }
            guard typ == rhs.typ else {
                return false
            }
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
        
        public init(sourceAnchor: SourceAnchor?, typ: Expression) {
            self.typ = typ
            super.init(sourceAnchor: sourceAnchor)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@ typ=%@}>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          typ.makeIndentedDescription(depth: depth))
        }
        
        public static func ==(lhs: ConstType, rhs: ConstType) -> Bool {
            return lhs.isEqual(rhs)
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
            guard let rhs = rhs as? ConstType else {
                return false
            }
            guard typ == rhs.typ else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(typ)
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
                guard rhs != nil else {
                    return false
                }
                guard type(of: rhs!) == type(of: self) else {
                    return false
                }
                guard let rhs = rhs as? Argument else {
                    return false
                }
                guard name == rhs.name else {
                    return false
                }
                guard expr == rhs.expr else {
                    return false
                }
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
        
        public let identifier: Identifier
        public let arguments: [Argument]
        
        public convenience init(identifier: Identifier, arguments: [Argument]) {
            self.init(sourceAnchor: nil,
                      identifier: identifier,
                      arguments: arguments)
        }
        
        public init(sourceAnchor: SourceAnchor?, identifier: Identifier, arguments: [Argument]) {
            self.identifier = identifier
            self.arguments = arguments
            super.init(sourceAnchor: sourceAnchor)
        }
        
        open override func makeIndentedDescription(depth: Int, wantsLeadingWhitespace: Bool = false) -> String {
            return String(format: "%@<%@ identifier=%@, arguments={%@}>",
                          wantsLeadingWhitespace ? makeIndent(depth: depth) : "",
                          String(describing: type(of: self)),
                          identifier.makeIndentedDescription(depth: depth),
                          makeArgumentsDescription())
        }
        
        public func makeArgumentsDescription() -> String {
            let result = arguments.map({"\($0.name): \($0.expr)"}).joined(separator: ", ")
            return result
        }
        
        public static func ==(lhs: StructInitializer, rhs: StructInitializer) -> Bool {
            return lhs.isEqual(rhs)
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
            guard let rhs = rhs as? StructInitializer else {
                return false
            }
            guard identifier == rhs.identifier else {
                return false
            }
            guard arguments == rhs.arguments else {
                return false
            }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(identifier)
            hasher.combine(arguments)
            return hasher.finalize()
        }
    }
}
