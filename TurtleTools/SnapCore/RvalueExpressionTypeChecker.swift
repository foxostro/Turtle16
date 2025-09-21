//
//  RvalueExpressionTypeChecker.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/5/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

/// There are no options today. This is in place for future expansion.
/// Yeah, yeah, YAGNI, but this was useful once and will be useful again.
/// For example, this is a place where a compiler pass could specify that the
/// type checker should throw an error on even encountering a certain type of
/// kind of type in that pass.
public struct TypeCheckerOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

/// Given an expression, determines the result type.
/// Throws a compiler error when the result type cannot be determined, e.g., due
/// to a type error in the expression.
public class RvalueExpressionTypeChecker {
    let symbols: Env
    private let staticStorageFrame: Frame
    private let memoryLayoutStrategy: MemoryLayoutStrategy
    private let options: TypeCheckerOptions

    public convenience init(_ symbols: Env) {
        self.init(symbols: symbols)
    }

    public init(
        symbols: Env = Env(),
        staticStorageFrame: Frame = Frame(),
        memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyNull(),
        options: TypeCheckerOptions = []
    ) {
        self.symbols = symbols
        self.staticStorageFrame = staticStorageFrame
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.options = options
    }

    func rvalueContext() -> RvalueExpressionTypeChecker {
        RvalueExpressionTypeChecker(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy,
            options: options
        )
    }

    func lvalueContext() -> LvalueExpressionTypeChecker {
        LvalueExpressionTypeChecker(
            symbols: symbols,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy,
            options: options
        )
    }

    @discardableResult public func check(expression: Expression) throws -> SymbolType {
        switch expression {
        case let expr as LiteralInt:
            return check(literalInt: expr)
        case let expr as LiteralBool:
            return .booleanType(.compTimeBool(expr.value))
        case let expr as Group:
            return try check(expression: expr.expression)
        case let expr as Unary:
            return try check(unary: expr)
        case let expr as Binary:
            return try check(binary: expr)
        case let identifier as Identifier:
            return try check(identifier: identifier)
        case let assig as Assignment:
            return try check(assignment: assig)
        case let call as Call:
            return try check(call: call)
        case let expr as As:
            return try check(as: expr)
        case let expr as Is:
            return try check(is: expr)
        case let expr as Subscript:
            return try check(subscript: expr)
        case let expr as LiteralArray:
            return try check(literalArray: expr)
        case let expr as Get:
            return try check(get: expr)
        case let expr as PrimitiveType:
            return try check(primitiveType: expr)
        case let expr as ArrayType:
            return try check(arrayType: expr)
        case let expr as DynamicArrayType:
            return try check(dynamicArrayType: expr)
        case let expr as FunctionType:
            return try check(functionType: expr)
        case let expr as GenericFunctionType:
            return try check(genericFunctionType: expr)
        case let expr as GenericTypeApplication:
            return try check(genericTypeApplication: expr)
        case let expr as PointerType:
            return try check(pointerType: expr)
        case let expr as ConstType:
            return try check(constType: expr)
        case let expr as MutableType:
            return try check(mutableType: expr)
        case let expr as StructInitializer:
            return try check(structInitializer: expr)
        case let expr as UnionType:
            return try check(unionType: expr)
        case let expr as LiteralString:
            return try check(literalString: expr)
        case let expr as TypeOf:
            return try check(typeOf: expr)
        case let expr as Bitcast:
            return try check(bitcast: expr)
        case let expr as SizeOf:
            return try check(sizeOf: expr)
        case let expr as Eseq:
            return try check(eseq: expr)
        default:
            throw unsupportedError(expression: expression)
        }
    }

    public func check(literalInt expr: LiteralInt) -> SymbolType {
        .arithmeticType(.compTimeInt(expr.value))
    }

    public func check(unary: Unary) throws -> SymbolType {
        let expressionType = try check(expression: unary.child)
        switch unary.op {
        case .minus:
            switch expressionType {
            case let .arithmeticType(arithmeticType):
                switch arithmeticType {
                case let .compTimeInt(value):
                    return .arithmeticType(.compTimeInt(-value))
                default:
                    return expressionType
                }
            default:
                throw CompilerError(
                    sourceAnchor: unary.sourceAnchor,
                    message: "Unary operator `\(unary.op)' cannot be applied to an operand of type `\(expressionType)'"
                )
            }
        case .ampersand:
            guard let lvalueType = try lvalueContext().check(expression: unary.child) else {
                throw CompilerError(
                    sourceAnchor: unary.child.sourceAnchor,
                    message: "lvalue required as operand of unary operator `\(unary.op)'"
                )
            }
            guard case let .function(typ) = lvalueType else {
                return .pointer(lvalueType)
            }
            return .pointer(.function(typ.eraseName()))
        case .tilde:
            switch expressionType {
            case let .arithmeticType(arithmeticType):
                switch arithmeticType {
                case let .compTimeInt(value):
                    return .arithmeticType(.compTimeInt(~value))
                default:
                    return expressionType
                }
            default:
                throw CompilerError(
                    sourceAnchor: unary.sourceAnchor,
                    message: "Unary operator `\(unary.op)' cannot be applied to an operand of type `\(expressionType)'"
                )
            }
        case .bang:
            switch expressionType {
            case let .booleanType(boolTyp):
                switch boolTyp {
                case let .compTimeBool(value):
                    return .booleanType(.compTimeBool(!value))
                default:
                    return expressionType
                }
            default:
                throw CompilerError(
                    sourceAnchor: unary.sourceAnchor,
                    message: "Unary operator `\(unary.op)' cannot be applied to an operand of type `\(expressionType)'"
                )
            }
        default:
            let operatorString: String =
                if let lexeme = unary.sourceAnchor?.text {
                    String(lexeme)
                }
                else {
                    fallbackStringForOperator(unary.op)
                }
            throw CompilerError(
                sourceAnchor: unary.sourceAnchor,
                message: "`\(operatorString)' is not a prefix unary operator"
            )
        }
    }

    private func fallbackStringForOperator(_ op: TokenOperator.Operator) -> String {
        switch op {
        case .eq: "=="
        case .ne: "!="
        case .lt: "<"
        case .gt: ">"
        case .le: "<="
        case .ge: ">="
        case .plus: "+"
        case .minus: "-"
        case .star: "*"
        case .divide: "/"
        case .modulus: "%"
        case .ampersand: "&"
        case .doubleAmpersand: "&&"
        case .pipe: "|"
        case .doublePipe: "||"
        case .bang: "!"
        case .caret: "^"
        case .leftDoubleAngle: "<<"
        case .rightDoubleAngle: ">>"
        case .tilde: "~"
        }
    }

    private func check(binary: Binary) throws -> SymbolType {
        let rightType = try check(expression: binary.right)
        let leftType = try check(expression: binary.left)

        if leftType.isArithmeticType, rightType.isArithmeticType {
            return try checkArithmeticBinaryExpression(binary, leftType, rightType)
        }

        if leftType.isBooleanType, rightType.isBooleanType {
            return try checkBooleanBinaryExpression(binary, leftType, rightType)
        }

        throw invalidBinaryExpr(binary, leftType, rightType)
    }

