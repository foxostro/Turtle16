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
    private let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
    
    @discardableResult public func check(expression: Expression) throws -> SymbolType {
        switch expression {
        case let expr as Expression.LiteralWord:
            return check(literalWord: expr)
        case is Expression.LiteralBoolean:
            return .bool
        case let expr as Expression.Unary:
            return try check(unary: expr)
        case let expr as Expression.Binary:
            return try check(binary: expr)
        case let identifier as Expression.Identifier:
            return try check(identifier: identifier)
        case let assignment as Expression.Assignment:
            return try check(assignment: assignment)
        case let call as Expression.Call:
            return try check(call: call)
        case let expr as Expression.As:
            return try check(as: expr)
        case let expr as Expression.Subscript:
            return try check(subscript: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }
    
    public func check(literalWord: Expression.LiteralWord) -> SymbolType {
        if literalWord.number.literal > 255 {
            return .u16
        }
        else {
            return .u8
        }
    }
        
    public func check(unary: Expression.Unary) throws -> SymbolType {
        let lineNumber = unary.tokens.first!.lineNumber
        let expressionType = try check(expression: unary.child)
        switch unary.op.op {
        case .minus:
            switch expressionType {
            case .u16:
                return .u16
            case .u8:
                return .u8
            default:
                throw CompilerError(line: lineNumber, message: "Unary operator `\(unary.op.lexeme)' cannot be applied to an operand of type `\(String(describing: expressionType))'")
            }
        default:
            throw CompilerError(line: lineNumber, message: "`\(unary.op.lexeme)' is not a prefix unary operator")
        }
    }
    
    public func check(binary: Expression.Binary) throws -> SymbolType {
        let right = try check(expression: binary.right)
        let left = try check(expression: binary.left)
        let lineNumber = binary.tokens.first!.lineNumber
        switch (binary.op.op, left, right) {
        case (.eq, .u8, .u8):         return .bool
        case (.eq, .u8, .u16):        return .bool
        case (.eq, .u16, .u8):        return .bool
        case (.eq, .u16, .u16):       return .bool
        case (.eq, .bool, .bool):     return .bool
        case (.ne, .u8, .u8):         return .bool
        case (.ne, .u8, .u16):        return .bool
        case (.ne, .u16, .u8):        return .bool
        case (.ne, .u16, .u16):       return .bool
        case (.ne, .bool, .bool):     return .bool
        case (.lt, .u8, .u8):         return .bool
        case (.lt, .u8, .u16):        return .bool
        case (.lt, .u16, .u8):        return .bool
        case (.lt, .u16, .u16):       return .bool
        case (.gt, .u8, .u8):         return .bool
        case (.gt, .u8, .u16):        return .bool
        case (.gt, .u16, .u8):        return .bool
        case (.gt, .u16, .u16):       return .bool
        case (.le, .u8, .u8):         return .bool
        case (.le, .u8, .u16):        return .bool
        case (.le, .u16, .u8):        return .bool
        case (.le, .u16, .u16):       return .bool
        case (.ge, .u8, .u8):         return .bool
        case (.ge, .u8, .u16):        return .bool
        case (.ge, .u16, .u8):        return .bool
        case (.ge, .u16, .u16):       return .bool
        case (.plus, .u8, .u8):       return .u8
        case (.plus, .u8, .u16):      return .u16
        case (.plus, .u16, .u8):      return .u16
        case (.plus, .u16, .u16):     return .u16
        case (.minus, .u8, .u8):      return .u8
        case (.minus, .u8, .u16):     return .u16
        case (.minus, .u16, .u8):     return .u16
        case (.minus, .u16, .u16):    return .u16
        case (.multiply, .u8, .u8):   return .u8
        case (.multiply, .u8, .u16):  return .u16
        case (.multiply, .u16, .u8):  return .u16
        case (.multiply, .u16, .u16): return .u16
        case (.divide, .u8, .u8):     return .u8
        case (.divide, .u8, .u16):    return .u16
        case (.divide, .u16, .u8):    return .u16
        case (.divide, .u16, .u16):   return .u16
        case (.modulus, .u8, .u8):    return .u8
        case (.modulus, .u8, .u16):   return .u16
        case (.modulus, .u16, .u8):   return .u16
        case (.modulus, .u16, .u16):  return .u16
        default:
            throw invalidBinaryExpr(lineNumber, binary, left, right)
        }
    }
    
    private func invalidBinaryExpr(_ lineNumber: Int, _ binary: Expression.Binary, _ left: SymbolType, _ right: SymbolType) -> CompilerError {
        if left == right {
            return CompilerError(line: lineNumber, message: "binary operator `\(binary.op.lexeme)' cannot be applied to two `\(right)' operands")
        } else {
            return CompilerError(line: lineNumber, message: "binary operator `\(binary.op.lexeme)' cannot be applied to operands of types `\(left)' and `\(right)'")
        }
    }
        
    public func check(assignment: Expression.Assignment) throws -> SymbolType {
        let symbol = try symbols.resolve(identifierToken: assignment.identifier)
        let rtype = try check(expression: assignment.child)
        if rtype != symbol.type {
            if rtype == .u8 && symbol.type == .u16 {
                // nothing to do
            } else {
                let lineNumber = assignment.tokens.first!.lineNumber
                let message = "cannot assign value of type `\(String(describing: rtype))' to type `\(String(describing: symbol.type))'"
                throw CompilerError(line: lineNumber, message: message)
            }
        }
        return symbol.type
    }
        
    public func check(identifier: Expression.Identifier) throws -> SymbolType {
        return try symbols.resolve(identifierToken: identifier.identifier).type
    }
        
    public func check(call: Expression.Call) throws -> SymbolType {
        let callee = call.callee as! Expression.Identifier
        let symbol = try symbols.resolve(identifierToken: callee.identifier)
        switch symbol.type {
        case .function(name: let name, mangledName: _, functionType: let typ):
            if call.arguments.count != typ.arguments.count {
                let message = "incorrect number of arguments in call to `\(name)'"
                if let lineNumber = call.tokens.first?.lineNumber {
                    throw CompilerError(line: lineNumber, message: message)
                } else {
                    throw CompilerError(message: message)
                }
            }
            for i in 0..<typ.arguments.count {
                let argumentType = try check(expression: call.arguments[i])
                switch (argumentType, typ.arguments[i].argumentType) {
                case (.bool, .bool): break
                case (.void, .void): break
                case (.u8, .u8):     break
                case (.u8, .u16):    break
                case (.u16, .u16):   break
                default:
                    let message = "cannot convert value of type `\(String(describing: argumentType))' to expected argument type `\(String(describing: typ.arguments[i].argumentType))' in call to `\(name)'"
                    if let lineNumber = call.tokens.first?.lineNumber {
                        throw CompilerError(line: lineNumber, message: message)
                    } else {
                        throw CompilerError(message: message)
                    }
                }
            }
            return typ.returnType
        default:
            let message = "cannot call value of non-function type `\(String(describing: symbol.type))'"
            if let lineNumber = call.tokens.first?.lineNumber {
                throw CompilerError(line: lineNumber, message: message)
            } else {
                throw CompilerError(message: message)
            }
        }
    }
        
    public func check(as expr: Expression.As) throws -> SymbolType {
        let originalType = try check(expression: expr.expr)
        let targetType = expr.targetType
        if originalType == targetType {
            return targetType
        }
        switch (originalType, targetType) {
        case (.u8, .u16), (.u16, .u8):
            return targetType
        default:
            let lineNumber = expr.tokens.first!.lineNumber
            let message = "cannot convert value of type `\(originalType)' to type `\(targetType)'"
            throw CompilerError(line: lineNumber, message: message)
        }
    }
        
    public func check(subscript expr: Expression.Subscript) throws -> SymbolType {
        let symbol = try symbols.resolve(identifierToken: expr.tokenIdentifier)
        let lineNumber = expr.tokens.first!.lineNumber
        let message = "value of type `\(symbol.type)' has no subscripts"
        throw CompilerError(line: lineNumber, message: message)
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
