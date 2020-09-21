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
            return .compTimeInt(expr.value)
        case let expr as Expression.LiteralBool:
            return .compTimeBool(expr.value)
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
        case let expr as Expression.ConstType:
            return try check(constType: expr)
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
            case .compTimeInt(let value):
                return .compTimeInt(-value)
            case .constU16:
                return .constU16
            case .u16:
                return .u16
            case .constU8:
                return .constU8
            case .u8:
                return .u8
            default:
                throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "Unary operator `\(unary.op.description)' cannot be applied to an operand of type `\(expressionType)'")
            }
        case .ampersand:
            guard let lvalueType = try lvalueContext().check(expression: unary.child) else {
                throw CompilerError(sourceAnchor: unary.child.sourceAnchor, message: "lvalue required as operand of unary operator `\(unary.op.description)'")
            }
            return .pointer(lvalueType)
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
    
    private func check(binary: Expression.Binary) throws -> SymbolType {
        let rightType = try check(expression: binary.right)
        let leftType = try check(expression: binary.left)
        
        if leftType.isArithmeticType && rightType.isArithmeticType {
            return try checkArithmeticBinaryExpression(binary, leftType, rightType)
        }
        
        if leftType.isBooleanType && rightType.isBooleanType {
            return try checkBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        throw invalidBinaryExpr(binary, leftType, rightType)
    }
    
    private func checkBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        guard leftType.isBooleanType && rightType.isBooleanType else {
            assert(false)
            abort()
        }
        
        if case .compTimeBool = leftType, case .compTimeBool = rightType {
            return try checkConstantBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        _ = try checkTypesAreConvertibleInAssignment(ltype: .bool,
                                                     rtype: leftType,
                                                     sourceAnchor: binary.left.sourceAnchor,
                                                     messageWhenNotConvertible: "cannot convert value of type `\(leftType)' to type `bool'")
        
        _ = try checkTypesAreConvertibleInAssignment(ltype: .bool,
                                                     rtype: rightType,
                                                     sourceAnchor: binary.right.sourceAnchor,
                                                     messageWhenNotConvertible: "cannot convert value of type `\(rightType)' to type `bool'")
        
        switch binary.op {
        case .eq, .ne:
            return .bool
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
        }
    }
    
    private func checkConstantBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        guard case .compTimeBool(let a) = leftType, case .compTimeBool(let b) = rightType else {
            assert(false)
            abort()
        }
        
        switch binary.op {
        case .eq:
            return .compTimeBool(a == b)
        case .ne:
            return .compTimeBool(a != b)
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
        }
    }
    
    private func checkArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        guard leftType.isArithmeticType && rightType.isArithmeticType else {
            assert(false)
            abort()
        }

        if case .compTimeInt = leftType, case .compTimeInt = rightType {
            return try checkConstantArithmeticBinaryExpression(binary, leftType, rightType)
        }
        
        let typeForArithmetic: SymbolType = (max(leftType.max(), rightType.max()) > 255) ? .u16 : .u8
        
        _ = try checkTypesAreConvertibleInAssignment(ltype: typeForArithmetic,
                                                     rtype: leftType,
                                                     sourceAnchor: binary.left.sourceAnchor,
                                                     messageWhenNotConvertible: "cannot convert value of type `\(leftType)' to type `\(typeForArithmetic)'")
        
        _ = try checkTypesAreConvertibleInAssignment(ltype: typeForArithmetic,
                                                     rtype: rightType,
                                                     sourceAnchor: binary.right.sourceAnchor,
                                                     messageWhenNotConvertible: "cannot convert value of type `\(rightType)' to type `\(typeForArithmetic)'")
        
        switch binary.op {
        case .eq, .ne, .lt, .gt, .le, .ge:
            return .bool
        case .plus, .minus, .star, .divide, .modulus:
            return typeForArithmetic
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
        }
    }
    
    private func checkConstantArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        guard case .compTimeInt(let a) = leftType, case .compTimeInt(let b) = rightType else {
            assert(false)
            abort()
        }
        
        switch binary.op {
        case .eq:
            return .compTimeBool(a == b)
        case .ne:
            return .compTimeBool(a != b)
        case .lt:
            return .compTimeBool(a < b)
        case .gt:
            return .compTimeBool(a > b)
        case .le:
            return .compTimeBool(a <= b)
        case .ge:
            return .compTimeBool(a >= b)
        case .plus:
            return .compTimeInt(a + b)
        case .minus:
            return .compTimeInt(a - b)
        case .star:
            return .compTimeInt(a * b)
        case .divide:
            return .compTimeInt(a / b)
        case .modulus:
            return .compTimeInt(a % b)
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
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
        guard let ltype = try lvalueContext().check(expression: assignment.lexpr) else {
            throw CompilerError(sourceAnchor: assignment.lexpr.sourceAnchor,
                                message: "lvalue required in assignment")
        }
        
        guard !ltype.isConst || (assignment is Expression.InitialAssignment) else {
            switch assignment.lexpr {
            case let identifier as Expression.Identifier:
                throw CompilerError(sourceAnchor: assignment.lexpr.sourceAnchor,
                                    message: "cannot assign to constant `\(identifier.identifier)' of type `\(ltype)'")
            default:
                throw CompilerError(sourceAnchor: assignment.lexpr.sourceAnchor,
                                    message: "cannot assign to expression of type `\(ltype)'")
            }
        }
        
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
        case (.compTimeInt(let a), .u8), (.compTimeInt(let a), .constU8):
            guard a >= 0 && a < 256 else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "integer constant `\(a)' overflows when stored into `\(ltype)'")
            }
            return ltype // The conversion is acceptable.
        case (.compTimeInt(let a), .u16), (.compTimeInt(let a), .constU16):
            guard a >= 0 && a < 65536 else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: "integer constant `\(a)' overflows when stored into `\(ltype)'")
            }
            return ltype // The conversion is acceptable.
        case (.constU8, .constU8),
             (.constU8, .u8),
             (.u8, .constU8),
             (.u8, .u8),
             (.constU16, .constU16),
             (.constU16, .u16),
             (.u16, .constU16),
             (.u16, .u16),
             (.constU8, .constU16),
             (.constU8, .u16),
             (.u8, .constU16),
             (.u8, .u16),
             (.compTimeBool, .constBool),
             (.compTimeBool, .bool),
             (.constBool, .constBool),
             (.constBool, .bool),
             (.bool, .constBool),
             (.bool, .bool):
            return ltype // The conversion is acceptable.
        case (.constU16, .constU8),
             (.constU16, .u8),
             (.u16, .constU8),
             (.u16, .u8):
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
        case (.array(let n, let a), .constDynamicArray(elementType: let b)),
             (.array(let n, let a), .dynamicArray(elementType: let b)):
            guard n != nil else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            }
            _ = try checkTypesAreConvertible(ltype: b,
                                             rtype: a,
                                             sourceAnchor: sourceAnchor,
                                             messageWhenNotConvertible: messageWhenNotConvertible,
                                             isExplicitCast: isExplicitCast)
            return ltype
        case (.constDynamicArray(let a), .constDynamicArray(let b)),
             (.constDynamicArray(let a), .dynamicArray(let b)),
             (.dynamicArray(let a), .constDynamicArray(let b)),
             (.dynamicArray(let a), .dynamicArray(let b)):
            guard a == b || a.correspondingConstType == b else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            }
            return .dynamicArray(elementType: b)
        case (.constStructType(let a), .constStructType(let b)),
             (.constStructType(let a), .structType(let b)),
             (.structType(let a), .constStructType(let b)),
             (.structType(let a), .structType(let b)):
            guard a == b else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            }
            return ltype
        case (.constPointer(let a), .constPointer(let b)),
             (.constPointer(let a), .pointer(let b)),
             (.pointer(let a), .constPointer(let b)),
             (.pointer(let a), .pointer(let b)):
            guard a == b || a.correspondingConstType == b else {
                throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            }
            return ltype
        default:
            throw CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
        }
    }
        
    public func check(identifier expr: Expression.Identifier) throws -> SymbolType {
        return try symbols.resolveTypeOfIdentifier(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier)
    }
        
    public func check(call: Expression.Call) throws -> SymbolType {
        let calleeType = try check(expression: call.callee)
        guard case .function(let typ) = calleeType else {
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: "cannot call value of non-function type `\(calleeType)'")
        }
        
        if typ.arguments.count > 0 {
            let argName0 = typ.arguments[0].name
            if argName0=="self" {
                let selfExpr: Expression?
                switch call.callee {
                case let expr as Expression.Get:
                    selfExpr = expr.expr
                case let expr as Expression.Identifier:
                    selfExpr = expr
                default:
                    selfExpr = nil
                }
                if let selfExpr = selfExpr {
                    let selfType = try RvalueExpressionTypeChecker(symbols: symbols).check(expression: selfExpr)
                    let argType0 = typ.arguments[0].argumentType
                    if argType0 == selfType || argType0.correspondingConstType == selfType {
                        return try checkStructMemberFunctionCall(call, selfExpr)
                    }
                    if argType0 == .pointer(selfType) || argType0.correspondingConstType == .constPointer(selfType) {
                        let addressOf = Expression.Unary(sourceAnchor: selfExpr.sourceAnchor, op: .ampersand, expression: selfExpr)
                        return try checkStructMemberFunctionCall(call, addressOf)
                    }
                }
            }
        }
        
        if call.arguments.count != typ.arguments.count {
            let message = "incorrect number of arguments in call to `\(typ.name!)'"
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: message)
        }
        for i in 0..<typ.arguments.count {
            let rtype = try rvalueContext().check(expression: call.arguments[i])
            let ltype = typ.arguments[i].argumentType
            let message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to `\(typ.name!)'"
            _ = try checkTypesAreConvertibleInAssignment(ltype: ltype,
                                                         rtype: rtype,
                                                         sourceAnchor: call.arguments[i].sourceAnchor,
                                                         messageWhenNotConvertible: message)
        }
        return typ.returnType
    }
    
    // TODO: checkStructMemberFunctionCall() is similar to a normal function call and perhaps some of these two can be consolidated by extracting some helper methods.
    public func checkStructMemberFunctionCall(_ call: Expression.Call, _ selfExpr: Expression) throws -> SymbolType {
        let calleeType = try check(expression: call.callee)
        guard case .function(_) = calleeType else {
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: "cannot call value of non-function type `\(calleeType)'")
        }
        
        let typ = calleeType.unwrapFunctionType()
        
        if call.arguments.count != typ.arguments.count-1 {
            let message = "incorrect number of arguments in call to `\(typ.name!)'"
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: message)
        }
        
        // Insert the object into the first argument in a UFCS call.
        let rtype0 = try rvalueContext().check(expression: selfExpr)
        let ltype0 = typ.arguments[0].argumentType
        let message0 = "cannot convert value of type `\(rtype0)' to expected argument type `\(ltype0)' in call to `\(typ.name!)'"
        _ = try checkTypesAreConvertibleInAssignment(ltype: ltype0,
                                                     rtype: rtype0,
                                                     sourceAnchor: selfExpr.sourceAnchor,
                                                     messageWhenNotConvertible: message0)
        
        // The remaining arguments come from the parameter list as usual.
        for i in 0..<call.arguments.count {
            let rtype = try rvalueContext().check(expression: call.arguments[i])
            let ltype = typ.arguments[i+1].argumentType
            let message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to `\(typ.name!)'"
            _ = try checkTypesAreConvertibleInAssignment(ltype: ltype,
                                                         rtype: rtype,
                                                         sourceAnchor: call.arguments[i].sourceAnchor,
                                                         messageWhenNotConvertible: message)
        }
        
        return typ.returnType
    }
        
    public func check(as expr: Expression.As) throws -> SymbolType {
        let ltype = try check(expression: expr.targetType)
        let rtype = try check(expression: expr.expr)
        return try checkTypesAreConvertibleInExplicitCast(ltype: ltype,
                                                          rtype: rtype,
                                                          sourceAnchor: expr.sourceAnchor,
                                                          messageWhenNotConvertible: "cannot convert value of type `\(rtype)' to type `\(ltype)'")
    }
    
    public func check(subscript expr: Expression.Subscript) throws -> SymbolType {
        let symbol = try symbols.resolve(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier.identifier)
        switch symbol.type {
        case .array(count: _, elementType: let elementType),
             .constDynamicArray(elementType: let elementType),
             .dynamicArray(elementType: let elementType):
            let argumentType = try rvalueContext().check(expression: expr.expr)
            guard argumentType.isArithmeticType else {
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
        case .array, .constDynamicArray, .dynamicArray:
            if name == "count" {
                return .u16
            }
        case .constStructType(let typ):
            if let symbol = typ.symbols.maybeResolve(identifier: name) {
                return symbol.type.correspondingConstType
            }
        case .structType(let typ):
            if let symbol = typ.symbols.maybeResolve(identifier: name) {
                return symbol.type
            }
        case .constPointer(let typ), .pointer(let typ):
            if name == "pointee" {
                return typ
            } else {
                switch typ {
                case .array, .constDynamicArray, .dynamicArray:
                    if name == "count" {
                        return .u16
                    }
                case .constStructType(let b):
                    if let symbol = b.symbols.maybeResolve(identifier: name) {
                        return symbol.type.correspondingConstType
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
            case .compTimeInt(let a):
                count = a
            default:
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "array count must be a compile time constant, got `\(typeOfCountExpr)' instead")
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
        
        let mangledName = Array(NSOrderedSet(array: symbols.allEnclosingFunctionNames() + [expr.name])).map{$0 as! String}.joined(separator: "_")
        
        return .function(FunctionType(name: expr.name,
                                      mangledName: mangledName,
                                      returnType: returnType,
                                      arguments: arguments))
    }
    
    public func check(pointerType expr: Expression.PointerType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return .pointer(typ)
    }
    
    public func check(constType expr: Expression.ConstType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return typ.correspondingConstType
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
