//
//  RvalueExpressionTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

// Given an expression, determines the result type.
// Throws a compiler error when the result type cannot be determined, e.g., due
// to a type error in the expression.
public class RvalueExpressionTypeChecker: NSObject {
    public let symbols: SymbolTable
    
    public init(symbols: SymbolTable = SymbolTable()) {
        self.symbols = symbols
    }
        
    func rvalueContext() -> RvalueExpressionTypeChecker {
        return RvalueExpressionTypeChecker(symbols: symbols)
    }
        
    func lvalueContext() -> LvalueExpressionTypeChecker {
        return LvalueExpressionTypeChecker(symbols: symbols)
    }
    
    @discardableResult public func check(expression: Expression) throws -> SymbolType {
        switch expression {
        case let expr as Expression.LiteralInt:
            return .constInt(expr.value)
        case let expr as Expression.LiteralBool:
            return .constBool(expr.value)
        case let expr as Expression.Group:
            return try check(expression: expr.expression)
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
        case let expr as Expression.Get:
            return try check(get: expr)
        case let expr as Expression.PrimitiveType:
            return try check(primitiveType: expr)
        case let expr as Expression.ArrayType:
            return try check(arrayType: expr)
        case let expr as Expression.DynamicArrayType:
            return try check(dynamicArrayType: expr)
        case let expr as Expression.FunctionType:
            return try check(functionType: expr)
        case let expr as Expression.PointerType:
            return try check(pointerType: expr)
        case let expr as Expression.StructInitializer:
            return try check(structInitializer: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }
        
    public func check(unary: Expression.Unary) throws -> SymbolType {
        let expressionType = try check(expression: unary.child)
        switch unary.op {
        case .minus:
            switch expressionType {
            case .constInt(let value):
                return .constInt(-value)
            case .u16:
                return .u16
            case .u8:
                return .u8
            default:
                throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "Unary operator `\(unary.op.description)' cannot be applied to an operand of type `\(expressionType)'")
            }
        case .ampersand:
            let context = lvalueContext()
            context.messageWhenLvalueGenericallyCannotBeTaken = "cannot take the address of an operand of type `\(expressionType)'"
            let expressionType = try context.check(expression: unary.child)
            return .pointer(expressionType)
        default:
            let operatorString: String
            if let lexeme = unary.sourceAnchor?.text {
                operatorString = String(lexeme)
            } else {
                operatorString = fallbackStringForOperator(unary.op)
            }
            throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "`\(operatorString)' is not a prefix unary operator")
        }
    }
    
    private func fallbackStringForOperator(_ op: TokenOperator.Operator) -> String {
        switch op {
        case .eq: return "=="
        case .ne: return "!="
        case .lt: return "<"
        case .gt: return ">"
        case .le: return "<="
        case .ge: return ">="
        case .plus: return "+"
        case .minus: return "-"
        case .star: return "*"
        case .divide: return "/"
        case .modulus: return "%"
        case .ampersand: return "&"
        }
    }
    
    public func check(binary: Expression.Binary) throws -> SymbolType {
        let right = try check(expression: binary.right)
        let left = try check(expression: binary.left)
        switch (binary.op, left, right) {
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
        case (.star, .u8, .u8):
            return .u8
        case (.star, .u8, .u16):
            return .u16
        case (.star, .u8, .constInt):
            return .u8
        case (.star, .u16, .u8):
            return .u16
        case (.star, .u16, .u16):
            return .u16
        case (.star, .u16, .constInt):
            return .u16
        case (.star, .constInt, .u8):
            return .u8
        case (.star, .constInt, .u16):
            return .u16
        case (.star, .constInt(let a), .constInt(let b)):
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
            throw invalidBinaryExpr(binary, left, right)
        }
    }
    
    private func invalidBinaryExpr(_ binary: Expression.Binary, _ left: SymbolType, _ right: SymbolType) -> CompilerError {
        if left == right {
            return CompilerError(sourceAnchor: binary.sourceAnchor, message: "binary operator `\(binary.op.description)' cannot be applied to two `\(right)' operands")
        } else {
            return CompilerError(sourceAnchor: binary.sourceAnchor, message: "binary operator `\(binary.op.description)' cannot be applied to operands of types `\(left)' and `\(right)'")
        }
    }
    
    public func check(assignment: Expression.Assignment) throws -> SymbolType {
        let ltype = try lvalueContext().check(expression: assignment.lexpr)
        let rtype = try rvalueContext().check(expression: assignment.rexpr)
        return try checkTypesAreConvertibleInAssignment(ltype: ltype,
                                                        rtype: rtype,
                                                        sourceAnchor: assignment.rexpr.sourceAnchor,
                                                        messageWhenNotConvertible: "cannot assign value of type `\(rtype)' to type `\(ltype)'")
    }
    