    private func checkBooleanBinaryExpression(
        _ binary: Binary,
        _ leftType: SymbolType,
        _ rightType: SymbolType
    ) throws -> SymbolType {
        guard leftType.isBooleanType, rightType.isBooleanType else {
            assertionFailure()
            abort()
        }

        if case .booleanType(.compTimeBool) = leftType, case .booleanType(.compTimeBool) = rightType
        {
            return try checkConstantBooleanBinaryExpression(binary, leftType, rightType)
        }

        _ = try checkTypesAreConvertibleInAssignment(
            ltype: .bool,
            rtype: leftType,
            sourceAnchor: binary.left.sourceAnchor,
            messageWhenNotConvertible: "cannot convert value of type `\(leftType)' to type `bool'"
        )

        _ = try checkTypesAreConvertibleInAssignment(
            ltype: .bool,
            rtype: rightType,
            sourceAnchor: binary.right.sourceAnchor,
            messageWhenNotConvertible: "cannot convert value of type `\(rightType)' to type `bool'"
        )

        switch binary.op {
        case .eq,
             .ne,
             .doubleAmpersand,
             .doublePipe:
            return .bool
        default:
            throw invalidBinaryExpr(binary, leftType, rightType)
        }
    }

    private func checkConstantBooleanBinaryExpression(
        _ binary: Binary,
        _ leftType: SymbolType,
        _ rightType: SymbolType
    ) throws -> SymbolType {
        guard case let .booleanType(.compTimeBool(a)) = leftType,
              case let .booleanType(.compTimeBool(b)) = rightType
        else {
            assertionFailure()
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

    private func checkArithmeticBinaryExpression(
        _ binary: Binary,
        _ leftType: SymbolType,
        _ rightType: SymbolType
    ) throws -> SymbolType {
        switch (leftType, rightType) {
        case (.arithmeticType(.compTimeInt), .arithmeticType(.compTimeInt)):
            return try checkConstantArithmeticBinaryExpression(binary, leftType, rightType)

        case let (.arithmeticType(leftArithmeticType), .arithmeticType(rightArithmeticType)):
            guard
                let arithmeticTypeForArithmetic = ArithmeticTypeInfo.binaryResultType(
                    left: leftArithmeticType,
                    right: rightArithmeticType
                )
            else {
                throw invalidBinaryExpr(binary, leftType, rightType)
            }

            let typeForArithmetic: SymbolType = .arithmeticType(arithmeticTypeForArithmetic)

            _ = try checkTypesAreConvertibleInAssignment(
                ltype: typeForArithmetic,
                rtype: rightType,
                sourceAnchor: binary.right.sourceAnchor,
                messageWhenNotConvertible: "cannot convert value of type `\(rightType)' to type `\(typeForArithmetic)'"
            )

            _ = try checkTypesAreConvertibleInAssignment(
                ltype: typeForArithmetic,
                rtype: leftType,
                sourceAnchor: binary.left.sourceAnchor,
                messageWhenNotConvertible: "cannot convert value of type `\(leftType)' to type `\(typeForArithmetic)'"
            )

            switch binary.op {
            case .eq,
                 .ne,
                 .lt,
                 .gt,
                 .le,
                 .ge:
                return .bool
            case .plus,
                 .minus,
                 .star,
                 .divide,
                 .modulus,
                 .ampersand,
                 .pipe,
                 .caret,
                 .leftDoubleAngle,
                 .rightDoubleAngle:
                return typeForArithmetic
            default:
                throw invalidBinaryExpr(binary, leftType, rightType)
            }

        default:
            assertionFailure()
            abort()
        }
    }

    private func checkConstantArithmeticBinaryExpression(
        _ binary: Binary,
        _ leftType: SymbolType,
        _ rightType: SymbolType
    ) throws -> SymbolType {
        guard case let .arithmeticType(.compTimeInt(a)) = leftType,
              case let .arithmeticType(.compTimeInt(b)) = rightType
        else {
            assertionFailure()
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

    private func invalidBinaryExpr(
        _ binary: Binary,
        _ left: SymbolType,
        _ right: SymbolType
    ) -> CompilerError {
        guard left == right else {
            return CompilerError(
                sourceAnchor: binary.sourceAnchor,
                message: "binary operator `\(binary.op)' cannot be applied to operands of types `\(left)' and `\(right)'"
            )
        }
        return CompilerError(
            sourceAnchor: binary.sourceAnchor,
            message: "binary operator `\(binary.op)' cannot be applied to two `\(right)' operands"
        )
    }

    public func check(assignment: Assignment) throws -> SymbolType {
        let ltype = try lvalueContext().check(expression: assignment.lexpr)
        guard let ltype else {
            throw CompilerError(
                sourceAnchor: assignment.lexpr.sourceAnchor,
                message: "lvalue required in assignment"
            )
        }

        // Guard against inappropriate assignment to an initialized const var
        guard isAssignmentToConstAcceptable(assignment, ltype) else {
            let message =
                if let ident = (assignment.lexpr as? Identifier)?.identifier {
                    "cannot assign to constant `\(ident)' of type `\(ltype)'"
                }
                else {
                    "cannot assign to expression of type `\(ltype)'"
                }
            throw CompilerError(
                sourceAnchor: assignment.lexpr.sourceAnchor,
                message: message
            )
        }

        let rtype = try rvalueContext().check(expression: assignment.rexpr)
        return try checkTypesAreConvertibleInAssignment(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: assignment.rexpr.sourceAnchor,
            messageWhenNotConvertible: "cannot assign value of type `\(rtype)' to type `\(ltype)'"
        )
    }

    /// An assignment to a const 'let' variable is acceptable when the variable
    /// is known to be uninitialized.
    private func isAssignmentToConstAcceptable(
        _ assignment: Assignment,
        _ ltype: SymbolType
    ) -> Bool {
        guard ltype.isConst else { return true }

        guard let ident = assignment.lexpr as? Identifier,
              let symbol = symbols.maybeResolve(identifier: ident.identifier),
              symbol.facts.initStatus == .uninitialized
        else {
            return false
        }

        return true
    }

    public enum TypeConversionStatus {
        case acceptable(SymbolType)
        case unacceptable(CompilerError)
    }

    public func convertBetweenTypes(
        ltype: SymbolType,
        rtype: SymbolType,
        sourceAnchor: SourceAnchor?,
        messageWhenNotConvertible: String,
        isExplicitCast: Bool
    ) -> TypeConversionStatus {
        // Integer constants will be automatically converted to appropriate
        // concrete integer types.
        //
        // Small integer types will be automatically promoted to larger types.

        // Do not allow function types to be converted at all.
        if ltype.isFunctionType || rtype.isFunctionType {
            return .unacceptable(
                CompilerError(
                    sourceAnchor: sourceAnchor,
                    message: "inappropriate use of a function type (Try taking the function's address instead.)"
                )
            )
        }

        // If the types match exactly then the conversion is acceptable.
        if rtype == ltype, rtype != .void {
            return .acceptable(ltype)
        }

        switch (rtype, ltype) {
        case let (.arithmeticType(a), .arithmeticType(b)):
            switch (a, b) {
            case let (.compTimeInt(constantValue), .mutableInt(intClassDst)),
                 let (.compTimeInt(constantValue), .immutableInt(intClassDst)):
                guard constantValue >= intClassDst.min, constantValue <= intClassDst.max else {
                    return .unacceptable(
                        CompilerError(
                            sourceAnchor: sourceAnchor,
                            message: "integer constant `\(constantValue)' overflows when stored into `\(ltype)'"
                        )
                    )
                }
                return .acceptable(ltype) // The conversion is acceptable.
            default:
                if let intClassA = a.intClass, let intClassB = b.intClass {
                    if (intClassB.min <= intClassA.min && intClassB.max >= intClassA.max)
                        || isExplicitCast {
                        return .acceptable(ltype) // The conversion is acceptable.
                    }
                }
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
        case let (.booleanType(a), .booleanType(b)):
            switch (a, b) {
            case (.compTimeBool, .immutableBool),
                 (.compTimeBool, .mutableBool),
                 (.immutableBool, .immutableBool),
                 (.immutableBool, .mutableBool),
                 (.mutableBool, .immutableBool),
                 (.mutableBool, .mutableBool):
                return .acceptable(ltype) // The conversion is acceptable.

            default:
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
        case let (.array(n, a), .array(m, b)):
            guard n == m || m == nil else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
            switch convertBetweenTypes(
                ltype: b,
                rtype: a,
                sourceAnchor: sourceAnchor,
                messageWhenNotConvertible: messageWhenNotConvertible,
                isExplicitCast: isExplicitCast
            ) {
            case let .acceptable(elementType):
                return .acceptable(.array(count: n, elementType: elementType))
            case let .unacceptable(err):
                return .unacceptable(err)
            }
        case let (.array(n, a), .constDynamicArray(elementType: b)),
             let (.array(n, a), .dynamicArray(elementType: b)):
            guard n != nil else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
            switch convertBetweenTypes(
                ltype: b,
                rtype: a,
                sourceAnchor:
                sourceAnchor,
                messageWhenNotConvertible: messageWhenNotConvertible,
                isExplicitCast: isExplicitCast
            ) {
            case .acceptable:
                return .acceptable(ltype)
            case let .unacceptable(err):
                return .unacceptable(err)
            }
        case let (.constDynamicArray(a), .constDynamicArray(b)),
             let (.constDynamicArray(a), .dynamicArray(b)),
             let (.dynamicArray(a), .constDynamicArray(b)),
             let (.dynamicArray(a), .dynamicArray(b)):
            guard a == b || a.correspondingConstType == b else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
            return .acceptable(.dynamicArray(elementType: b))
        case let (.constStructType(a), .constStructType(b)),
             let (.constStructType(a), .structType(b)),
             let (.structType(a), .constStructType(b)),
             let (.structType(a), .structType(b)):
            guard a == b else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
            return .acceptable(ltype)
        case let (.constPointer(a), .constPointer(b)),
             let (.constPointer(a), .pointer(b)),
             let (.pointer(a), .constPointer(b)),
             let (.pointer(a), .pointer(b)):
            guard a == b || a.correspondingConstType == b else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
            return .acceptable(ltype)
        case let (.unionType(a), .unionType(b)):
            if b == a.correspondingConstType {
                return .acceptable(ltype)
            }
            else if b.correspondingConstType == a {
                return .acceptable(ltype)
            }
            else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
        case let (.unionType(typ), _):
            if !isExplicitCast {
                return .unacceptable(
                    CompilerError(
                        sourceAnchor: sourceAnchor,
                        message: "cannot implicitly convert a union type `\(rtype)' to `\(ltype)'; use an explicit conversion instead"
                    )
                )
            }
            for member in typ.members {
                let status = convertBetweenTypes(
                    ltype: ltype,
                    rtype: member,
                    sourceAnchor: sourceAnchor,
                    messageWhenNotConvertible: messageWhenNotConvertible,
                    isExplicitCast: isExplicitCast
                )
                switch status {
                case let .acceptable(symbolType):
                    return .acceptable(symbolType)
                case .unacceptable:
                    break // just move on to the next one
                }
            }
            return .unacceptable(
                CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            )
        case let (_, .unionType(typ)):
            for member in typ.members {
                let status = convertBetweenTypes(
                    ltype: member,
                    rtype: rtype,
                    sourceAnchor: sourceAnchor,
                    messageWhenNotConvertible: messageWhenNotConvertible,
                    isExplicitCast: isExplicitCast
                )
                switch status {
                case .acceptable:
                    return .acceptable(ltype)
                default:
                    break // just move on to the next one
                }
            }
            return .unacceptable(
                CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            )
        case let (.constPointer(a), .traitType(b)),
             let (.pointer(a), .traitType(b)),
             let (.constPointer(a), .constTraitType(b)),
             let (.pointer(a), .constTraitType(b)):
            let traitType: TraitTypeInfo = b
            switch a {
            case let .constStructType(structType),
                 let .structType(structType):
                let conforms = doesStructConformToVtable(structType, traitType)
                if conforms {
                    return .acceptable(ltype)
                }

            default:
                break
            }
            return .unacceptable(
                CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            )
        case let (.constStructType(a), .traitType(b)),
             let (.structType(a), .traitType(b)),
             let (.constStructType(a), .constTraitType(b)),
             let (.structType(a), .constTraitType(b)):
            let nameOfVtableInstance = nameOfVtableInstance(
                traitName: b.name,
                structName: a.name
            )
            let vtableInstance = symbols.maybeResolve(identifier: nameOfVtableInstance)
            guard vtableInstance != nil else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
            return .acceptable(ltype)
        case let (.constTraitType(a), .traitType(b)),
             let (.traitType(a), .constTraitType(b)):
            guard a == b else {
                return .unacceptable(
                    CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
                )
            }
            return .acceptable(ltype)
        case let (_, .constPointer(b)),
             let (_, .pointer(b)):
            if rtype.correspondingConstType == b.correspondingConstType {
                return .acceptable(ltype)
            }
            else {
                switch rtype {
                case let .constTraitType(a),
                     let .traitType(a):
                    let traitObjectType = try? symbols.resolveType(
                        identifier: a.nameOfTraitObjectType
                    )
                    if traitObjectType == b {
                        return .acceptable(ltype)
                    }

                default:
                    break
                }
            }
            return .unacceptable(
                CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            )
        default:
            return .unacceptable(
                CompilerError(sourceAnchor: sourceAnchor, message: messageWhenNotConvertible)
            )
        }
    }

    private func areTypesConvertible(ltype: SymbolType, rtype: SymbolType) -> Bool {
        let status = convertBetweenTypes(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: nil,
            messageWhenNotConvertible: "",
            isExplicitCast: false
        )

        return switch status {
        case .acceptable: false
        case .unacceptable: true
        }
    }

    private func checkTypesAreConvertible(
        ltype: SymbolType,
        rtype: SymbolType,
        sourceAnchor: SourceAnchor?,
        messageWhenNotConvertible: String,
        isExplicitCast: Bool
    ) throws -> SymbolType {
        let status = convertBetweenTypes(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: sourceAnchor,
            messageWhenNotConvertible: messageWhenNotConvertible,
            isExplicitCast: isExplicitCast
        )
        switch status {
        case let .acceptable(symbolType):
            return symbolType
        case let .unacceptable(err):
            throw err
        }
    }

    /// Return true if it is acceptable to convert from rtype to ltype
    public func areTypesAreConvertible(
        ltype: SymbolType,
        rtype: SymbolType,
        isExplicitCast: Bool
    ) -> Bool {
        switch convertBetweenTypes(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: nil,
            messageWhenNotConvertible: "",
            isExplicitCast: isExplicitCast
        ) {
        case .acceptable: true
        case .unacceptable: false
        }
    }

    @discardableResult public func checkTypesAreConvertibleInAssignment(
        ltype: SymbolType,
        rtype: SymbolType,
        sourceAnchor: SourceAnchor?,
        messageWhenNotConvertible: String
    ) throws -> SymbolType {
        try checkTypesAreConvertible(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: sourceAnchor,
            messageWhenNotConvertible: messageWhenNotConvertible,
            isExplicitCast: false
        )
    }

    public func checkTypesAreConvertibleInExplicitCast(
        ltype: SymbolType,
        rtype: SymbolType,
        sourceAnchor: SourceAnchor?,
        messageWhenNotConvertible: String
    ) throws -> SymbolType {
        try checkTypesAreConvertible(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: sourceAnchor,
            messageWhenNotConvertible: messageWhenNotConvertible,
            isExplicitCast: true
        )
    }

    public func check(identifier expr: Identifier) throws -> SymbolType {
        let rvalueType = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.sourceAnchor,
            identifier: expr.identifier
        )

        switch rvalueType {
        case let .genericFunction(typ):
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "cannot instantiate generic function `\(typ)'"
            )

        case let .genericStructType(typ):
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "cannot instantiate generic struct `\(typ)'"
            )

        case let .genericTraitType(typ):
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "cannot instantiate generic trait `\(typ)'"
            )

        default:
            return rvalueType
        }
    }

    public func check(call: Call) throws -> SymbolType {
        let calleeType: SymbolType =
            if let identifier = call.callee as? Identifier {
                try symbols.resolveTypeOfIdentifier(
                    sourceAnchor: identifier.sourceAnchor,
                    identifier: identifier.identifier
                )
            }
            else {
                try check(expression: call.callee)
            }
        return try check(call: call, calleeType: calleeType)
    }

    private func check(call: Call, calleeType: SymbolType) throws -> SymbolType {
        switch calleeType {
        case let .genericFunction(typ):
            return try check(call: call, genericFunctionType: typ)
        case let .function(typ),
             let .pointer(.function(typ)),
             let .constPointer(.function(typ)):
            return try check(call: call, typ: typ)
        default:
            throw CompilerError(
                sourceAnchor: call.sourceAnchor,
                message: "cannot call value of non-function type `\(calleeType)'"
            )
        }
    }

    private func check(
        call expr: Call,
        genericFunctionType: GenericFunctionType
    ) throws -> SymbolType {
        let a = try synthesizeGenericTypeApplication(
            call: expr,
            genericFunctionType: genericFunctionType
        )
        let calleeType = try check(genericTypeApplication: a)
        return try check(call: expr, calleeType: calleeType)
    }

    public func synthesizeGenericTypeApplication(
        call expr: Call,
        genericFunctionType: GenericFunctionType
    ) throws -> GenericTypeApplication {
        guard let identifier = expr.callee as? Identifier else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "expected identifier, got `\(expr.callee)'"
            )
        }
        let typeArguments = try inferTypeArguments(
            call: expr,
            genericFunctionType: genericFunctionType
        )
        let a = GenericTypeApplication(
            sourceAnchor: expr.sourceAnchor,
            identifier: identifier,
            arguments: typeArguments
        )
        return a
    }

