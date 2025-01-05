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
    public let globalEnvironment: GlobalEnvironment!
    
    public init(symbols: SymbolTable = SymbolTable(), globalEnvironment: GlobalEnvironment? = nil) {
        self.symbols = symbols
        self.globalEnvironment = globalEnvironment
    }
        
    func rvalueContext() -> RvalueExpressionTypeChecker {
        return RvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
    }
        
    func lvalueContext() -> LvalueExpressionTypeChecker {
        return LvalueExpressionTypeChecker(symbols: symbols, globalEnvironment: globalEnvironment)
    }
    
    @discardableResult public func check(expression: Expression) throws -> SymbolType {
        switch expression {
        case let expr as Expression.LiteralInt:
            return check(literalInt: expr)
        case let expr as Expression.LiteralBool:
            return .booleanType(.compTimeBool(expr.value))
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
        case let expr as Expression.GenericFunctionType:
            return try check(genericFunctionType: expr)
        case let expr as Expression.GenericTypeApplication:
            return try check(genericTypeApplication: expr)
        case let expr as Expression.PointerType:
            return try check(pointerType: expr)
        case let expr as Expression.ConstType:
            return try check(constType: expr)
        case let expr as Expression.MutableType:
            return try check(mutableType: expr)
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
        case let expr as Expression.Eseq:
            return try check(eseq: expr)
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
            case .booleanType(let boolTyp):
                switch boolTyp {
                case .compTimeBool(let value):
                    return .booleanType(.compTimeBool(!value))
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
        
        if case .booleanType(.compTimeBool) = leftType, case .booleanType(.compTimeBool) = rightType {
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
        case .eq, .ne, .doubleAmpersand, .doublePipe:
            return .bool
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
        }
    }
    
    private func checkConstantBooleanBinaryExpression(_ binary: Expression.Binary, _ leftType: SymbolType, _ rightType: SymbolType) throws -> SymbolType {
        guard case .booleanType(.compTimeBool(let a)) = leftType, case .booleanType(.compTimeBool(let b)) = rightType else {
            assert(false)
            abort()
        }
        
        switch binary.op {
        case .eq:
            return .booleanType(.compTimeBool(a == b))
        case .ne:
            return .booleanType(.compTimeBool(a != b))
        case .doubleAmpersand:
            return .booleanType(.compTimeBool(a && b))
        case .doublePipe:
            return .booleanType(.compTimeBool(a || b))
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
                return .bool
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
            return .booleanType(.compTimeBool(a == b))
        case .ne:
            return .booleanType(.compTimeBool(a != b))
        case .lt:
            return .booleanType(.compTimeBool(a < b))
        case .gt:
            return .booleanType(.compTimeBool(a > b))
        case .le:
            return .booleanType(.compTimeBool(a <= b))
        case .ge:
            return .booleanType(.compTimeBool(a >= b))
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
        if rtype == ltype && rtype != .void {
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
        case (.booleanType(let a), .booleanType(let b)):
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
            let traitType: TraitType = b
            switch a {
            case .constStructType(let structType), .structType(let structType):
                let conforms = doesStructConformToVtable(structType, traitType)
                if conforms {
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
            let nameOfVtableInstance = nameOfVtableInstance(
                traitName: b.name,
                structName: a.name)
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
    
    private func areTypesConvertible(ltype: SymbolType, rtype: SymbolType) -> Bool {
        let status = convertBetweenTypes(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: nil,
            messageWhenNotConvertible: "",
            isExplicitCast: false)
        
        return switch status {
        case .acceptable:   false
        case .unacceptable: true
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
    
    /// Return true if it is acceptable to convert from rtype to ltype
    public func areTypesAreConvertible(
        ltype: SymbolType,
        rtype: SymbolType,
        isExplicitCast: Bool) -> Bool {
        
        switch convertBetweenTypes(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: nil,
            messageWhenNotConvertible: "",
            isExplicitCast: isExplicitCast) {
        case .acceptable:   true
        case .unacceptable: false
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
        let rvalueType = try symbols.resolveTypeOfIdentifier(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier)
        
        switch rvalueType {
        case .genericFunction(let typ):
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot instantiate generic function `\(typ.description)'")
            
        case .genericStructType(let typ):
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot instantiate generic struct `\(typ.description)'")
            
        case .genericTraitType(let typ):
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot instantiate generic trait `\(typ.description)'")
            
        default:
            return rvalueType
        }
    }
        
    public func check(call: Expression.Call) throws -> SymbolType {
        let calleeType: SymbolType
        if let identifier = call.callee as? Expression.Identifier {
            calleeType = try symbols.resolveTypeOfIdentifier(sourceAnchor: identifier.sourceAnchor, identifier: identifier.identifier)
        }
        else {
            calleeType = try check(expression: call.callee)
        }
        return try check(call: call, calleeType: calleeType)
    }
    
    private func check(call: Expression.Call, calleeType: SymbolType) throws -> SymbolType {
        switch calleeType {
        case .genericFunction(let typ):
            return try check(call: call, genericFunctionType: typ)
        case .function(let typ), .pointer(.function(let typ)), .constPointer(.function(let typ)):
            return try check(call: call, typ: typ)
        default:
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: "cannot call value of non-function type `\(calleeType)'")
        }
    }
    
    private func check(call expr: Expression.Call, genericFunctionType: Expression.GenericFunctionType) throws -> SymbolType {
        let a = try synthesizeGenericTypeApplication(call: expr, genericFunctionType: genericFunctionType)
        let calleeType = try check(genericTypeApplication: a)
        return try check(call: expr, calleeType: calleeType)
    }
    
    public func synthesizeGenericTypeApplication(call expr: Expression.Call, genericFunctionType: Expression.GenericFunctionType) throws -> Expression.GenericTypeApplication {
        guard let identifier = expr.callee as? Expression.Identifier else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "expected identifier, got `\(expr.callee)'")
        }
        let typeArguments = try inferTypeArguments(call: expr, genericFunctionType: genericFunctionType)
        let a = Expression.GenericTypeApplication(sourceAnchor: expr.sourceAnchor,
                                                  identifier: identifier,
                                                  arguments: typeArguments)
        return a
    }
    
    private func inferTypeArguments(call expr: Expression.Call, genericFunctionType generic: Expression.GenericFunctionType) throws -> [Expression] {
        let solver = GenericFunctionTypeArgumentSolver()
        let typeArguments = try solver.inferTypeArguments(call: expr,
                                                          genericFunctionType: generic,
                                                          symbols: symbols)
        return typeArguments.map {
            Expression.PrimitiveType($0)
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
                return .bool
            } else {
                return .booleanType(.compTimeBool(false))
            }
        default:
            return .booleanType(.compTimeBool(ltype == rtype || ltype.correspondingConstType == rtype || ltype == rtype.correspondingConstType))
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
            
        case .structType(let typ), .constStructType(let typ):
            // TODO: The compiler treats Range specially but maybe it shouldn't. We could instead have a way to provide an overload of the subscript operator or some other solution in the standard library.
            if typ.name == "Range" {
                return .u16
            }
            else {
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(subscriptableType)' has no subscripts")
            }
            
        default:
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(subscriptableType)' has no subscripts")
        }
    }
    
    fileprivate func isRangeType(_ typ: StructType) -> Bool {
        guard typ.name == "Range" else {
            return false
        }
        guard typ.symbols.maybeResolve(identifier: "begin")?.type == .u16 else {
            return false
        }
        guard typ.symbols.maybeResolve(identifier: "limit")?.type == .u16 else {
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
        if let _ = expr.member as? Expression.Identifier {
            return try check(getIdent: expr)
        }
        else if let _ = expr.member as? Expression.GenericTypeApplication {
            return try check(getApp: expr)
        }
        else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "unsupported get expression `\(expr)'")
        }
    }
    
    private func check(getIdent expr: Expression.Get) throws -> SymbolType {
        let member = expr.member as! Expression.Identifier
        
        if let structInitializer = expr.expr as? Expression.StructInitializer {
            let argument = structInitializer.arguments.first(where: {$0.name == member.identifier})
            if let argument {
                return try check(expression: argument.expr)
            }
            else {
                let a = try check(structInitializer: structInitializer)
                switch a {
                case .structType(let typ), .constStructType(let typ):
                    // TODO: The compiler has special handling of Range.count but maybe it shouldn't. The compiler could provide a way to write a specialized Range.count property or something like that
                    if typ.name == "Range", member.identifier == "count" {
                        return .u16
                    }
                               
                default:
                    break
                }
                
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(a)' has no member `\(member.identifier)'")
            }
        }
        
        let name = member.identifier
        let objectType = try check(expression: expr.expr)
        switch objectType {
        case .array, .constDynamicArray, .dynamicArray:
            if name == "count" {
                return .u16
            }
        case .constStructType(let typ):
            // TODO: The compiler treats Range specially but maybe it shouldn't do this. We could have some way to provide a specific template specialization and do it in stdlib.
            if typ.name == "Range", name == "count" {
                return .u16
            }
            else if let symbol = typ.symbols.maybeResolve(identifier: name) {
                return symbol.type.correspondingConstType
            }
        case .structType(let typ):
            if typ.name == "Range", name == "count" {
                return .u16
            }
            else if let symbol = typ.symbols.maybeResolve(identifier: name) {
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
        case .constTraitType(let typ), .traitType(let typ):
            return try check(get: Expression.Get(sourceAnchor: expr.sourceAnchor,
                                                 expr: Expression.Identifier(typ.nameOfTraitObjectType),
                                                 member: expr.member))
        default:
            break
        }
        throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(objectType)' has no member `\(name)'")
    }
    
    private func check(getApp expr: Expression.Get) throws -> SymbolType {
        let app = expr.member as! Expression.GenericTypeApplication
        
        let name = app.identifier.identifier
        let resultType = try check(expression: expr.expr)
        switch resultType {
        case .constStructType(let typ), .structType(let typ):
            let type = try check(genericTypeApplication: app, symbols: typ.symbols)
            return type
        case .constPointer(let typ), .pointer(let typ):
            switch typ {
            case .constStructType(let b), .structType(let b):
                let type = try check(genericTypeApplication: app, symbols: b.symbols)
                return type
            default:
                break
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
        let arguments = try evaluateFunctionArguments(expr.arguments)
        let mangledName = mangleFunctionName(expr.name)
        
        return .function(FunctionType(name: expr.name,
                                      mangledName: mangledName,
                                      returnType: returnType,
                                      arguments: arguments))
    }
    
    public func mangleFunctionName(_ name: String?, evaluatedTypeArguments: [SymbolType] = []) -> String? {
        guard let name else {
            return nil
        }
        
        // Each concrete instance must have a unique mangled name. We append a
        // suffix derived from the type argument list to ensure it.
        let typeNameList = evaluatedTypeArguments.map { arg in
            arg.description.replacingOccurrences(of: " ", with: "_")
        }
        
        let allEnclosingFunctionNames = symbols.allEnclosingFunctionNames().map {
            $0.hasPrefix("__") ? String($0.dropFirst(2)) : $0
        }
        let arr = Array(NSOrderedSet(array: allEnclosingFunctionNames + [name] + typeNameList))
        var mangledName = arr.map{$0 as! String}.joined(separator: "_")
        
        if arr.count > 1 && !mangledName.hasPrefix("__") {
            mangledName = "__" + mangledName
        }
        
        return mangledName
    }
    
    public func mangleStructName(_ name: String?, evaluatedTypeArguments: [SymbolType] = []) -> String? {
        guard let name else {
            return nil
        }
        
        // Each concrete instance must have a unique mangled name. We append a
        // suffix derived from the type argument list to ensure it.
        let typeNameList = evaluatedTypeArguments.map { arg in
            arg.description.replacingOccurrences(of: " ", with: "_")
        }
        
        let arr = Array(NSOrderedSet(array: [name] + typeNameList))
        let prefix: String = (arr.count == 1) ? "" : "__"
        let mangledName = prefix + arr.map{$0 as! String}.joined(separator: "_")
        
        return mangledName
    }
    
    public func mangleTraitName(_ name: String?, evaluatedTypeArguments: [SymbolType] = []) -> String? {
        mangleStructName(name, evaluatedTypeArguments: evaluatedTypeArguments)
    }
    
    fileprivate func evaluateFunctionArguments(_ argsToEvaluate: [Expression]) throws -> [SymbolType] {
        try argsToEvaluate.map {
            try check(expression: $0)
        }
    }
    
    public func check(genericFunctionType expr: Expression.GenericFunctionType) throws -> SymbolType {
        throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "cannot instantiate generic function `\(expr.description)'")
    }
    
    public func check(genericTypeApplication expr: Expression.GenericTypeApplication) throws -> SymbolType {
        return try check(genericTypeApplication: expr, symbols: symbols)
    }
    
    fileprivate func check(genericTypeApplication expr: Expression.GenericTypeApplication, symbols: SymbolTable) throws -> SymbolType {
        let typeOfIdentifier = try symbols.resolveTypeOfIdentifier(sourceAnchor: expr.sourceAnchor, identifier: expr.identifier.identifier)
        
        switch typeOfIdentifier {
        case .genericFunction(let typ):
            let resolvedType = try apply(
                genericTypeApplication: expr,
                genericFunctionType: typ)
            
            // We must update the symbol table to include this new function.
            let funTyp = resolvedType.unwrapFunctionType()
            let scopeWhereItAlreadyExists = symbols.lookupScopeEnclosingType(identifier: funTyp.name!)
            if scopeWhereItAlreadyExists === symbols || scopeWhereItAlreadyExists == nil {
                
                symbols.bind(
                    identifier: funTyp.name!,
                    symbol: Symbol(type: .function(funTyp)))
            }
            
            return resolvedType
            
        case .genericStructType(let typ):
            return try apply(genericTypeApplication: expr, genericStructType: typ)
            
        case .genericTraitType(let typ):
            return try apply(genericTypeApplication: expr, genericTraitType: typ)
            
        default:
            throw unsupportedError(expression: expr)
        }
    }
    
    fileprivate func apply(genericTypeApplication expr: Expression.GenericTypeApplication,
                           genericFunctionType: Expression.GenericFunctionType) throws -> SymbolType {
        
        guard expr.arguments.count == genericFunctionType.typeArguments.count else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "incorrect number of type arguments in application of generic function type `\(expr.shortDescription)'")
        }
        
        // TODO: check type constraints on the type variables here too
        // TODO: instantiation of the body of generic functions should not happen here at all
        
        let template0 = genericFunctionType.template
        let template1 = template0.clone()
        let template2 = template1.withTypeArguments([])
        
        // Bind types in a new symbol table to apply the type arguments.
        let symbolsWithTypeArguments = template2.symbols
        var evaluatedTypeArguments: [SymbolType] = []
        var replacementMap: [String : Expression] = [:]
        for i in 0..<expr.arguments.count {
            let typeVariable = genericFunctionType.typeArguments[i]
            let typeArgument = try check(expression: expr.arguments[i])
            symbolsWithTypeArguments.bind(identifier: typeVariable.identifier, symbolType: typeArgument)
            evaluatedTypeArguments.append(typeArgument)
            replacementMap[typeVariable.identifier] = Expression.PrimitiveType(typeArgument)
        }
        let inner = RvalueExpressionTypeChecker(symbols: symbolsWithTypeArguments)
        
        // Evaluate the function type template using the above symbols to get
        // the concrete function type result.
        let returnType = try inner.check(expression: genericFunctionType.returnType)
        let arguments = try inner.evaluateFunctionArguments(genericFunctionType.arguments)
        let mangledName = inner.mangleFunctionName(genericFunctionType.name, evaluatedTypeArguments: evaluatedTypeArguments)!
        let template3 = template2.withIdentifier(mangledName)
        let functionType = FunctionType(name: mangledName,
                                        mangledName: mangledName,
                                        returnType: returnType,
                                        arguments: arguments,
                                        ast: template3)
        
        try SnapSubcompilerFunctionDeclaration()
            .instantiate(memoryLayoutStrategy: globalEnvironment.memoryLayoutStrategy,
                         functionType: functionType,
                         functionDeclaration: template3)
        
        let ast0 = functionType.ast!
        let ast1 = try GenericsPartialEvaluator(symbols: nil, map: replacementMap).visit(func: ast0) as! FunctionDeclaration
        functionType.ast = ast1
        
        return .function(functionType)
    }
    
    fileprivate func apply(genericTypeApplication expr: Expression.GenericTypeApplication,
                           genericStructType: GenericStructType) throws -> SymbolType {
        guard expr.arguments.count == genericStructType.typeArguments.count else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "incorrect number of type arguments in application of generic struct type `\(expr.shortDescription)'")
        }
        
        // TODO: check type constraints on the type variables here too
        
        // Bind types in a new symbol table to apply the type arguments.
        let symbolsWithTypeArguments = SymbolTable(parent: symbols)
        var evaluatedTypeArguments: [SymbolType] = []
        for i in 0..<expr.arguments.count {
            let typeVariable = genericStructType.typeArguments[i]
            let typeArgument = try check(expression: expr.arguments[i])
            symbolsWithTypeArguments.bind(identifier: typeVariable.identifier, symbolType: typeArgument)
            evaluatedTypeArguments.append(typeArgument)
        }
        
        if let memoizedResult = genericStructType.instantiations[evaluatedTypeArguments] {
            return memoizedResult
        }
        
        // Bind the concrete struct type
        let subcompiler = SnapSubcompilerStructDeclaration(symbols: symbolsWithTypeArguments,
                                                           globalEnvironment: globalEnvironment)
        let template = genericStructType.template.eraseTypeArguments()
        let concreteType = try subcompiler.compile(template, evaluatedTypeArguments)
        genericStructType.instantiations[evaluatedTypeArguments] = concreteType // memoize
        
        // Apply the deferred impl nodes now.
        for implNode in genericStructType.implNodes.map({ $0.eraseTypeArguments() }) {
            try ImplScanner(
                globalEnvironment: globalEnvironment,
                symbols: symbolsWithTypeArguments)
            .scan(impl: implNode.clone())
        }
        
        // Apply the deferred impl-for nodes now.
        for node0 in genericStructType.implForNodes {
            let node1 = node0.eraseTypeArguments().clone()
            try ImplForScanner(
                globalEnvironment: globalEnvironment,
                symbols: symbolsWithTypeArguments)
            .scan(implFor: node1)
        }
        
        try exportSymbols(typeArguments: genericStructType.template.typeArguments,
                          symbolsWithTypeArguments: symbolsWithTypeArguments,
                          expr: expr)
        
        return concreteType
    }
    
    fileprivate func apply(genericTypeApplication expr: Expression.GenericTypeApplication,
                           genericTraitType: GenericTraitType) throws -> SymbolType {
        guard expr.arguments.count == genericTraitType.typeArguments.count else {
            throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "incorrect number of type arguments in application of generic trait type `\(expr.shortDescription)'")
        }
        
        // TODO: check type constraints on the type variables here too
        
        // Bind types in a new symbol table to apply the type arguments.
        let symbolsWithTypeArguments = SymbolTable(parent: symbols)
        var evaluatedTypeArguments: [SymbolType] = []
        for i in 0..<expr.arguments.count {
            let typeVariable = genericTraitType.typeArguments[i]
            let typeArgument = try check(expression: expr.arguments[i])
            symbolsWithTypeArguments.bind(identifier: typeVariable.identifier.identifier, symbolType: typeArgument)
            evaluatedTypeArguments.append(typeArgument)
        }
        
        if let memoizedResult = genericTraitType.instantiations[evaluatedTypeArguments] {
            return memoizedResult
        }
        
        // Bind the concrete trait type
        let concreteType = try instantiate(
            genericTraitType,
            evaluatedTypeArguments,
            symbolsWithTypeArguments)
        genericTraitType.instantiations[evaluatedTypeArguments] = concreteType // memoize
        
        try exportSymbols(typeArguments: genericTraitType.typeArguments,
                          symbolsWithTypeArguments: symbolsWithTypeArguments,
                          expr: expr)
        
        return concreteType
    }
    
    fileprivate func instantiate(
        _ genericTraitType: GenericTraitType,
        _ evaluatedTypeArguments: [SymbolType],
        _ symbols: SymbolTable) throws -> SymbolType {
        
        let node0 = genericTraitType.template.eraseTypeArguments()
        
        // TODO: We need an overhaul of name mangling in general. Name mangling functions should be moved to a new object such as a struct `NameMangler` or something like that. Also, the mangling scheme should be changed so there is no possibility of name collisions with identifiers written by the programmer.
        let mangledName = TypeContextTypeChecker(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .mangleTraitName(
            node0.name,
            evaluatedTypeArguments: evaluatedTypeArguments)!
        let node1 = node0.withMangledName(mangledName)
        
        let result = try declareTraitType(node1, evaluatedTypeArguments,
                                          genericTraitType, symbols)
        try declareVtableType(node1, symbols)
        try declareTraitObjectType(node1, symbols)
        try declareTraitObjectThunks(node1, symbols)
        
        return result
    }
    
    private func declareTraitType(
        _ traitDecl: TraitDeclaration,
        _ evaluatedTypeArguments: [SymbolType] = [],
        _ genericTraitType: GenericTraitType? = nil,
        _ symbols: SymbolTable) throws -> SymbolType {
        
        let mangledName = traitDecl.mangledName
        let members = SymbolTable(parent: symbols)
        let typeChecker = TypeContextTypeChecker(symbols: members, globalEnvironment: globalEnvironment)
        let fullyQualifiedTraitType = TraitType(
            name: mangledName,
            nameOfTraitObjectType: traitDecl.nameOfTraitObjectType,
            nameOfVtableType: traitDecl.nameOfVtableType,
            symbols: members)
        let result = SymbolType.traitType(fullyQualifiedTraitType)
        symbols.bind(identifier: mangledName,
                     symbolType: result,
                     visibility: traitDecl.visibility)
        
        if let genericTraitType {
            genericTraitType.instantiations[evaluatedTypeArguments] = result // memoize
        }
            
        members.enclosingFunctionNameMode = .set(mangledName)
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        for memberDeclaration in traitDecl.members {
            let memberType = try typeChecker.check(expression: memberDeclaration.memberType)
            let sizeOfMemberType = globalEnvironment
                .memoryLayoutStrategy
                .sizeof(type: memberType)
            let offset = frame.allocate(size: sizeOfMemberType)
            let symbol = Symbol(type: memberType, offset: offset, storage: .automaticStorage)
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            frame.add(identifier: memberDeclaration.name, symbol: symbol)
        }
        members.parent = nil
        
        return result
    }
    
    private func declareVtableType(
        _ traitDecl: TraitDeclaration,
        _ symbols: SymbolTable) throws {
        
        let traitName = traitDecl.identifier.identifier
        let members: [StructDeclaration.Member] = traitDecl.members.map {
            let memberType = TraitObjectDeclarationsBuilder()
                .rewriteTraitMemberTypeForVtable(traitName, $0.memberType)
            let member = StructDeclaration.Member(name: $0.name, type: memberType)
            return member
        }
        let structDecl = StructDeclaration(sourceAnchor: traitDecl.sourceAnchor,
                                           identifier: Expression.Identifier(traitDecl.nameOfVtableType),
                                           members: members,
                                           visibility: traitDecl.visibility,
                                           isConst: true)
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment).compile(structDecl)
    }
    
    private func declareTraitObjectType(
        _ traitDecl: TraitDeclaration,
        _ symbols: SymbolTable) throws {
        
        let members: [StructDeclaration.Member] = [
            StructDeclaration.Member(name: "object", type: Expression.PointerType(Expression.PrimitiveType(.void))),
            StructDeclaration.Member(name: "vtable", type: Expression.PointerType(Expression.ConstType(Expression.Identifier(traitDecl.nameOfVtableType))))
        ]
        let structDecl = StructDeclaration(
            sourceAnchor: traitDecl.sourceAnchor,
            identifier: Expression.Identifier(traitDecl.nameOfTraitObjectType),
            members: members,
            visibility: traitDecl.visibility,
            isConst: false) // TODO: Should isConst be true here?
        _ = try SnapSubcompilerStructDeclaration(
            symbols: symbols,
            globalEnvironment: globalEnvironment)
        .compile(structDecl)
    }
    
    private func declareTraitObjectThunks(
        _ traitDecl: TraitDeclaration,
        _ symbols: SymbolTable) throws {
        
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = TraitObjectDeclarationsBuilder()
                .rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map {
                ($0 == 0) ? "self" : "arg\($0)"
            }
            let callee = Expression.Get(expr: Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("vtable")), member: Expression.Identifier(method.name))
            let arguments = [Expression.Get(expr: Expression.Identifier("self"), member: Expression.Identifier("object"))] + argumentNames[1...].map({Expression.Identifier($0)})
            
            let outer = SymbolTable(
                parent: symbols,
                frameLookupMode: .set(Frame(growthDirection: .down)))
            
            let fnBody: Block
            let returnType = try TypeContextTypeChecker(symbols: symbols).check(expression: functionType.returnType)
            if returnType == .void {
                fnBody = Block(symbols: SymbolTable(parent: outer),
                               children: [Expression.Call(callee: callee, arguments: arguments)])
            } else {
                fnBody = Block(symbols: SymbolTable(parent: outer),
                               children: [Return(Expression.Call(callee: callee, arguments: arguments))])
            }
            
            let fnDecl = FunctionDeclaration(
                identifier: Expression.Identifier(method.name),
                functionType: functionType,
                argumentNames: argumentNames,
                body: fnBody,
                symbols: outer)
            thunks.append(fnDecl)
        }
        let implBlock = Impl(
            sourceAnchor: traitDecl.sourceAnchor,
            typeArguments: [], // TODO: Generic traits
            structTypeExpr: Expression.Identifier(traitDecl.nameOfTraitObjectType),
            children: thunks)
        try ImplScanner(
            globalEnvironment: globalEnvironment,
            symbols: symbols)
        .scan(impl: implBlock)
    }
    
    fileprivate func exportSymbols(
        typeArguments: [Expression.GenericTypeArgument],
        symbolsWithTypeArguments: SymbolTable,
        expr: Expression.GenericTypeApplication) throws {
        
        // Collect the new types and symbols that were bound above in
        // `symbolsWithTypeArguments' and move them to `symbols'.
        // Not the type variables, though, avoid those.
        for typeVariable in typeArguments {
            let identifier = typeVariable.identifier.identifier
            symbolsWithTypeArguments.typeTable.removeValue(forKey: identifier)
        }
        
        for typeName in symbolsWithTypeArguments.typeTable.keys {
            let typeRecord = symbolsWithTypeArguments.typeTable[typeName]!
            let symbolType = typeRecord.symbolType
            guard !symbols.exists(identifier: typeName) else {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "generic type application redefines existing symbol: `\(typeName)'")
            }
            symbols.bind(identifier: typeName, symbolType: symbolType)
        }
        
        for symbolName in symbolsWithTypeArguments.symbolTable.keys {
            let symbol = symbolsWithTypeArguments.symbolTable[symbolName]!
            guard !symbols.exists(identifier: symbolName) else {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "generic type application redefines existing symbol: `\(symbolName)'")
            }
            guard !symbols.existsAsType(identifier: symbolName) else {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "generic type application redefines existing type: `\(symbolName)'")
            }
            symbols.bind(identifier: symbolName, symbol: symbol)
        }
    }
    
    public func check(pointerType expr: Expression.PointerType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return .pointer(typ)
    }
    
    public func check(constType expr: Expression.ConstType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return typ.correspondingConstType
    }
    
    public func check(mutableType expr: Expression.MutableType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return typ.correspondingMutableType
    }
    
    public func check(structInitializer expr: Expression.StructInitializer) throws -> SymbolType {
        let result = try check(expression: expr.expr)
        let typ = result.unwrapStructType()
        var membersAlreadyInitialized: [String] = []
        for arg in expr.arguments {
            guard typ.symbols.exists(identifier: arg.name) else {
                throw CompilerError(sourceAnchor: expr.sourceAnchor, message: "value of type `\(expr.expr)' has no member `\(arg.name)'")
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
        return .array(count: expr.value.count, elementType: .u8)
    }
    
    public func check(typeOf expr: Expression.TypeOf) throws -> SymbolType {
        let type0 = try rvalueContext().check(expression: expr.expr)
        
        let type1: SymbolType = switch type0 {
        case .arithmeticType(.compTimeInt(let constantValue)):
            .arithmeticType(.mutableInt(
                IntClass.smallestClassContaining(value: constantValue)!))
        case .booleanType(.compTimeBool):
            .bool
        default:
            type0
        }
        
        return type1
    }
    
    public func check(bitcast expr: Expression.Bitcast) throws -> SymbolType {
        return try rvalueContext().check(expression: expr.targetType)
    }
    
    public func check(sizeOf expr: Expression.SizeOf) throws -> SymbolType {
        return .arithmeticType(.immutableInt(.u16)) // TODO: should the runtime provide a `usize' typealias for this?
    }
    
    public func check(eseq: Expression.Eseq) throws -> SymbolType {
        guard let expr = eseq.children.last else {
            return .void
        }
        return try check(expression: expr)
    }
    
    func unsupportedError(expression: Expression) -> Error {
        CompilerError(
            sourceAnchor: expression.sourceAnchor,
            message: "unsupported expression: \(expression)")
    }
    
    private func doesStructConformToVtable(
        _ structType: StructType,
        _ traitType: TraitType) -> Bool {
        
        try! symbols
            .resolveType(identifier: traitType.nameOfVtableType)
            .unwrapStructType()
            .symbols
            .symbolTable
            .allSatisfy { name, traitSymbol in
                let structSymbol = structType.symbols.symbolTable[name]
                guard let structSymbol else { return false }
                let conforms = areTypesConvertible(ltype: traitSymbol.type,
                                                   rtype: structSymbol.type)
                return conforms
            }
    }
}