    @discardableResult public func checkTypesAreConvertibleInAssignment(ltype: SymbolType,
                                                                        rtype: SymbolType,
                                                                        sourceAnchor: SourceAnchor?,
                                                                        messageWhenNotConvertible: String) throws -> SymbolType {
        return try checkTypesAreConvertible(ltype: ltype,
                                            rtype: rtype,
                                            sourceAnchor: sourceAnchor,
                                            messageWhenNotConvertible: messageWhenNotConvertible,
                                            isExplicitCast: false)
    }
        
    public func checkTypesAreConvertibleInExplicitCast(ltype: SymbolType,
                                                       rtype: SymbolType,
                                                       sourceAnchor: SourceAnchor?,
                                                       messageWhenNotConvertible: String) throws -> SymbolType {
        return try checkTypesAreConvertible(ltype: ltype,
                                            rtype: rtype,
                                            sourceAnchor: sourceAnchor,
                                            messageWhenNotConvertible: messageWhenNotConvertible,
                                            isExplicitCast: true)
    }
        
    private func checkTypesAreConvertible(ltype: SymbolType,
                                          rtype: SymbolType,
                                          sourceAnchor: SourceAnchor?,
                                          messageWhenNotConvertible: String,
                                          isExplicitCast: Bool) throws -> SymbolType {
        // Integer constants will be automatically converted to appropriate
        // concrete integer types.
        //
        // Small integer types will be automatically promoted to larger types.
        //
        // Otherwise, the type of the expression must be identical to the type
        // of the symbol.
        if rtype == ltype {
            return ltype
        }
        switch (rtype, ltype) {
        case (.constInt(let a), .u8):
            guard a >= 0 && a < 256 else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "integer constant `\(a)' overflows when stored into `u8'")
            }
            return ltype // The conversion is acceptable.
        case (.constInt(let a), .u16):
            guard a >= 0 && a < 65536 else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "integer constant `\(a)' overflows when stored into `u16'")
            }
            return ltype // The conversion is acceptable.
        case (.u8, .u16), (.constBool, .bool):
            return ltype // The conversion is acceptable.
        case (.u16, .u8):
            if !isExplicitCast {
                throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            }
            return ltype
        case (.array(let n, let a), .array(let m, let b)):
            guard n == m || m == nil else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            }
            let elementType = try checkTypesAreConvertible(ltype: b, rtype: a,
                                                           sourceAnchor: sourceAnchor,
                                                           messageWhenNotConvertible: messageWhenNotConvertible,
                                                           isExplicitCast: isExplicitCast)
            return .array(count: n, elementType: elementType)
        case (.array(let n, let a), .dynamicArray(elementType: let b)):
            guard n != nil && a == b else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            }
            return ltype
        default:
            throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
        }
    }
        
    public func check(identifier expr: Expression.Identifier) throws -> SymbolType {
        return try symbols.resolve(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier).type
    }
        
    public func check(call: Expression.Call) throws -> SymbolType {
        let callee = call.callee as! Expression.Identifier
        let name = callee.identifier
        let symbol = try resolve(callee)
        switch symbol.type {
        case .function(let typ):
            if call.arguments.count != typ.arguments.count {
                let message = "incorrect number of arguments in call to `\(name)'"
                throw CompilerError(sourceAnchor: call.sourceAnchor, message: message)
            }
            for i in 0..<typ.arguments.count {
                let rtype = try rvalueContext().check(expression: call.arguments[i])
                let ltype = typ.arguments[i].argumentType
                let message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to `\(name)'"
                _ = try checkTypesAreConvertibleInAssignment(ltype: ltype,
                                                             rtype: rtype,
                                                             sourceAnchor: call.arguments[i].sourceAnchor,
                                                             messageWhenNotConvertible: message)
            }
            return typ.returnType
        default:
            let message = "cannot call value of non-function type `\(symbol.type)'"
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: message)
        }
    }
        
    public func check(as expr: Expression.As) throws -> SymbolType {
        let ltype = try check(expression: expr.targetType)
        let rtype = try check(expression: expr.expr)
        return try checkTypesAreConvertibleInExplicitCast(ltype: ltype,
                                                          rtype: rtype,
                                                          sourceAnchor: expr.sourceAnchor,
                                                          messageWhenNotConvertible: "cannot convert value of type `\(rtype)' to type `\(ltype)'")
    }
    
    public func resolve(_ expr: Expression.Identifier) throws -> Symbol {
        let symbol = try symbols.resolve(sourceAnchor: expr.sourceAnchor,
                                         identifier: expr.identifier)
        return symbol
    }
    
    public func check(subscript expr: Expression.Subscript) throws -> SymbolType {
        let symbol = try resolve(expr.identifier)
        switch symbol.type {
        case .array(count: _, elementType: let elementType),
             .dynamicArray(elementType: let elementType):
            let argumentType = try rvalueContext().check(expression: expr.expr)
            if !argumentType.isArithmeticType {
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot subscript a value of type `\(symbol.type)' with an argument of type `\(argumentType)'")
            }
            return elementType
        default:
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(symbol.type)' has no subscripts")
        }
    }
    
    public func check(literalArray expr: Expression.LiteralArray) throws -> SymbolType {
        var arrayLiteralType = try check(expression: expr.arrayType)
        let arrayCount = arrayLiteralType.arrayCount
        let arrayElementType = arrayLiteralType.arrayElementType
        
        if let explicitCount = arrayCount {
            if expr.elements.count != explicitCount {
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "expected \(explicitCount) elements in `\(arrayLiteralType)' array literal")
            }
        }
        
        arrayLiteralType = .array(count: expr.elements.count, elementType: arrayElementType)
        
        for element in expr.elements {
            let ltype = arrayElementType
            let rtype = try check(expression: element)
            try checkTypesAreConvertibleInAssignment(ltype: ltype,
                                                     rtype: rtype,
                                                     sourceAnchor: element.sourceAnchor,
                                                     messageWhenNotConvertible: "cannot convert value of type `\(rtype)' to type `\(ltype)' in `\(arrayLiteralType)' array literal")
        }
        
        return arrayLiteralType
    }
    
    public func check(get expr: Expression.Get) throws -> SymbolType {
        let name = expr.member.identifier
        let resultType = try check(expression: expr.expr)
        switch resultType {
        case .array, .dynamicArray:
            if name == "count" {
                return .u16
            }
        case .structType(let typ):
            if let symbol = typ.symbols.maybeResolve(identifier: name) {
                return symbol.type
            }
        case .pointer(let typ):
            if name == "pointee" {
                return typ
            } else {
                switch typ {
                case .array, .dynamicArray:
                    if name == "count" {
                        return .u16
                    }
                case .structType(let b):
                    if let symbol = b.symbols.maybeResolve(identifier: name) {
                        return symbol.type
                    }
                default:
                    break
                }
            }
        default:
            break
        }
        throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(resultType)' has no member `\(name)'")
    }
    
    public func check(primitiveType expr: Expression.PrimitiveType) throws -> SymbolType {
        return expr.typ
    }
    
    public func check(arrayType expr: Expression.ArrayType) throws -> SymbolType {
        let count: Int?
        if let exprCount = expr.count {
            let typeOfCountExpr = try check(expression: exprCount)
            switch typeOfCountExpr {
            case .constInt(let a):
                count = a
            default:
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot convert value of type `\(typeOfCountExpr)' to expected type `const int'")
            }
        } else {
            count = nil
        }
        let elementType = try check(expression: expr.elementType)
        return .array(count: count, elementType: elementType)
    }
    
    public func check(dynamicArrayType expr: Expression.DynamicArrayType) throws -> SymbolType {
        let elementType = try check(expression: expr.elementType)
        return .dynamicArray(elementType: elementType)
    }
    
    public func check(functionType expr: Expression.FunctionType) throws -> SymbolType {
        let returnType = try check(expression: expr.returnType)
        var arguments: [FunctionType.Argument] = []
        for arg in expr.arguments {
            let typ = try check(expression: arg.argumentType)
            arguments.append(FunctionType.Argument(name: arg.name, type: typ))
        }
        return .function(FunctionType(returnType: returnType, arguments: arguments))
    }
    
    public func check(pointerType expr: Expression.PointerType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return .pointer(typ)
    }
    
    public func check(structInitializer expr: Expression.StructInitializer) throws -> SymbolType {
        let result = try symbols.resolveType(identifier: expr.identifier.identifier)
        let typ = result.unwrapStructType()
        var membersAlreadyInitialized: [String] = []
        for arg in expr.arguments {
            guard typ.symbols.exists(identifier: arg.name) else {
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(expr.identifier.identifier)' has no member `\(arg.name)'")
            }
            if membersAlreadyInitialized.contains(arg.name) {
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "initialization of member `\(arg.name)' can only occur one time")
            }
            let rtype = try rvalueContext().check(expression: arg.expr)
            let member = try! typ.symbols.resolve(identifier: arg.name)
            let ltype = member.type
            let message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in initialization of `\(arg.name)'"
            _ = try checkTypesAreConvertibleInAssignment(ltype: ltype,
                                                         rtype: rtype,
                                                         sourceAnchor: arg.expr.sourceAnchor,
                                                         messageWhenNotConvertible: message)
            membersAlreadyInitialized.append(arg.name)
        }
        return result
    }
    
    func unsupportedError(expression: Expression) -> Error {
        return CompilerError(sourceAnchor: expression.sourceAnchor,
                             message: "unsupported expression: \(expression)")
    }
}