    private func inferTypeArguments(
        call expr: Call,
        genericFunctionType generic: GenericFunctionType
    ) throws -> [Expression] {
        let solver = GenericFunctionTypeArgumentSolver()
        let typeArguments = try solver.inferTypeArguments(
            call: expr,
            genericFunctionType: generic,
            symbols: symbols
        )
        return typeArguments.map {
            PrimitiveType($0)
        }
    }

    private func check(call: Call, typ: FunctionTypeInfo) throws -> SymbolType {
        do {
            return try checkInner(call: call, typ: typ)
        }
        catch let err as CompilerError {
            guard let rewritten = try rewriteStructMemberFunctionCallIfPossible(call) else {
                throw err
            }
            return try checkInner(call: rewritten, typ: typ)
        }
    }

    func checkInner(call: Call, typ: FunctionTypeInfo) throws -> SymbolType {
        if call.arguments.count != typ.arguments.count {
            let message =
                if let name = typ.name {
                    "incorrect number of arguments in call to `\(name)'"
                }
                else {
                    "incorrect number of arguments in call to function of type `\(typ)'"
                }
            throw CompilerError(sourceAnchor: call.sourceAnchor, message: message)
        }

        for i in 0..<typ.arguments.count {
            let rtype = try rvalueContext().check(expression: call.arguments[i])
            let ltype = typ.arguments[i]
            let message =
                if let name = typ.name {
                    "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to `\(name)'"
                }
                else {
                    "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in call to function of type `\(typ)'"
                }
            _ = try checkTypesAreConvertibleInAssignment(
                ltype: ltype,
                rtype: rtype,
                sourceAnchor: call.arguments[i].sourceAnchor,
                messageWhenNotConvertible: message
            )
        }

        return typ.returnType
    }

