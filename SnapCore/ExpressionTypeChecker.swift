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
            return .constInt(expr.number.literal)
        case let expr as Expression.LiteralBoolean:
            return .constBool(expr.boolean.literal)
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
        case let expr as Expression.LiteralArray:
            return try check(literalArray: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }
        
    public func check(unary: Expression.Unary) throws -> SymbolType {
        let lineNumber = unary.tokens.first!.lineNumber
        let expressionType = try check(expression: unary.child)
        switch unary.op.op {
        case .minus:
            switch expressionType {
            case .constInt(let value):
                return .constInt(-value)
            case .u16:
                return .u16
            case .u8:
                return .u8
            default:
                throw CompilerError(line: lineNumber, message: "Unary operator `\(unary.op.lexeme)' cannot be applied to an operand of type `\(expressionType)'")
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
        case (.eq, .u8, .u8):
            return .bool
        case (.eq, .u8, .u16):
            return .bool
        case (.eq, .u8, .constInt):
            return .bool
        case (.eq, .u16, .u8):
            return .bool
        case (.eq, .u16, .u16):
            return .bool
        case (.eq, .u16, .constInt):
            return .bool
        case (.eq, .constInt, .u8):
            return .bool
        case (.eq, .constInt, .u16):
            return .bool
        case (.eq, .constInt(let a), .constInt(let b)):
            return .constBool(a == b)
        case (.eq, .bool, .bool):
            return .bool
        case (.eq, .bool, .constBool):
            return .bool
        case (.eq, .constBool, .bool):
            return .bool
        case (.eq, .constBool(let a), .constBool(let b)):
            return .constBool(a == b)
        case (.ne, .u8, .u8):
            return .bool
        case (.ne, .u8, .u16):
            return .bool
        case (.ne, .u8, .constInt):
            return .bool
        case (.ne, .u16, .u8):
            return .bool
        case (.ne, .u16, .u16):
            return .bool
        case (.ne, .u16, .constInt):
            return .bool
        case (.ne, .constInt, .u8):
            return .bool
        case (.ne, .constInt, .u16):
            return .bool
        case (.ne, .constInt(let a), .constInt(let b)):
            return .constBool(a != b)
        case (.ne, .bool, .bool):
            return .bool
        case (.ne, .bool, .constBool):
            return .bool
        case (.ne, .constBool, .bool):
            return .bool
        case (.ne, .constBool(let a), .constBool(let b)):
            return .constBool(a != b)
        case (.lt, .u8, .u8):
            return .bool
        case (.lt, .u8, .u16):
            return .bool
        case (.lt, .u8, .constInt):
            return .bool
        case (.lt, .u16, .u8):
            return .bool
        case (.lt, .u16, .u16):
            return .bool
        case (.lt, .u16, .constInt):
            return .bool
        case (.lt, .constInt, .u8):
            return .bool
        case (.lt, .constInt, .u16):
            return .bool
        case (.lt, .constInt(let a), .constInt(let b)):
            return .constBool(a < b)
        case (.gt, .u8, .u8):
            return .bool
        case (.gt, .u8, .u16):
            return .bool
        case (.gt, .u8, .constInt):
            return .bool
        case (.gt, .u16, .u8):
            return .bool
        case (.gt, .u16, .u16):
            return .bool
        case (.gt, .u16, .constInt):
            return .bool
        case (.gt, .constInt, .u8):
            return .bool
        case (.gt, .constInt, .u16):
            return .bool
        case (.gt, .constInt(let a), .constInt(let b)):
            return .constBool(a > b)
        case (.le, .u8, .u8):
            return .bool
        case (.le, .u8, .u16):
            return .bool
        case (.le, .u8, .constInt):
            return .bool
        case (.le, .u16, .u8):
            return .bool
        case (.le, .u16, .u16):
            return .bool
        case (.le, .u16, .constInt):
            return .bool
        case (.le, .constInt, .u8):
            return .bool
        case (.le, .constInt, .u16):
            return .bool
        case (.le, .constInt(let a), .constInt(let b)):
            return .constBool(a <= b)
        case (.ge, .u8, .u8):
            return .bool
        case (.ge, .u8, .u16):
            return .bool
        case (.ge, .u8, .constInt):
            return .bool
        case (.ge, .u16, .u8):
            return .bool
        case (.ge, .u16, .u16):
            return .bool
        case (.ge, .u16, .constInt):
            return .bool
        case (.ge, .constInt, .u8):
            return .bool
        case (.ge, .constInt, .u16):
            return .bool
        case (.ge, .constInt(let a), .constInt(let b)):
            return .constBool(a >= b)
        case (.plus, .u8, .u8):
            return .u8
        case (.plus, .u8, .u16):
            return .u16
        case (.plus, .u8, .constInt):
            return .u8
        case (.plus, .u16, .u8):
            return .u16
        case (.plus, .u16, .u16):
            return .u16
        case (.plus, .u16, .constInt):
            return .u16
        case (.plus, .constInt, .u8):
            return .u8
        case (.plus, .constInt, .u16):
            return .u16
        case (.plus, .constInt(let a), .constInt(let b)):
            return .constInt(a + b)
        case (.minus, .u8, .u8):
            return .u8
        case (.minus, .u8, .u16):
            return .u16
        case (.minus, .u8, .constInt):
            return .u8
        case (.minus, .u16, .u8):
            return .u16
        case (.minus, .u16, .u16):
            return .u16
        case (.minus, .u16, .constInt):
            return .u16
        case (.minus, .constInt, .u8):
            return .u8
        case (.minus, .constInt, .u16):
            return .u16
        case (.minus, .constInt(let a), .constInt(let b)):
            return .constInt(a - b)
        case (.multiply, .u8, .u8):
            return .u8
        case (.multiply, .u8, .u16):
            return .u16
        case (.multiply, .u8, .constInt):
            return .u8
        case (.multiply, .u16, .u8):
            return .u16
        case (.multiply, .u16, .u16):
            return .u16
        case (.multiply, .u16, .constInt):
            return .u16
        case (.multiply, .constInt, .u8):
            return .u8
        case (.multiply, .constInt, .u16):
            return .u16
        case (.multiply, .constInt(let a), .constInt(let b)):
            return .constInt(a * b)
        case (.divide, .u8, .u8):
            return .u8
        case (.divide, .u8, .u16):
            return .u16
        case (.divide, .u8, .constInt):
            return .u8
        case (.divide, .u16, .u8):
            return .u16
        case (.divide, .u16, .u16):
            return .u16
        case (.divide, .u16, .constInt):
            return .u16
        case (.divide, .constInt, .u8):
            return .u8
        case (.divide, .constInt, .u16):
            return .u16
        case (.divide, .constInt(let a), .constInt(let b)):
            return .constInt(a / b)
        case (.modulus, .u8, .u8):
            return .u8
        case (.modulus, .u8, .u16):
            return .u16
        case (.modulus, .u8, .constInt):
            return .u8
        case (.modulus, .u16, .u8):
            return .u16
        case (.modulus, .u16, .u16):
            return .u16
        case (.modulus, .u16, .constInt):
            return .u16
        case (.modulus, .constInt, .u8):
            return .u8
        case (.modulus, .constInt, .u16):
            return .u16
        case (.modulus, .constInt(let a), .constInt(let b)):
            return .constInt(a % b)
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
        if !areTypesAreConvertibleInAssignment(ltype: symbol.type, rtype: rtype) {
            let lineNumber = assignment.tokens.first!.lineNumber
            let message = "cannot assign value of type `\(rtype)' to type `\(symbol.type)'"
            throw CompilerError(line: lineNumber, message: message)
        }
        return symbol.type
    }
        
    private func areTypesAreConvertibleInAssignment(ltype: SymbolType, rtype: SymbolType) -> Bool {
        // Integer constants will be automatically converted to appropriate
        // concrete integer types.
        //
        // Small integer types will be automatically promoted to larger types.
        //
        // Otherwise, the type of the expression must be identical to the type
        // of the symbol.
        if rtype == ltype {
            return true
        }
        switch (rtype, ltype) {
        case (.constInt, .u8),
             (.constInt, .u16),
             (.u8, .u16),
             (.constBool, .bool):
            return true // The conversion is acceptable.
        default:
            return false
        }
    }
        
    public func check(identifier: Expression.Identifier) throws -> SymbolType {
        let symbolType = try symbols.resolve(identifierToken: identifier.identifier).type
        switch symbolType {
        case .array:
            throw unsupportedError(expression: identifier)
        default:
            break
        }
        return symbolType
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
                let rtype = try check(expression: call.arguments[i])
                let ltype = typ.arguments[i].argumentType
                if !areTypesAreConvertibleInAssignment(ltype: ltype, rtype: rtype) {
                    let message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to `\(name)'"
                    if let lineNumber = call.tokens.first?.lineNumber {
                        throw CompilerError(line: lineNumber, message: message)
                    } else {
                        throw CompilerError(message: message)
                    }
                }
            }
            return typ.returnType
        default:
            let message = "cannot call value of non-function type `\(symbol.type)'"
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
        case (.u8, .u16),
             (.u16, .u8),
             (.constInt, .u8),
             (.constInt, .u16),
             (.constBool, .bool):
            return targetType // the conversion is valid
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
    
    public func check(literalArray expr: Expression.LiteralArray) throws -> SymbolType {
        let elementTypes = try expr.elements.compactMap({try check(expression: $0)})
        guard let elementType = determineArrayElementType(elementTypes) else {
            let lineNumber = expr.tokens.first!.lineNumber
            throw CompilerError(line: lineNumber, message: "cannot infer type of heterogeneous array")
        }
        return .array(count: elementTypes.count, elementType: elementType)
    }
    
    private func determineArrayElementType(_ elementTypes: [SymbolType]) -> SymbolType? {
        if elementTypes.isEmpty {
            return .void
        }
        else if elementTypes.allSatisfy({$0.isBooleanType}) {
            return .bool
        }
        else if elementTypes.allSatisfy({$0.isArithmeticType}) {
            var largestVal = Int.min
            for el in elementTypes {
                switch el {
                case .constInt(let val):
                    largestVal = max(largestVal, val)
                case .u8:
                    largestVal = max(largestVal, 255)
                case .u16:
                    largestVal = max(largestVal, 65535)
                default:
                    return nil
                }
            }
            if largestVal < 256 {
                return .u8
            } else {
                return .u16
            }
        }
        else if elementTypes.allSatisfy({$0 == elementTypes[0]}) {
            return elementTypes[0]
        }
        else {
            return nil
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
