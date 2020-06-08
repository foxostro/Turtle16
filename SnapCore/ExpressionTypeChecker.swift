//
//  ExpressionTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Given an expression, determines the result type.
// Throws a compiler error when the result type cannot be determined, e.g., due
// to a type error in the expression.
public class ExpressionTypeChecker: NSObject {
    public enum ExpressionType {
        case word
        case boolean
    }
    
    private let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    @discardableResult public func check(expression: Expression) throws -> ExpressionType {
        if let _ = expression as? Expression.LiteralWord {
            return .word
        } else if let _ = expression as? Expression.LiteralBoolean {
            return .boolean
        } else if let expr = expression as? Expression.Unary {
            return try check(unary: expr)
        } else if let expr = expression as? Expression.Binary {
            return try check(binary: expr)
        } else if let identifier = expression as? Expression.Identifier {
            return try check(identifier: identifier)
        } else if let assignment = expression as? Expression.Assignment {
            return try check(assignment: assignment)
        }
        throw unsupportedError(expression: expression)
    }
        
    public func check(unary: Expression.Unary) throws -> ExpressionType {
        let lineNumber = unary.tokens.first!.lineNumber
        let expr: ExpressionType = try check(expression: unary.child)
        switch unary.op.op {
        case .minus:
            switch expr {
            case .word:
                return .word
            case .boolean:
                throw CompilerError(line: lineNumber, message: "Unary operator `\(unary.op.lexeme)' cannot be applied to an operand of type `\(String(describing: expr))'")
            }
        default:
            throw CompilerError(line: lineNumber, message: "`\(unary.op.lexeme)' is not a prefix unary operator")
        }
    }
    
    public func check(binary: Expression.Binary) throws -> ExpressionType {
        let right: ExpressionType = try check(expression: binary.right)
        let left: ExpressionType = try check(expression: binary.left)
        let lineNumber = binary.tokens.first!.lineNumber
        guard right == left else {
            throw CompilerError(line: lineNumber, message: "Binary operator `\(binary.op.lexeme)' cannot be applied to operands of types `\(left)' and `\(right)'")
        }
        switch binary.op.op {
        case .eq:
            fallthrough
        case .ne:
            return .boolean
        
        case .lt:
            fallthrough
        case .gt:
            fallthrough
        case .le:
            fallthrough
        case .ge:
            switch right {
            case .word:
                return .boolean
            case .boolean:
                throw CompilerError(line: lineNumber, message: "Binary operator `\(binary.op.lexeme)' cannot be applied to two `\(right)' operands")
            }
            
        case .plus:
            fallthrough
        case .minus:
            fallthrough
        case .multiply:
            fallthrough
        case .divide:
            fallthrough
        case .modulus:
            switch right {
            case .word:
                return .word
            case .boolean:
                throw CompilerError(line: lineNumber, message: "Binary operator `\(binary.op.lexeme)' cannot be applied to two `\(right)' operands")
            }
        }
    }
        
    public func check(assignment: Expression.Assignment) throws -> ExpressionType {
        return try check(expression: assignment.child)
    }
        
    public func check(identifier: Expression.Identifier) throws -> ExpressionType {
        let symbol = try symbols.resolve(identifierToken: identifier.identifier)
        switch symbol {
        case .word(_):
            return .word
        case .boolean(_):
            return .boolean
        }
    }
    
    private func unsupportedError(expression: Expression) -> Error {
        let message = "unsupported expression: \(expression)"
        if let lineNumber = expression.tokens.first?.lineNumber {
            return CompilerError(line: lineNumber, message: message)
        } else {
            return CompilerError(message: message)
        }
    }
}