    private func rewriteStructMemberFunctionCallIfPossible(_ expr: Call) throws -> Call? {
        guard let match = try StructMemberFunctionCallMatcher(call: expr, typeChecker: self).match()
        else {
            return nil
        }

        return Call(
            sourceAnchor: match.callExpr.sourceAnchor,
            callee: Get(
                sourceAnchor: match.callExpr.sourceAnchor,
                expr: match.getExpr.expr,
                member: match.getExpr.member
            ),
            arguments: [match.getExpr.expr] + match.callExpr.arguments
        )
    }

    public func check(as expr: As) throws -> SymbolType {
        let ltype = try check(expression: expr.targetType)
        let rtype = try check(expression: expr.expr)
        return try checkTypesAreConvertibleInExplicitCast(
            ltype: ltype,
            rtype: rtype,
            sourceAnchor: expr.sourceAnchor,
            messageWhenNotConvertible: "cannot convert value of type `\(rtype)' to type `\(ltype)'"
        )
    }

    public func check(is expr: Is) throws -> SymbolType {
        let ltype = try check(expression: expr.expr)
        let rtype = try check(expression: expr.testType)
        switch ltype {
        case let .unionType(typ):
            guard typ.members.contains(rtype) || typ.members.contains(rtype.correspondingConstType)
            else {
                return .booleanType(.compTimeBool(false))
            }
            return .bool
        default:
            return .booleanType(
                .compTimeBool(
                    ltype == rtype || ltype.correspondingConstType == rtype
                        || ltype == rtype.correspondingConstType
                )
            )
        }
    }

