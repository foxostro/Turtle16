//
//  RvalueExpressionTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

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
            return check(literalInt: expr)
        case let expr as Expression.LiteralBool:
            return .bool(.compTimeBool(expr.value))
        case let expr as Expression.Group:
            return try check(expression: expr.expression)
        case let expr as Expression.Unary:
            return try check(unary: expr)
        case let expr as Expression.Binary:
            return try check(binary: expr)
        case let identifier as Expression.Identifier:
            return try check(identifier: identifier)
        case let assig as Expression.Assignment:
            return try check(assignment: assig)
        case let call as Expression.Call:
            return try check(call: call)
        case let expr as Expression.As:
            return try check(as: expr)
        case let expr as Expression.Is:
            return try check(is: expr)
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
        case let expr as Expression.UnionType:
            return try check(unionType: expr)
        case let expr as Expression.LiteralString:
            return try check(literalString: expr)
        case let expr as Expression.TypeOf:
            return try check(typeOf: expr)
        case let expr as Expression.Bitcast:
            return try check(bitcast: expr)
        case let expr as Expression.SizeOf:
            return try check(sizeOf: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }
    
    public func check(literalInt expr: Expression.LiteralInt) -> SymbolType {
        return .arithmeticType(.compTimeInt(expr.value))
    }
        
    public func check(unary: Expression.Unary) throws -> SymbolType {
        let expressionType = try check(expression: unary.child)
        switch unary.op {
        case .minus:
            switch expressionType {
            case .arithmeticType(let arithmeticType):
                switch arithmeticType {
                case .compTimeInt(let value):
                    return .arithmeticType(.compTimeInt(-value))
                default:
                    return expressionType
                }
            default:
                throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "Unary operator `\(unary.op.description)' cannot be applied to an operand of type `\(expressionType)'")
            }
        case .ampersand:
            guard let lvalueType = try lvalueContext().check(expression: unary.child) else {
                throw CompilerError(sourceAnchor: unary.child.sourceAnchor, message: "lvalue required as operand of unary operator `\(unary.op.description)'")
            }
            if case .function(let typ) = lvalueType {
                return .pointer(.function(typ.eraseName()))
            } else {
                return .pointer(lvalueType)
            }
        case .tilde:
            switch expressionType {
            case .arithmeticType(let arithmeticType):
                switch arithmeticType {
                case .compTimeInt(let value):
                    return .arithmeticType(.compTimeInt(~value))
                default:
                    return expressionType
                }
            default:
                throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "Unary operator `\(unary.op.description)' cannot be applied to an operand of type `\(expressionType)'")
            }
        case .bang:
            switch expressionType {
            case .bool(let boolTyp):
                switch boolTyp {
                case .compTimeBool(let value):
                    return .bool(.compTimeBool(!value))
                default:
                    return expressionType
                }
            default:
                throw CompilerError(sourceAnchor: unary.sourceAnchor, message: "Unary operator `\(unary.op.description)' cannot be applied to an operand of type `\(expressionType)'")
            }
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
        case .doubleAmpersand: return "&&"
        case .pipe: return "|"
        case .doublePipe: return "||"
        case .bang: return "!"
        case .caret: return "^"
        case .leftDoubleAngle: return "<<"
        case .rightDoubleAngle: return ">>"
        case .tilde: return "~"
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
        
        if case .bool(.compTimeBool) = leftType, case .bool(.compTimeBool) = rightType {
            return try checkConstantBooleanBinaryExpression(binary, leftType, rightType)
        }
        
        _ = try checkTypesAreConvertibleInAssignment(ltype: .bool(.mutableBool),
                                                     rtype: leftType,
                                                     sourceAnchor: binary.left.sourceAnchor,
                                                     messageWhenNotConvertible: "cannot convert value of type `\(leftType)' to type `bool'")
        
        _ = try checkTypesAreConvertibleInAssignment(ltype: .bool(.mutableBool),
                                                     rtype: rightType,
                                                     sourceAnchor: binary.right.sourceAnchor,
                                                     messageWhenNotConvertible: "cannot convert value of type `\(rightType)' to type `bool'")
        
        switch binary.op {
        case .eq, .ne, .doubleAmpersand, .doublePipe:
            return .bool(.mutableBool)
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
        }
    }
    
    private func checkConstantBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        guard case .bool(.compTimeBool(let a)) = leftType, case .bool(.compTimeBool(let b)) = rightType else {
            assert(false)
            abort()
        }
        
        switch binary.op {
        case .eq:
            return .bool(.compTimeBool(a == b))
        case .ne:
            return .bool(.compTimeBool(a != b))
        case .doubleAmpersand:
            return .bool(.compTimeBool(a && b))
        case .doublePipe:
            return .bool(.compTimeBool(a || b))
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
        }
    }
    
    private func checkArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        switch (leftType, rightType) {
        case (.arithmeticType(.compTimeInt), .arithmeticType(.compTimeInt)):
            return try checkConstantArithmeticBinaryExpression(binary, leftType, rightType)
        
        case (.arithmeticType(let leftArithmeticType), .arithmeticType(let rightArithmeticType)):
            guard let arithmeticTypeForArithmetic = ArithmeticType.binaryResultType(left: leftArithmeticType, right: rightArithmeticType) else {
                throw invalidBinaryExpr(binary, leftType, rightType)
            }
            
            let typeForArithmetic: SymbolType = .arithmeticType(arithmeticTypeForArithmetic)
            
            _ = try checkTypesAreConvertibleInAssignment(ltype: typeForArithmetic,
                                                         rtype: rightType,
                                                         sourceAnchor: binary.right.sourceAnchor,
                                                         messageWhenNotConvertible: "cannot convert value of type `\(rightType)' to type `\(typeForArithmetic)'")
            
            _ = try checkTypesAreConvertibleInAssignment(ltype: typeForArithmetic,
                                                         rtype: leftType,
                                                         sourceAnchor: binary.left.sourceAnchor,
                                                         messageWhenNotConvertible: "cannot convert value of type `\(leftType)' to type `\(typeForArithmetic)'")
            
            switch binary.op {
            case .eq, .ne, .lt, .gt, .le, .ge:
                return .bool(.mutableBool)
            case .plus, .minus, .star, .divide, .modulus, .ampersand, .pipe, .caret, .leftDoubleAngle, .rightDoubleAngle:
                return typeForArithmetic
            default:
                throw invalidBinaryExpr(binary, leftType, rightType)
            }
            
        default:
            assert(false)
            abort()
        }
    }
    
    private func checkConstantArithmeticBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        guard case .arithmeticType(.compTimeInt(let a)) = leftType, case .arithmeticType(.compTimeInt(let b)) = rightType else {
            assert(false)
            abort()
        }
        
        switch binary.op {
        case .eq:
            return .bool(.compTimeBool(a == b))
        case .ne:
            return .bool(.compTimeBool(a != b))
        case .lt:
            return .bool(.compTimeBool(a < b))
        case .gt:
            return .bool(.compTimeBool(a > b))
        case .le:
            return .bool(.compTimeBool(a <= b))
        case .ge:
            return .bool(.compTimeBool(a >= b))
        case .plus:
            return .arithmeticType(.compTimeInt(a + b))
        case .minus:
            return .arithmeticType(.compTimeInt(a - b))
        case .star:
            return .arithmeticType(.compTimeInt(a * b))
        case .divide:
            return .arithmeticType(.compTimeInt(a / b))
        case .modulus:
            return .arithmeticType(.compTimeInt(a % b))
        case .ampersand:
            return .arithmeticType(.compTimeInt(a & b))
        case .pipe:
            return .arithmeticType(.compTimeInt(a | b))
        case .caret:
            return .arithmeticType(.compTimeInt(a ^ b))
        case .leftDoubleAngle:
            return .arithmeticType(.compTimeInt(a << b))
        case .rightDoubleAngle:
            return .arithmeticType(.compTimeInt(a >> b))
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
        
        if case .traitType = ltype, case .constTraitType = ltype {
            print("trait here")
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
    
    public enum TypeConversionStatus {
    case acceptable(SymbolType)
    case unacceptable(CompilerError)
    }
    
    public func convertBetweenTypes(ltype: SymbolType,
                                    rtype: SymbolType,
                                    sourceAnchor: SourceAnchor?,
                                    messageWhenNotConvertible: String,
                                    isExplicitCast: Bool) -> TypeConversionStatus {
        // Integer constants will be automatically converted to appropriate
        // concrete integer types.
        //
        // Small integer types will be automatically promoted to larger types.
        
        // Do not allow function types to be converted at all.
        if ltype.isFunctionType || rtype.isFunctionType {
            return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: "inappropriate use of a function type (Try taking the function's address instead.)"))
        }
        
        // If the types match exactly then the conversion is acceptable.
        if rtype == ltype {
            return .acceptable(ltype)
        }
        
        switch (rtype, ltype) {
        case (.arithmeticType(let a), .arithmeticType(let b)):
            switch (a, b) {
            case (.compTimeInt(let constantValue), .mutableInt(let intClassDst)),
                 (.compTimeInt(let constantValue), .immutableInt(let intClassDst)):
                if constantValue >= intClassDst.min && constantValue <= intClassDst.max {
                    return .acceptable(ltype) // The conversion is acceptable.
                }
                else {
                    return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: "integer constant `\(constantValue)' overflows when stored into `\(ltype)'"))
                }
            default:
                if let intClassA = a.intClass, let intClassB = b.intClass {
                    if (intClassB.min <= intClassA.min && intClassB.max >= intClassA.max) || isExplicitCast {
                        return .acceptable(ltype) // The conversion is acceptable.
                    }
                }
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
        case (.bool(let a), .bool(let b)):
            switch (a, b) {
            case (.compTimeBool, .immutableBool),
                 (.compTimeBool, .mutableBool),
                 (.immutableBool, .immutableBool),
                 (.immutableBool, .mutableBool),
                 (.mutableBool, .immutableBool),
                 (.mutableBool, .mutableBool):
                return .acceptable(ltype) // The conversion is acceptable.
                
            default:
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
        case (.array(let n, let a), .array(let m, let b)):
            guard n == m || m == nil else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
            switch convertBetweenTypes(ltype: b,
                                       rtype: a,
                                       sourceAnchor: sourceAnchor,
                                       messageWhenNotConvertible: messageWhenNotConvertible,
                                       isExplicitCast: isExplicitCast) {
            case .acceptable(let elementType):
                return .acceptable(.array(count: n, elementType: elementType))
            case .unacceptable(let err):
                return .unacceptable(err)
            }
        case (.array(let n, let a), .constDynamicArray(elementType: let b)),
             (.array(let n, let a), .dynamicArray(elementType: let b)):
            guard n != nil else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
            switch convertBetweenTypes(ltype: b,
                                       rtype: a,
                                       sourceAnchor:
                                        sourceAnchor,
                                       messageWhenNotConvertible: messageWhenNotConvertible,
                                       isExplicitCast: isExplicitCast) {
            case .acceptable:
                return .acceptable(ltype)
            case .unacceptable(let err):
                return .unacceptable(err)
            }
        case (.constDynamicArray(let a), .constDynamicArray(let b)),
             (.constDynamicArray(let a), .dynamicArray(let b)),
             (.dynamicArray(let a), .constDynamicArray(let b)),
             (.dynamicArray(let a), .dynamicArray(let b)):
            guard a == b || a.correspondingConstType == b else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
            return .acceptable(.dynamicArray(elementType: b))
        case (.constStructType(let a), .constStructType(let b)),
             (.constStructType(let a), .structType(let b)),
             (.structType(let a), .constStructType(let b)),
             (.structType(let a), .structType(let b)):
            guard a == b else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
            return .acceptable(ltype)
        case (.constPointer(let a), .constPointer(let b)),
             (.constPointer(let a), .pointer(let b)),
             (.pointer(let a), .constPointer(let b)),
             (.pointer(let a), .pointer(let b)):
            guard a == b || a.correspondingConstType == b else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
            return .acceptable(ltype)
        case (.unionType(let a), .unionType(let b)):
            if b == a.correspondingConstType {
                return .acceptable(ltype)
            } else if b.correspondingConstType == a {
                return .acceptable(ltype)
            } else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
        case (.unionType(let typ), _):
            if !isExplicitCast {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: "cannot implicitly convert a union type `\(rtype)' to `\(ltype)'; use an explicit conversion instead"))
            }
            for member in typ.members {
                let status = convertBetweenTypes(ltype: ltype,
                                                 rtype: member,
                                                 sourceAnchor: sourceAnchor,
                                                 messageWhenNotConvertible: messageWhenNotConvertible,
                                                 isExplicitCast: isExplicitCast)
                switch status {
                case .acceptable(let symbolType):
                    return .acceptable(symbolType)
                case .unacceptable:
                    break // just move on to the next one
                }
            }
            return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
        case (_, .unionType(let typ)):
            for member in typ.members {
                let status = convertBetweenTypes(ltype: member,
                                                 rtype: rtype,
                                                 sourceAnchor: sourceAnchor,
                                                 messageWhenNotConvertible: messageWhenNotConvertible,
                                                 isExplicitCast: isExplicitCast)
                switch status {
                case .acceptable:
                    return .acceptable(ltype)
                default:
                    break // just move on to the next one
                }
            }
            return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
        case (.constPointer(let a), .traitType(let b)),
             (.pointer(let a), .traitType(let b)),
             (.constPointer(let a), .constTraitType(let b)),
             (.pointer(let a), .constTraitType(let b)):
            switch a {
            case .constStructType(let structType), .structType(let structType):
                let nameOfVtableInstance = "__\(b.name)_\(structType.name)_vtable_instance"
                let vtableInstance = symbols.maybeResolve(identifier: nameOfVtableInstance)
                if vtableInstance != nil {
                    return .acceptable(ltype)
                }
            
            default:
                break
            }
            return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
        case (.constStructType(let a), .traitType(let b)),
             (.structType(let a), .traitType(let b)),
             (.constStructType(let a), .constTraitType(let b)),
             (.structType(let a), .constTraitType(let b)):
            let nameOfVtableInstance = "__\(b.name)_\(a.name)_vtable_instance"
            let vtableInstance = symbols.maybeResolve(identifier: nameOfVtableInstance)
            if vtableInstance != nil {
                return .acceptable(ltype)
            } else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
        case (.constTraitType(let a), .traitType(let b)),
             (.traitType(let a), .constTraitType(let b)):
            guard a == b else {
                return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
            }
            return .acceptable(ltype)
        case (_, .constPointer(let b)),
             (_, .pointer(let b)):
            if rtype.correspondingConstType == b.correspondingConstType {
                return .acceptable(ltype)
            }
            else {
                switch rtype {
                case .constTraitType(let a), .traitType(let a):
                    let traitObjectType = try? symbols.resolveType(identifier: a.nameOfTraitObjectType)
                    if traitObjectType == b {
                        return .acceptable(ltype)
                    }
                
                default:
                    break
                }
            }
            return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
        default:
            return .unacceptable(CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible))
        }
    }
    
    private func checkTypesAreConvertible(ltype: SymbolType,
                                          rtype: SymbolType,
                                          sourceAnchor: SourceAnchor?,
                                          messageWhenNotConvertible: String,
                                          isExplicitCast: Bool) throws -> SymbolType {
        let status = convertBetweenTypes(ltype: ltype,
                                         rtype: rtype,
                                         sourceAnchor: sourceAnchor,
                                         messageWhenNotConvertible: messageWhenNotConvertible,
                                         isExplicitCast: isExplicitCast)
        switch status {
        case .acceptable(let symbolType):
            return symbolType
        case .unacceptable(let err):
            throw err
        }
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
        
    public func check(identifier expr: Expression.Identifier) throws -> SymbolType {
        return try symbols.resolveTypeOfIdentifier(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier)
    }
        
    public func check(call: Expression.Call) throws -> SymbolType {
        let calleeType = try check(expression: call.callee)
        switch calleeType {
        case .function(let typ), .pointer(.function(let typ)), .constPointer(.function(let typ)):
            return try check(call: call, typ: typ)
        default:
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: "cannot call value of non-function type `\(calleeType)'")
        }
    }
    
    private func check(call: Expression.Call, typ: FunctionType) throws -> SymbolType {
        do {
            return try checkInner(call: call, typ: typ)
        }
        catch let err as CompilerError {
            if let rewritten = try rewriteStructMemberFunctionCallIfPossible(call) {
                return try checkInner(call: rewritten, typ: typ)
            } else {
                throw err
            }
        }
    }
    
    func checkInner(call: Expression.Call, typ: FunctionType) throws -> SymbolType {
        if call.arguments.count != typ.arguments.count {
            let message: String
            if let name = typ.name {
                message = "incorrect number of arguments in call to `\(name)'"
            } else {
                message = "incorrect number of arguments in call to function of type `\(typ)'"
            }
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: message)
        }
        
        for i in 0..<typ.arguments.count {
            let rtype = try rvalueContext().check(expression: call.arguments[i])
            let ltype = typ.arguments[i]
            let message: String
            if let name = typ.name {
                message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to `\(name)'"
            } else {
                message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to function of type `\(typ)'"
            }
            _ = try checkTypesAreConvertibleInAssignment(ltype: ltype,
                                                         rtype: rtype,
                                                         sourceAnchor: call.arguments[i].sourceAnchor,
                                                         messageWhenNotConvertible: message)
        }
        
        return typ.returnType
    }
    
    fileprivate func rewriteStructMemberFunctionCallIfPossible(_ expr: Expression.Call) throws -> Expression.Call? {
        guard let match = try StructMemberFunctionCallMatcher(call: expr, typeChecker: self).match() else {
            return nil
        }
        
        return Expression.Call(sourceAnchor: match.callExpr.sourceAnchor,
                               callee: Expression.Get(sourceAnchor: match.callExpr.sourceAnchor,
                                                      expr: match.getExpr.expr,
                                                      member: match.getExpr.member),
                               arguments: [match.getExpr.expr] + match.callExpr.arguments)
    }
        
    public func check(as expr: Expression.As) throws -> SymbolType {
        let ltype = try check(expression: expr.targetType)
        let rtype = try check(expression: expr.expr)
        return try checkTypesAreConvertibleInExplicitCast(ltype: ltype,
                                                          rtype: rtype,
                                                          sourceAnchor: expr.sourceAnchor,
                                                          messageWhenNotConvertible: "cannot convert value of type `\(rtype)' to type `\(ltype)'")
    }
    
    public func check(is expr: Expression.Is) throws -> SymbolType {
        let ltype = try check(expression: expr.expr)
        let rtype = try check(expression: expr.testType)
        switch ltype {
        case .unionType(let typ):
            if typ.members.contains(rtype) || typ.members.contains(rtype.correspondingConstType) {
                return .bool(.mutableBool)
            } else {
                return .bool(.compTimeBool(false))
            }
        default:
            return .bool(.compTimeBool(ltype == rtype || ltype.correspondingConstType == rtype || ltype == rtype.correspondingConstType))
        }
    }
    
    public func check(subscript expr: Expression.Subscript) throws -> SymbolType {
        let subscriptableType = try check(expression: expr.subscriptable)
        switch subscriptableType {
        case .array(count: _, elementType: let elementType),
             .constDynamicArray(elementType: let elementType),
             .dynamicArray(elementType: let elementType):
            let argumentType = try rvalueContext().check(expression: expr.argument)
            let typeError = CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot subscript a value of type `\(subscriptableType)' with an argument of type `\(argumentType)'")
            switch argumentType {
            case .structType(let typ), .constStructType(let typ):
                if isRangeType(typ) {
                    return .dynamicArray(elementType: elementType)
                } else {
                    throw typeError
                }
            default:
                break
            }
            if argumentType.isArithmeticType {
                return elementType
            }
            throw typeError
        default:
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(subscriptableType)' has no subscripts")
        }
    }
    
    fileprivate func isRangeType(_ typ: StructType) -> Bool {
        guard typ.name == "Range" else {
            return false
        }
        guard typ.symbols.maybeResolve(identifier: "begin")?.type == .arithmeticType(.mutableInt(.u16)) else {
            return false
        }
        guard typ.symbols.maybeResolve(identifier: "limit")?.type == .arithmeticType(.mutableInt(.u16)) else {
            return false
        }
        return true
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
        if let structInitializer = expr.expr as? Expression.StructInitializer {
            let argument = structInitializer.arguments.first(where: {$0.name == expr.member.identifier})
            let memberExpr = argument!.expr
            return try check(expression: memberExpr)
        }
        
        let name = expr.member.identifier
        let resultType = try check(expression: expr.expr)
        switch resultType {
        case .array, .constDynamicArray, .dynamicArray:
            if name == "count" {
                return .arithmeticType(.mutableInt(.u16))
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
                        return .arithmeticType(.mutableInt(.u16))
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
        case .constTraitType(let typ), .traitType(let typ):
            return try check(get: Expression.Get(sourceAnchor: expr.sourceAnchor,
                                                 expr: Expression.Identifier(typ.nameOfTraitObjectType),
                                                 member: expr.member))
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
            case .arithmeticType(.compTimeInt(let a)):
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
        var arguments: [SymbolType] = []
        for arg in expr.arguments {
            let typ = try check(expression: arg)
            arguments.append(typ)
        }
        
        let mangledName: String?
        if let name = expr.name {
            mangledName = Array(NSOrderedSet(array: symbols.allEnclosingFunctionNames() + [name])).map{$0 as! String}.joined(separator: "_")
        } else {
            mangledName = nil
        }
        
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
    
    public func check(unionType expr: Expression.UnionType) throws -> SymbolType {
        let members = try expr.members.map({try check(expression: $0)})
        return .unionType(UnionType(members))
    }
    
    public func check(literalString expr: Expression.LiteralString) throws -> SymbolType {
        return .array(count: expr.value.count, elementType: .arithmeticType(.mutableInt(.u8)))
    }
    
    public func check(typeOf expr: Expression.TypeOf) throws -> SymbolType {
        return try rvalueContext().check(expression: expr.expr)
    }
    
    public func check(bitcast expr: Expression.Bitcast) throws -> SymbolType {
        return try rvalueContext().check(expression: expr.targetType)
    }
    
    public func check(sizeOf expr: Expression.SizeOf) throws -> SymbolType {
        return .arithmeticType(.immutableInt(.u16)) // TODO: should the runtime provide a `usize' typealias for this?
    }
    
    func unsupportedError(expression: Expression) -> Error {
        return CompilerError(sourceAnchor: expression.sourceAnchor,
                             message: "unsupported expression: \(expression)")
    }
}