    public func check(subscript expr: Subscript) throws -> SymbolType {
        let subscriptableType = try check(expression: expr.subscriptable)
        switch subscriptableType {
        case .array(count: _, let elementType),
             let .constDynamicArray(elementType),
             let .dynamicArray(elementType),
             .pointer(.array(count: _, let elementType)),
             let .pointer(.constDynamicArray(elementType)),
             let .pointer(.dynamicArray(elementType)),
             .constPointer(.array(count: _, let elementType)),
             let .constPointer(.constDynamicArray(elementType)),
             let .constPointer(.dynamicArray(elementType)):
            let argumentType = try rvalueContext().check(expression: expr.argument)
            let typeError = CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "cannot subscript a value of type `\(subscriptableType)' with an argument of type `\(argumentType)'"
            )
            switch argumentType {
            case let .structType(typ),
                 let .constStructType(typ):
                guard isRangeType(typ) else {
                    throw typeError
                }
                return .dynamicArray(elementType: elementType)
            default:
                break
            }
            if argumentType.isArithmeticType {
                return elementType
            }
            throw typeError

        case let .structType(typ),
             let .constStructType(typ):
            // TODO: The compiler treats Range specially but maybe it shouldn't. We could instead have a way to provide an overload of the subscript operator or some other solution in the standard library.
            guard typ.name == "Range" else {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "value of type `\(subscriptableType)' has no subscripts"
                )
            }
            return .u16

        default:
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "value of type `\(subscriptableType)' has no subscripts"
            )
        }
    }

    private func isRangeType(_ typ: StructTypeInfo) -> Bool {
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

    public func check(literalArray expr: LiteralArray) throws -> SymbolType {
        var arrayLiteralType = try check(expression: expr.arrayType)
        let arrayCount = arrayLiteralType.arrayCount
        let arrayElementType = arrayLiteralType.arrayElementType

        if let explicitCount = arrayCount {
            if expr.elements.count != explicitCount {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "expected \(explicitCount) elements in `\(arrayLiteralType)' array literal"
                )
            }
        }

        arrayLiteralType = .array(count: expr.elements.count, elementType: arrayElementType)

        for element in expr.elements {
            let ltype = arrayElementType
            let rtype = try check(expression: element)
            try checkTypesAreConvertibleInAssignment(
                ltype: ltype,
                rtype: rtype,
                sourceAnchor: element.sourceAnchor,
                messageWhenNotConvertible: "cannot convert value of type `\(rtype)' to type `\(ltype)' in `\(arrayLiteralType)' array literal"
            )
        }

        return arrayLiteralType
    }

    public func check(get expr: Get) throws -> SymbolType {
        if expr.member as? Identifier != nil {
            return try check(getIdent: expr)
        }
        else if expr.member as? GenericTypeApplication != nil {
            return try check(getApp: expr)
        }
        else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "unsupported get expression `\(expr)'"
            )
        }
    }

    private func check(getIdent expr: Get) throws -> SymbolType {
        let member = expr.member as! Identifier

        if let structInitializer = expr.expr as? StructInitializer {
            let argument = structInitializer.arguments.first(where: { $0.name == member.identifier }
            )
            guard let argument else {
                let a = try check(structInitializer: structInitializer)
                switch a {
                case let .structType(typ),
                     let .constStructType(typ):
                    // TODO: The compiler has special handling of Range.count but maybe it shouldn't. The compiler could provide a way to write a specialized Range.count property or something like that
                    if typ.name == "Range", member.identifier == "count" {
                        return .u16
                    }

                default:
                    break
                }

                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "value of type `\(a)' has no member `\(member.identifier)'"
                )
            }
            return try check(expression: argument.expr)
        }

        let name = member.identifier
        let objectType = try check(expression: expr.expr)
        switch objectType {
        case .array,
             .constDynamicArray,
             .dynamicArray:
            if name == "count" {
                return .u16
            }
        case let .constStructType(typ):
            // TODO: The compiler treats Range specially but maybe it shouldn't do this. We could have some way to provide a specific template specialization and do it in stdlib.
            if typ.name == "Range", name == "count" {
                return .u16
            }
            else if let symbol = typ.symbols.maybeResolve(identifier: name) {
                return symbol.type.correspondingConstType
            }
        case let .structType(typ):
            if typ.name == "Range", name == "count" {
                return .u16
            }
            else if let symbol = typ.symbols.maybeResolve(identifier: name) {
                return symbol.type
            }
        case let .constPointer(typ),
             let .pointer(typ):
            if name == "pointee" {
                return typ
            }
            else {
                switch typ {
                case .array,
                     .constDynamicArray,
                     .dynamicArray:
                    if name == "count" {
                        return .u16
                    }
                case let .constStructType(b):
                    if let symbol = b.symbols.maybeResolve(identifier: name) {
                        return symbol.type.correspondingConstType
                    }
                case let .structType(b):
                    if let symbol = b.symbols.maybeResolve(identifier: name) {
                        return symbol.type
                    }
                case let .traitType(b):
                    return try check(
                        get: Get(
                            sourceAnchor: expr.sourceAnchor,
                            expr: Identifier(b.nameOfTraitObjectType),
                            member: expr.member
                        )
                    )
                default:
                    break
                }
            }
        case let .constTraitType(typ),
             let .traitType(typ):
            return try check(
                get: Get(
                    sourceAnchor: expr.sourceAnchor,
                    expr: Identifier(typ.nameOfTraitObjectType),
                    member: expr.member
                )
            )
        default:
            break
        }
        throw CompilerError(
            sourceAnchor: expr.sourceAnchor,
            message: "value of type `\(objectType)' has no member `\(name)'"
        )
    }

    private func check(getApp expr: Get) throws -> SymbolType {
        let app = expr.member as! GenericTypeApplication

        let name = app.identifier.identifier
        let resultType = try check(expression: expr.expr)
        switch resultType {
        case let .constStructType(typ),
             let .structType(typ):
            let type = try check(genericTypeApplication: app, symbols: typ.symbols)
            return type
        case let .constPointer(typ),
             let .pointer(typ):
            switch typ {
            case let .constStructType(b),
                 let .structType(b):
                let type = try check(genericTypeApplication: app, symbols: b.symbols)
                return type
            default:
                break
            }
        default:
            break
        }
        throw CompilerError(
            sourceAnchor: expr.sourceAnchor,
            message: "value of type `\(resultType)' has no member `\(name)'"
        )
    }

    public func check(primitiveType expr: PrimitiveType) throws -> SymbolType {
        expr.typ
    }

    public func check(arrayType expr: ArrayType) throws -> SymbolType {
        let count: Int?
        if let exprCount = expr.count {
            let typeOfCountExpr = try check(expression: exprCount)
            switch typeOfCountExpr {
            case let .arithmeticType(.compTimeInt(a)):
                count = a
            default:
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "array count must be a compile time constant, got `\(typeOfCountExpr)' instead"
                )
            }
        }
        else {
            count = nil
        }
        let elementType = try check(expression: expr.elementType)
        return .array(count: count, elementType: elementType)
    }

    public func check(dynamicArrayType expr: DynamicArrayType) throws -> SymbolType {
        let elementType = try check(expression: expr.elementType)
        return .dynamicArray(elementType: elementType)
    }

    public func check(functionType expr: FunctionType) throws -> SymbolType {
        let returnType = try check(expression: expr.returnType)
        let arguments = try evaluateFunctionArguments(expr.arguments)
        let mangledName = mangleFunctionName(expr.name)

        return .function(
            FunctionTypeInfo(
                name: expr.name,
                mangledName: mangledName,
                returnType: returnType,
                arguments: arguments
            )
        )
    }

    public func mangleFunctionName(
        _ name: String?,
        evaluatedTypeArguments: [SymbolType] = []
    ) -> String? {
        NameMangler().mangleFunctionName(
            name,
            evaluatedTypeArguments: evaluatedTypeArguments,
            symbols: symbols
        )
    }

    public func mangleStructName(
        _ name: String?,
        evaluatedTypeArguments: [SymbolType] = []
    ) -> String? {
        NameMangler().mangleStructName(
            name,
            evaluatedTypeArguments: evaluatedTypeArguments,
            symbols: symbols
        )
    }

    public func mangleTraitName(
        _ name: String?,
        evaluatedTypeArguments: [SymbolType] = []
    ) -> String? {
        NameMangler().mangleTraitName(
            name,
            evaluatedTypeArguments: evaluatedTypeArguments,
            symbols: symbols
        )
    }

    private func evaluateFunctionArguments(
        _ argsToEvaluate: [Expression]
    ) throws -> [SymbolType] {
        try argsToEvaluate.map {
            try check(expression: $0)
        }
    }

    public func check(genericFunctionType expr: GenericFunctionType) throws -> SymbolType {
        throw CompilerError(
            sourceAnchor: expr.sourceAnchor,
            message: "cannot instantiate generic function `\(expr)'"
        )
    }

    public func check(genericTypeApplication expr: GenericTypeApplication) throws -> SymbolType {
        try check(genericTypeApplication: expr, symbols: symbols)
    }

    private func check(
        genericTypeApplication expr: GenericTypeApplication,
        symbols: Env
    ) throws -> SymbolType {
        let typeOfIdentifier = try symbols.resolveTypeOfIdentifier(
            sourceAnchor: expr.sourceAnchor,
            identifier: expr.identifier.identifier
        )

        switch typeOfIdentifier {
        case let .genericFunction(typ):
            let resolvedType = try apply(
                genericTypeApplication: expr,
                genericFunctionType: typ
            )

            // We must update the symbol table to include this new function.
            let funTyp = resolvedType.unwrapFunctionType()
            let scopeWhereItAlreadyExists = symbols.lookupScopeEnclosingType(
                identifier: funTyp.name!
            )
            if scopeWhereItAlreadyExists === symbols || scopeWhereItAlreadyExists == nil {
                symbols.bind(
                    identifier: funTyp.name!,
                    symbol: Symbol(type: .function(funTyp))
                )
            }

            return resolvedType

        case let .genericStructType(typ):
            return try apply(genericTypeApplication: expr, genericStructType: typ)

        case let .genericTraitType(typ):
            return try apply(genericTypeApplication: expr, genericTraitType: typ)

        default:
            throw unsupportedError(expression: expr)
        }
    }

    private func apply(
        genericTypeApplication expr: GenericTypeApplication,
        genericFunctionType: GenericFunctionType
    ) throws -> SymbolType {
        guard expr.arguments.count == genericFunctionType.typeArguments.count else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "incorrect number of type arguments in application of generic function type `\(expr.shortDescription)'"
            )
        }

        // TODO: check type constraints on the type variables here too
        // TODO: instantiation of the body of generic functions should not happen here at all

        let template0 = genericFunctionType.template
        let template1 = template0.clone()
        let template2 = template1.withTypeArguments([])

        // Bind types in a new symbol table to apply the type arguments.
        let symbolsWithTypeArguments = template2.symbols
        var evaluatedTypeArguments: [SymbolType] = []
        typealias Key = GenericsPartialEvaluator.ReplacementKey
        var replacementMap: [Key: Expression] = [:]
        for i in 0..<expr.arguments.count {
            let typeVariable = genericFunctionType.typeArguments[i]
            let typeArgument = try check(expression: expr.arguments[i])
            symbolsWithTypeArguments.bind(
                identifier: typeVariable.identifier,
                symbolType: typeArgument
            )
            evaluatedTypeArguments.append(typeArgument)

            let ident = typeVariable.identifier
            let scope = symbols.lookupIdOfEnclosingScope(identifier: ident)
            let key = Key(identifier: ident, scope: scope)
            replacementMap[key] = PrimitiveType(typeArgument)
        }
        let inner = RvalueExpressionTypeChecker(
            symbols: symbolsWithTypeArguments,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy,
            options: options
        )

        // Evaluate the function type template using the above symbols to get
        // the concrete function type result.
        let returnType = try inner.check(expression: genericFunctionType.returnType)
        let arguments = try inner.evaluateFunctionArguments(genericFunctionType.arguments)
        let mangledName = inner.mangleFunctionName(
            genericFunctionType.name,
            evaluatedTypeArguments: evaluatedTypeArguments
        )!
        let template3 = template2.withIdentifier(mangledName)
        let functionType = FunctionTypeInfo(
            name: mangledName,
            mangledName: mangledName,
            returnType: returnType,
            arguments: arguments,
            ast: template3
        )

        try SnapSubcompilerFunctionDeclaration(memoryLayoutStrategy: memoryLayoutStrategy)
            .instantiate(
                functionType: functionType,
                functionDeclaration: template3
            )

        let ast0 = functionType.ast!
        let ast1 = try GenericsPartialEvaluator(symbols: nil, map: replacementMap).visit(func: ast0)
            as! FunctionDeclaration
        functionType.ast = ast1

        return .function(functionType)
    }

    private func apply(
        genericTypeApplication expr: GenericTypeApplication,
        genericStructType: GenericStructTypeInfo
    ) throws -> SymbolType {
        guard expr.arguments.count == genericStructType.typeArguments.count else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "incorrect number of type arguments in application of generic struct type `\(expr.shortDescription)'"
            )
        }

        // TODO: check type constraints on the type variables here too

        // Bind types in a new symbol table to apply the type arguments.
        let symbolsWithTypeArguments = Env(parent: symbols)
        var evaluatedTypeArguments: [SymbolType] = []
        for i in 0..<expr.arguments.count {
            let typeVariable = genericStructType.typeArguments[i]
            let typeArgument = try check(expression: expr.arguments[i])
            symbolsWithTypeArguments.bind(
                identifier: typeVariable.identifier,
                symbolType: typeArgument
            )
            evaluatedTypeArguments.append(typeArgument)
        }

        if let memoizedResult = genericStructType.instantiations[evaluatedTypeArguments] {
            return memoizedResult
        }

        // Bind the concrete struct type
        let subcompiler = StructScanner(
            symbols: symbolsWithTypeArguments,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        let template = genericStructType.template.eraseTypeArguments()
        let concreteType = try subcompiler.compile(template, evaluatedTypeArguments)
        genericStructType.instantiations[evaluatedTypeArguments] = concreteType // memoize

        // Apply the deferred impl nodes now.
        for implNode in genericStructType.implNodes.map({ $0.eraseTypeArguments() }) {
            try ImplScanner(
                memoryLayoutStrategy: memoryLayoutStrategy,
                symbols: symbolsWithTypeArguments
            )
            .scan(impl: implNode.clone())
        }

        // Apply the deferred impl-for nodes now.
        for node0 in genericStructType.implForNodes {
            let node1 = node0.eraseTypeArguments().clone()
            try ImplForScanner(
                staticStorageFrame: staticStorageFrame,
                memoryLayoutStrategy: memoryLayoutStrategy,
                symbols: symbolsWithTypeArguments
            )
            .scan(implFor: node1)
        }

        try exportSymbols(
            typeArguments: genericStructType.template.typeArguments,
            symbolsWithTypeArguments: symbolsWithTypeArguments,
            expr: expr
        )

        return concreteType
    }

    private func apply(
        genericTypeApplication expr: GenericTypeApplication,
        genericTraitType: GenericTraitTypeInfo
    ) throws -> SymbolType {
        guard expr.arguments.count == genericTraitType.typeArguments.count else {
            throw CompilerError(
                sourceAnchor: expr.sourceAnchor,
                message: "incorrect number of type arguments in application of generic trait type `\(expr.shortDescription)'"
            )
        }

        // TODO: check type constraints on the type variables here too

        // Bind types in a new symbol table to apply the type arguments.
        let symbolsWithTypeArguments = Env(parent: symbols)
        var evaluatedTypeArguments: [SymbolType] = []
        for i in 0..<expr.arguments.count {
            let typeVariable = genericTraitType.typeArguments[i]
            let typeArgument = try check(expression: expr.arguments[i])
            symbolsWithTypeArguments.bind(
                identifier: typeVariable.identifier.identifier,
                symbolType: typeArgument
            )
            evaluatedTypeArguments.append(typeArgument)
        }

        if let memoizedResult = genericTraitType.instantiations[evaluatedTypeArguments] {
            return memoizedResult
        }

        // Bind the concrete trait type
        let concreteType = try instantiate(
            genericTraitType,
            evaluatedTypeArguments,
            symbolsWithTypeArguments
        )
        genericTraitType.instantiations[evaluatedTypeArguments] = concreteType // memoize

        try exportSymbols(
            typeArguments: genericTraitType.typeArguments,
            symbolsWithTypeArguments: symbolsWithTypeArguments,
            expr: expr
        )

        return concreteType
    }

    private func instantiate(
        _ genericTraitType: GenericTraitTypeInfo,
        _ evaluatedTypeArguments: [SymbolType],
        _ symbols: Env
    ) throws -> SymbolType {
        let node0 = genericTraitType.template.eraseTypeArguments()

        guard let mangledName = mangleTraitName(
            node0.name,
            evaluatedTypeArguments: evaluatedTypeArguments
        ) else {
            throw CompilerError(
                sourceAnchor: node0.identifier.sourceAnchor,
                message: "internal compiler error: could not generate mangled name for trait"
            )
        }
        let node1 = node0.withMangledName(mangledName)

        let result = try declareTraitType(
            node1,
            evaluatedTypeArguments,
            genericTraitType,
            symbols
        )
        try declareVtableType(node1, symbols)
        try declareTraitObjectType(node1, symbols)
        try declareTraitObjectThunks(node1, symbols)

        return result
    }

    private func declareTraitType(
        _ traitDecl: TraitDeclaration,
        _ evaluatedTypeArguments: [SymbolType] = [],
        _ genericTraitType: GenericTraitTypeInfo? = nil,
        _ symbols: Env
    ) throws -> SymbolType {
        let mangledName = traitDecl.mangledName
        let members = Env(parent: symbols)
        let typeChecker = RvalueExpressionTypeChecker(
            symbols: members,
            staticStorageFrame: staticStorageFrame,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        let fullyQualifiedTraitType = TraitTypeInfo(
            name: mangledName,
            nameOfTraitObjectType: traitDecl.nameOfTraitObjectType,
            nameOfVtableType: traitDecl.nameOfVtableType,
            symbols: members
        )
        let result = SymbolType.traitType(fullyQualifiedTraitType)
        symbols.bind(
            identifier: mangledName,
            symbolType: result,
            visibility: traitDecl.visibility
        )

        if let genericTraitType {
            genericTraitType.instantiations[evaluatedTypeArguments] = result // memoize
        }

        members.breadcrumb = .traitType(fullyQualifiedTraitType.name)
        let frame = Frame()
        members.frameLookupMode = .set(frame)
        for memberDeclaration in traitDecl.members {
            let memberType = try typeChecker.check(expression: memberDeclaration.memberType)
            let sizeOfMemberType = memoryLayoutStrategy.sizeof(type: memberType)
            let offset = frame.allocate(size: sizeOfMemberType)
            let symbol = Symbol(type: memberType, storage: .automaticStorage(offset: offset))
            members.bind(identifier: memberDeclaration.name, symbol: symbol)
            frame.add(identifier: memberDeclaration.name, symbol: symbol)
        }
        members.parent = nil

        return result
    }

    private func declareVtableType(
        _ traitDecl: TraitDeclaration,
        _ symbols: Env
    ) throws {
        let traitName = traitDecl.identifier.identifier
        let members: [StructDeclaration.Member] = traitDecl.members.map {
            let memberType = TraitObjectDeclarationsBuilder()
                .rewriteTraitMemberTypeForVtable(traitName, $0.memberType)
            let member = StructDeclaration.Member(name: $0.name, type: memberType)
            return member
        }
        let structDecl = StructDeclaration(
            sourceAnchor: traitDecl.sourceAnchor,
            identifier: Identifier(traitDecl.nameOfVtableType),
            members: members,
            visibility: traitDecl.visibility,
            isConst: true
        )
        _ = try StructScanner(
            symbols: symbols,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(structDecl)
    }

    private func declareTraitObjectType(
        _ traitDecl: TraitDeclaration,
        _ symbols: Env
    ) throws {
        let members: [StructDeclaration.Member] = [
            StructDeclaration.Member(name: "object", type: PointerType(PrimitiveType(.void))),
            StructDeclaration.Member(
                name: "vtable",
                type: PointerType(ConstType(Identifier(traitDecl.nameOfVtableType)))
            )
        ]
        let structDecl = StructDeclaration(
            sourceAnchor: traitDecl.sourceAnchor,
            identifier: Identifier(traitDecl.nameOfTraitObjectType),
            members: members,
            visibility: traitDecl.visibility,
            isConst: false
        ) // TODO: Should isConst be true here?
        _ = try StructScanner(
            symbols: symbols,
            memoryLayoutStrategy: memoryLayoutStrategy
        )
        .compile(structDecl)
    }

    private func declareTraitObjectThunks(
        _ traitDecl: TraitDeclaration,
        _ symbols: Env
    ) throws {
        var thunks: [FunctionDeclaration] = []
        for method in traitDecl.members {
            let functionType = TraitObjectDeclarationsBuilder()
                .rewriteTraitMemberTypeForThunk(traitDecl, method)
            let argumentNames = (0..<functionType.arguments.count).map {
                ($0 == 0) ? "self" : "arg\($0)"
            }
            let callee = Get(
                expr: Get(expr: Identifier("self"), member: Identifier("vtable")),
                member: Identifier(method.name)
            )
            let arguments = [Get(expr: Identifier("self"), member: Identifier("object"))]
                + argumentNames[1...].map { Identifier($0) }

            let outer = Env(
                parent: symbols,
                frameLookupMode: .set(Frame(growthDirection: .down))
            )

            let fnBody: Block
            let returnType = try RvalueExpressionTypeChecker(symbols: symbols).check(
                expression: functionType.returnType
            )
            if returnType == .void {
                fnBody = Block(
                    symbols: Env(parent: outer),
                    children: [Call(callee: callee, arguments: arguments)]
                )
            }
            else {
                fnBody = Block(
                    symbols: Env(parent: outer),
                    children: [Return(Call(callee: callee, arguments: arguments))]
                )
            }

            let fnDecl = FunctionDeclaration(
                identifier: Identifier(method.name),
                functionType: functionType,
                argumentNames: argumentNames,
                body: fnBody,
                symbols: outer
            )
            thunks.append(fnDecl)
        }
        let implBlock = Impl(
            sourceAnchor: traitDecl.sourceAnchor,
            typeArguments: [], // TODO: Generic traits
            structTypeExpr: Identifier(traitDecl.nameOfTraitObjectType),
            children: thunks
        )
        try ImplScanner(
            memoryLayoutStrategy: memoryLayoutStrategy,
            symbols: symbols
        )
        .scan(impl: implBlock)
    }

    private func exportSymbols(
        typeArguments: [GenericTypeArgument],
        symbolsWithTypeArguments: Env,
        expr: GenericTypeApplication
    ) throws {
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
                    message: "generic type application redefines existing symbol: `\(typeName)'"
                )
            }
            symbols.bind(identifier: typeName, symbolType: symbolType)
        }

        for symbolName in symbolsWithTypeArguments.symbolTable.keys {
            let symbol = symbolsWithTypeArguments.symbolTable[symbolName]!
            guard !symbols.exists(identifier: symbolName) else {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "generic type application redefines existing symbol: `\(symbolName)'"
                )
            }
            guard !symbols.existsAsType(identifier: symbolName) else {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "generic type application redefines existing type: `\(symbolName)'"
                )
            }
            symbols.bind(identifier: symbolName, symbol: symbol)
        }
    }

    public func check(pointerType expr: PointerType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return .pointer(typ)
    }

    public func check(constType expr: ConstType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return typ.correspondingConstType
    }

    public func check(mutableType expr: MutableType) throws -> SymbolType {
        let typ = try check(expression: expr.typ)
        return typ.correspondingMutableType
    }

    public func check(structInitializer expr: StructInitializer) throws -> SymbolType {
        let result = try check(expression: expr.expr)
        let typ = result.unwrapStructType()
        var membersAlreadyInitialized: [String] = []
        for arg in expr.arguments {
            guard typ.symbols.exists(identifier: arg.name) else {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "value of type `\(expr.expr)' has no member `\(arg.name)'"
                )
            }
            if membersAlreadyInitialized.contains(arg.name) {
                throw CompilerError(
                    sourceAnchor: expr.sourceAnchor,
                    message: "initialization of member `\(arg.name)' can only occur one time"
                )
            }
            let rtype = try rvalueContext().check(expression: arg.expr)
            let member = try! typ.symbols.resolve(identifier: arg.name)
            let ltype = member.type
            let message = "cannot convert value of type `\(rtype)' to expected argument type `\(ltype)' in initialization of `\(arg.name)'"
            _ = try checkTypesAreConvertibleInAssignment(
                ltype: ltype,
                rtype: rtype,
                sourceAnchor: arg.expr.sourceAnchor,
                messageWhenNotConvertible: message
            )
            membersAlreadyInitialized.append(arg.name)
        }
        return result
    }

    public func check(unionType expr: UnionType) throws -> SymbolType {
        try .unionType(unionTypeInfo(for: expr))
    }

    public func unionTypeInfo(for expr: UnionType) throws -> UnionTypeInfo {
        try UnionTypeInfo(expr.members.map { try check(expression: $0) })
    }

    public func check(literalString expr: LiteralString) throws -> SymbolType {
        .array(count: expr.value.count, elementType: .u8)
    }

    public func check(typeOf expr: TypeOf) throws -> SymbolType {
        let type0 = try rvalueContext().check(expression: expr.expr)

        let type1: SymbolType =
            switch type0 {
            case let .arithmeticType(.compTimeInt(constantValue)):
                .arithmeticType(
                    .mutableInt(
                        IntClass.smallestClassContaining(value: constantValue)!
                    )
                )
            case .booleanType(.compTimeBool):
                .bool
            default:
                type0
            }

        return type1
    }

    public func check(bitcast expr: Bitcast) throws -> SymbolType {
        try rvalueContext().check(expression: expr.targetType)
    }

    public func check(sizeOf _: SizeOf) throws -> SymbolType {
        .arithmeticType(.immutableInt(.u16
        )) // TODO: should the runtime provide a `usize' typealias for this?
        // TODO: should the runtime provide a `usize' typealias for this?
    }

    public func check(eseq: Eseq) throws -> SymbolType {
        try check(expression: eseq.expr)
    }

    func unsupportedError(expression: Expression) -> Error {
        CompilerError(
            sourceAnchor: expression.sourceAnchor,
            message: "unsupported expression: \(expression)"
        )
    }

    private func doesStructConformToVtable(
        _ structType: StructTypeInfo,
        _ traitType: TraitTypeInfo
    ) -> Bool {
        try! symbols
            .resolveType(identifier: traitType.nameOfVtableType)
            .unwrapStructType()
            .symbols
            .symbolTable
            .allSatisfy { name, traitSymbol in
                let structSymbol = structType.symbols.symbolTable[name]
                guard let structSymbol else { return false }
                let conforms = areTypesConvertible(
                    ltype: traitSymbol.type,
                    rtype: structSymbol.type
                )
                return conforms
            }
    }
}

/// Mangles identifier names in a consistent way
/// Mangle, here, means to take a human-readable identifier provided by the
/// programmer and replace it with an automatically generated name which is
/// less readable, but embeds additional information useful to the compiler.
public struct NameMangler {
    public func mangleFunctionName(
        _ name: String?,
        evaluatedTypeArguments: [SymbolType] = [],
        symbols: Env
    ) -> String? {
        guard let name else { return nil }

        let decoratedName: String = {
            guard evaluatedTypeArguments.isEmpty else {
                let args = evaluatedTypeArguments
                    .map(\.description)
                    .joined(separator: ", ")
                return "\(name)[\(args)]"
            }
            return name
        }()

        let breadcrumbs = symbols.breadcrumbs
            .filter { $0.useGlobalNamespace != true }
            .compactMap(\.name) + [decoratedName]
        let mangledName = breadcrumbs.joined(separator: "::")

        return mangledName
    }

    public func mangleStructName(
        _ name: String?,
        evaluatedTypeArguments: [SymbolType] = [],
        symbols _: Env
    ) -> String? {
        guard let name else { return nil }
        let mangledName: String = {
            guard evaluatedTypeArguments.isEmpty else {
                let args = evaluatedTypeArguments
                    .map(\.description)
                    .joined(separator: ", ")
                return "\(name)[\(args)]"
            }
            return name
        }()
        return mangledName
    }

    public func mangleTraitName(
        _ name: String?,
        evaluatedTypeArguments: [SymbolType] = [],
        symbols: Env
    ) -> String? {
        mangleStructName(
            name,
            evaluatedTypeArguments: evaluatedTypeArguments,
            symbols: symbols
        )
    }
}
