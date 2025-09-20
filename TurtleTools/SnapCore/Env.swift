//
//  Env.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

public indirect enum SymbolType: Hashable, CustomStringConvertible {
    case void
    case function(FunctionTypeInfo)
    case genericFunction(GenericFunctionType)
    case booleanType(BooleanTypeInfo)
    case arithmeticType(ArithmeticTypeInfo)
    case array(count: Int?, elementType: SymbolType)
    case constDynamicArray(elementType: SymbolType)
    case dynamicArray(elementType: SymbolType)
    case constPointer(SymbolType)
    case pointer(SymbolType)
    case constStructType(StructTypeInfo)
    case structType(StructTypeInfo)
    case genericStructType(GenericStructTypeInfo)
    case constTraitType(TraitTypeInfo)
    case traitType(TraitTypeInfo)
    case genericTraitType(GenericTraitTypeInfo)
    case unionType(UnionTypeInfo)
    case label

    public var isPrimitive: Bool {
        switch self {
        case .void, .booleanType, .arithmeticType, .pointer, .constPointer, .label:
            true

        default:
            false
        }
    }

    public var isConst: Bool {
        switch self {
        case .void, .function, .label:
            true
        case .booleanType(let typ):
            typ.isConst
        case .arithmeticType(let typ):
            typ.isConst
        case .constDynamicArray, .constPointer, .constStructType, .constTraitType:
            true
        default:
            false
        }
    }

    public var correspondingConstType: SymbolType {
        switch self {
        case .booleanType:
            .constBool
        case .arithmeticType(let arithmeticType):
            .arithmeticType(.immutableInt(arithmeticType.intClass!))
        case .array(count: let n, elementType: let typ):
            .array(count: n, elementType: typ.correspondingConstType)
        case .dynamicArray(elementType: let typ):
            .constDynamicArray(elementType: typ)
        case .structType(let typ):
            .constStructType(typ)
        case .pointer(let typ):
            .constPointer(typ)
        case .unionType(let typ):
            .unionType(typ.correspondingConstType)
        case .traitType(let typ):
            .constTraitType(typ)
        default:
            self
        }
    }

    public var correspondingMutableType: SymbolType {
        switch self {
        case .booleanType:
            .bool
        case .arithmeticType(let arithmeticType):
            .arithmeticType(.mutableInt(arithmeticType.intClass!))
        case .array(count: let n, elementType: let typ):
            .array(count: n, elementType: typ.correspondingMutableType)
        case .constDynamicArray(elementType: let typ):
            .dynamicArray(elementType: typ)
        case .constStructType(let typ):
            .structType(typ)
        case .constPointer(let typ):
            .pointer(typ)
        case .unionType(let typ):
            .unionType(typ.correspondingMutableType)
        case .constTraitType(let typ):
            .traitType(typ)
        default:
            self
        }
    }
    
    public var isUnionType: Bool {
        maybeUnwrapUnionType() != nil
    }
    
    public func unwrapUnionType() -> UnionTypeInfo {
        maybeUnwrapUnionType()!
    }

    public func maybeUnwrapUnionType() -> UnionTypeInfo? {
        switch self {
        case .unionType(let typ):
            typ
        default:
            nil
        }
    }

    public func unwrapGenericFunctionType() -> GenericFunctionType {
        switch self {
        case .genericFunction(let typ):
            typ
        default:
            abort()
        }
    }

    public func unwrapPointerType() -> SymbolType {
        maybeUnwrapPointerType()!
    }

    public func maybeUnwrapPointerType() -> SymbolType? {
        switch self {
        case .pointer(let typ), .constPointer(let typ):
            typ
        default:
            nil
        }
    }

    public func unwrapFunctionType() -> FunctionTypeInfo {
        maybeUnwrapFunctionType()!
    }

    public func maybeUnwrapFunctionType() -> FunctionTypeInfo? {
        switch self {
        case .function(let typ):
            typ
        default:
            nil
        }
    }

    public func unwrapStructType() -> StructTypeInfo {
        maybeUnwrapStructType()!
    }

    public func maybeUnwrapStructType() -> StructTypeInfo? {
        switch self {
        case .constStructType(let typ), .structType(let typ):
            typ
        default:
            nil
        }
    }

    public func unwrapGenericStructType() -> GenericStructTypeInfo {
        maybeUnwrapGenericStructType()!
    }

    public func maybeUnwrapGenericStructType() -> GenericStructTypeInfo? {
        switch self {
        case .genericStructType(let typ):
            typ
        default:
            nil
        }
    }

    public func unwrapTraitType() -> TraitTypeInfo {
        maybeUnwrapTraitType()!
    }

    public func maybeUnwrapTraitType() -> TraitTypeInfo? {
        switch self {
        case .constTraitType(let typ), .traitType(let typ):
            typ
        default:
            nil
        }
    }

    public var isTraitType: Bool {
        maybeUnwrapTraitType() != nil
    }

    public func unwrapGenericTraitType() -> GenericTraitTypeInfo {
        switch self {
        case .genericTraitType(let typ):
            return typ
        default:
            abort()
        }
    }

    public var isFunctionType: Bool {
        switch self {
        case .function:
            true
        default:
            false
        }
    }

    public var isBooleanType: Bool {
        switch self {
        case .booleanType:
            true
        default:
            false
        }
    }
    
    public var isCompileTimeBooleanType: Bool {
        switch self {
        case .booleanType(.compTimeBool(_)):
            true
        default:
            false
        }
    }

    public var isArithmeticType: Bool {
        switch self {
        case .arithmeticType:
            true
        default:
            false
        }
    }
    
    public var isCompileTimeArithmeticType: Bool {
        switch self {
        case .arithmeticType(.compTimeInt(_)):
            true
        default:
            false
        }
    }
    
    public func unwrapArithmeticType() -> ArithmeticTypeInfo {
        maybeUnwrapArithmeticType()!
    }

    public func maybeUnwrapArithmeticType() -> ArithmeticTypeInfo? {
        switch self {
        case .arithmeticType(let typ):
            typ
        default:
            nil
        }
    }

    public var isPointerType: Bool {
        switch self {
        case .pointer, .constPointer:
            true
        default:
            false
        }
    }

    public var isStructType: Bool {
        maybeUnwrapStructType() != nil
    }
    
    public var isDynamicArrayType: Bool {
        switch self {
        case .dynamicArray, .constDynamicArray:
            true
        default:
            false
        }
    }

    public var isArrayType: Bool {
        switch self {
        case .array:
            true
        default:
            false
        }
    }

    public var arrayCount: Int? {
        switch self {
        case .array(let count, elementType: _):
            count
        default:
            abort()
        }
    }

    public var arrayElementType: SymbolType {
        switch self {
        case .array(count: _, let elementType):
            elementType
        case .constDynamicArray(let elementType), .dynamicArray(let elementType):
            elementType
        default:
            abort()
        }
    }

    public var description: String {
        switch self {
        case .void:
            "void"
        case .booleanType(let a):
            "\(a)"
        case .arithmeticType(let arithmeticType):
            "\(arithmeticType)"
        case .array(let count, let elementType):
            if let count = count {
                "[\(count)]\(elementType)"
            }
            else {
                "[_]\(elementType)"
            }
        case .constDynamicArray(let elementType):
            "const []\(elementType)"
        case .dynamicArray(let elementType):
            "[]\(elementType)"
        case .function(let functionType):
            "\(functionType)"
        case .genericFunction(let genericFunctionType):
            "\(genericFunctionType)"
        case .constStructType(let typ):
            "const \(typ.shortDescription)"
        case .structType(let typ):
            "\(typ.shortDescription)"
        case .genericStructType(let typ):
            "\(typ)"
        case .constTraitType(let typ):
            "const \(typ.name)"
        case .traitType(let typ):
            "\(typ.name)"
        case .genericTraitType(let genericTraitType):
            "\(genericTraitType)"
        case .constPointer(let pointee):
            "const *\(pointee)"
        case .pointer(let pointee):
            "*\(pointee)"
        case .unionType(let typ):
            "\(typ)"
        case .label:
            "label"
        }
    }

    /// Return an expression for this type
    /// Types may be expressed in the language of Expression nodes, which may
    /// be inserted directly into the AST, or as a value of SymbolType, which
    /// may be elegantly matched in a switch statement.
    public var lift: Expression {
        switch self {
        case .void:
            PrimitiveType(.void)

        case .function(let typ):
            FunctionType(
                name: typ.name,
                returnType: typ.returnType.lift,
                arguments: typ.arguments.map { $0.lift }
            )

        case .genericFunction(let typ):
            GenericFunctionType(
                template: typ.template,
                enclosingImplId: typ.enclosingImplId
            )

        case .booleanType(let typ):
            switch typ {
            case .compTimeBool(let val):
                LiteralBool(val)
            case .immutableBool:
                ConstType(PrimitiveType(.bool))
            case .mutableBool:
                PrimitiveType(.bool)
            }

        case .arithmeticType(let typ):
            switch typ {
            case .compTimeInt(let val):
                LiteralInt(val)
            case .immutableInt(let cls):
                ConstType(PrimitiveType(.arithmeticType(.mutableInt(cls))))
            case .mutableInt(let cls):
                PrimitiveType(.arithmeticType(.mutableInt(cls)))
            }

        case .array(let count, let elementType):
            ArrayType(
                count: count == nil ? nil : LiteralInt(count!),
                elementType: elementType.lift
            )

        case .constDynamicArray(let elementType):
            ConstType(DynamicArrayType(elementType.lift))

        case .dynamicArray(let elementType):
            DynamicArrayType(elementType.lift)

        case .constPointer(let typ):
            ConstType(PointerType(typ.lift))

        case .pointer(let typ):
            PointerType(typ.lift)

        case .constStructType:
            ConstType(self.correspondingMutableType.lift)

        case .structType(let typ):
            if typ.name.isEmpty {
                PrimitiveType(self)
            }
            else {
                Identifier(typ.name)
            }

        case .genericStructType:
            PrimitiveType(self)

        case .constTraitType:
            ConstType(self.correspondingMutableType.lift)

        case .traitType(let typ):
            Identifier(typ.name)

        case .genericTraitType(let typ):
            Identifier(typ.name)

        case .unionType(let typ):
            UnionType(typ.members.map(\.lift))

        case .label:
            fatalError("cannot lift a label")
        }
    }

    public static let u8: SymbolType = .arithmeticType(.mutableInt(.u8))
    public static let u16: SymbolType = .arithmeticType(.mutableInt(.u16))
    public static let i8: SymbolType = .arithmeticType(.mutableInt(.i8))
    public static let i16: SymbolType = .arithmeticType(.mutableInt(.i16))

    public static let constU8: SymbolType = .arithmeticType(.immutableInt(.u8))
    public static let constU16: SymbolType = .arithmeticType(.immutableInt(.u16))
    public static let constI8: SymbolType = .arithmeticType(.immutableInt(.i8))
    public static let constI16: SymbolType = .arithmeticType(.immutableInt(.i16))

    public static let bool: SymbolType = .booleanType(.mutableBool)
    public static let constBool: SymbolType = .booleanType(.immutableBool)
}

public enum SymbolStorage: Hashable {
    public typealias Register = TackInstruction.Register

    case staticStorage(offset: Int?)
    case automaticStorage(offset: Int?)
    case registerStorage(Register?)

    public var offset: Int? {
        switch self {
        case .automaticStorage(let offset),
            .staticStorage(let offset):
            offset

        case .registerStorage:
            nil
        }
    }

    public var isStaticStorage: Bool {
        switch self {
        case .staticStorage: true
        default: false
        }
    }

    public var isAutomaticStorage: Bool {
        switch self {
        case .automaticStorage: true
        default: false
        }
    }

    public var isRegisterStorage: Bool {
        switch self {
        case .registerStorage: true
        default: false
        }
    }

    public var register: Register? {
        switch self {
        case .registerStorage(let r): r
        default: nil
        }
    }

    public func withOffset(_ offset: Int?) -> SymbolStorage {
        switch self {
        case .automaticStorage:
            .automaticStorage(offset: offset)

        case .staticStorage:
            .staticStorage(offset: offset)

        case .registerStorage:
            fatalError("register storage has no associated offset in memory")
        }
    }
}

public enum BooleanTypeInfo: Hashable, CustomStringConvertible {
    case mutableBool, immutableBool
    case compTimeBool(Bool)

    public func canValueBeTriviallyReinterpretedAs(type: BooleanTypeInfo) -> Bool {
        !(self.isCompTime || type.isCompTime)
    }

    public var isCompTime: Bool {
        switch self {
        case .compTimeBool:
            true

        case .immutableBool, .mutableBool:
            false
        }
    }

    public var isConst: Bool {
        switch self {
        case .mutableBool:
            false

        case .immutableBool, .compTimeBool:
            true
        }
    }

    public var description: String {
        switch self {
        case .mutableBool:
            "bool"

        case .immutableBool:
            "const bool"

        case .compTimeBool(let a):
            "boolean constant \(a)"
        }
    }
}

public enum IntClass: Hashable, CustomStringConvertible, CaseIterable {
    case u8, u16, i8, i16

    public static func binaryResultType(left: IntClass?, right: IntClass?) -> IntClass? {
        guard let left = left, let right = right else {
            return nil
        }

        if left.min < right.min {
            return left
        }

        if left.max > right.max {
            return left
        }

        return right
    }

    public var isSigned: Bool {
        switch self {
        case .i8, .i16:
            true

        case .u8, .u16:
            false
        }
    }

    public var description: String {
        switch self {
        case .i8: "i8"
        case .i16: "i16"
        case .u8: "u8"
        case .u16: "u16"
        }
    }

    public var min: Int {
        switch self {
        case .i8: -128
        case .i16: -32768
        case .u8: 0
        case .u16: 0
        }
    }

    public var max: Int {
        switch self {
        case .i8: 127
        case .i16: 32767
        case .u8: 255
        case .u16: 65535
        }
    }

    public static func smallestClassContaining(value: Int) -> IntClass? {
        for intClass in IntClass.allCases {
            if value >= intClass.min && value <= intClass.max {
                return intClass
            }
        }

        return nil
    }
}

public enum ArithmeticTypeInfo: Hashable, CustomStringConvertible {
    case mutableInt(IntClass)
    case immutableInt(IntClass)
    case compTimeInt(Int)

    public static func binaryResultType(
        left: ArithmeticTypeInfo,
        right: ArithmeticTypeInfo
    ) -> ArithmeticTypeInfo? {
        if let intClass = IntClass.binaryResultType(left: left.intClass, right: right.intClass) {
            .mutableInt(intClass)
        }
        else {
            nil
        }
    }

    public var intClass: IntClass? {
        switch self {
        case .mutableInt(let a), .immutableInt(let a):
            a

        case .compTimeInt(let value):
            IntClass.smallestClassContaining(value: value)
        }
    }

    public var min: Int {
        switch self {
        case .compTimeInt(let constantValue):
            constantValue

        case .mutableInt(let a), .immutableInt(let a):
            a.min
        }
    }

    public var max: Int {
        switch self {
        case .compTimeInt(let constantValue):
            constantValue

        case .mutableInt(let a), .immutableInt(let a):
            a.max
        }
    }

    public func canValueBeTriviallyReinterpretedAs(type dst: ArithmeticTypeInfo) -> Bool {
        if self.isCompTime || dst.isCompTime {
            return false
        }

        let srcIntClass = intClass!
        let dstIntClass = dst.intClass!

        // In previous versions of the language, we could trivially reinterpret
        // i8 as i16 and u8 as u16, but this is no longer allowed since the
        // introduction of typed registers in the Tack intermediate language.
        return srcIntClass == dstIntClass
    }

    public var isCompTime: Bool {
        switch self {
        case .compTimeInt:
            true

        case .mutableInt, .immutableInt:
            false
        }
    }

    public var isConst: Bool {
        switch self {
        case .mutableInt:
            false

        case .immutableInt, .compTimeInt:
            true
        }
    }

    public var description: String {
        switch self {
        case .mutableInt(let width):
            "\(width)"

        case .immutableInt(let width):
            "const \(width)"

        case .compTimeInt(let value):
            "integer constant \(value)"
        }
    }
}

/// Describe a function type in detail
public final class FunctionTypeInfo: Hashable, CustomStringConvertible {
    public let name: String?
    public let mangledName: String?
    public let returnType: SymbolType
    public let arguments: [SymbolType]
    public var ast: FunctionDeclaration?

    public convenience init(returnType: SymbolType, arguments: [SymbolType]) {
        self.init(
            name: nil,
            mangledName: nil,
            returnType: returnType,
            arguments: arguments
        )
    }

    public convenience init(
        name: String,
        returnType: SymbolType,
        arguments: [SymbolType]
    ) {
        self.init(
            name: name,
            mangledName: name,
            returnType: returnType,
            arguments: arguments
        )
    }

    public init(
        name: String?,
        mangledName: String?,
        returnType: SymbolType,
        arguments: [SymbolType],
        ast: FunctionDeclaration? = nil
    ) {
        self.name = name
        self.mangledName = mangledName
        self.returnType = returnType
        self.arguments = arguments
        self.ast = ast
    }

    public var description: String {
        let name = self.name ?? ""
        return "func \(name)(\(argumentsDescription)) -> \(returnType)"
    }

    public var argumentsDescription: String {
        arguments.map(\.description).joined(separator: ", ")
    }

    public static func == (lhs: FunctionTypeInfo, rhs: FunctionTypeInfo) -> Bool {
        guard lhs.name == rhs.name else { return false }
        guard lhs.mangledName == rhs.mangledName else { return false }
        guard lhs.returnType == rhs.returnType else { return false }
        guard lhs.arguments == rhs.arguments else { return false }
        //        guard lhs.ast == rhs.ast else { return false }
        return true
    }

    private var isDoingHash = false

    public func hash(into hasher: inout Hasher) {
        defer { isDoingHash = false }
        hasher.combine(name)
        hasher.combine(mangledName)
        hasher.combine(returnType)
        if !isDoingHash {
            hasher.combine(arguments)
        }
        //        hasher.combine(ast)
    }

    public func eraseName() -> FunctionTypeInfo {
        FunctionTypeInfo(
            name: nil,
            mangledName: nil,
            returnType: returnType,
            arguments: arguments,
            ast: ast
        )
    }

    public func withBody(_ body: Block) -> FunctionTypeInfo {
        FunctionTypeInfo(
            name: name,
            mangledName: mangledName,
            returnType: returnType,
            arguments: arguments,
            ast: ast?.withBody(body)
        )
    }

    public func withName(_ name: String) -> FunctionTypeInfo {
        FunctionTypeInfo(
            name: name,
            mangledName: mangledName,
            returnType: returnType,
            arguments: arguments,
            ast: ast
        )
    }
}

/// Describe a struct type in detail
public final class StructTypeInfo: Hashable, CustomStringConvertible {
    public let name: String
    public let fields: Env
    public private(set) var symbols: Env

    /// If the struct was synthesized to represent a Trait then this is the
    /// name of the associated trait, else nil.
    public let associatedTraitType: String?

    /// If the struct was synthesized to represent a Module then this is the
    /// name of the associated module, else nil.
    public let associatedModuleName: String?

    /// Indicates whether the struct was synthesized to represent a Module
    public var isModule: Bool { associatedModuleName != nil }

    public init(
        name: String,
        fields: Env,
        associatedTraitType: String? = nil,
        associatedModuleName: String? = nil
    ) {
        self.name = name
        self.fields = fields
        self.symbols = fields
        self.associatedTraitType = associatedTraitType
        self.associatedModuleName = associatedModuleName
    }

    public func clone() -> StructTypeInfo {
        StructTypeInfo(
            name: name,
            fields: fields.clone(),
            associatedTraitType: associatedTraitType,
            associatedModuleName: associatedModuleName
        )
    }

    public func withAssociatedModule(_ associatedModuleName: String?) -> StructTypeInfo {
        StructTypeInfo(
            name: name,
            fields: fields.clone(),
            associatedTraitType: associatedTraitType,
            associatedModuleName: associatedModuleName
        )
    }
    
    private var isShortDescriptionRunning = 0 // avoid infinite recursion
    
    public var shortDescription: String {
        isShortDescriptionRunning += 1
        defer { isShortDescriptionRunning -= 1 }
        guard name.isEmpty else { return name }
        guard isShortDescriptionRunning <= 1 else { return "struct { … }" }
        let membersDesc = symbols.declarationOrder
            .map {
                guard let sym = symbols.symbolTable[$0] else {
                    fatalError("internal compiler error: an identifier in `declarationOrder` is expected to also be present in `smybolTable` but this one was missing: \($0)")
                }
                return "\($0):\(sym.type)"
            }
            .joined(separator: ", ")
        return "struct { \(membersDesc) }"
    }

    public var description: String {
        """
        StructDeclaration(\(name))
        \tassociatedTraitType: \(associatedTraitType ?? "none")
        \tassociatedModuleName: \(associatedModuleName ?? "none")
        \tMembers:
        \(makeMembersDescription())\n
        """
    }

    public func makeMembersDescription() -> String {
        symbols.symbolTable
            .map { "\t\t\($0): \($1.type)" }
            .joined(separator: "\n")
    }

    public static func == (lhs: StructTypeInfo, rhs: StructTypeInfo) -> Bool {
        lhs.isEqual(rhs)
    }

    private var isDoingEqualityTest = false

    private func isEqual(_ rhs: StructTypeInfo) -> Bool {
        // Avoid recursive comparisons. These can occur if a trait contains a
        // method with a parameter whose type is a pointer to the trait. If we
        // don't detect these cases then we get infinite recursion.
        guard !isDoingEqualityTest else { return true }
        isDoingEqualityTest = true
        defer { isDoingEqualityTest = false }

        guard name == rhs.name else { return false }
        guard fields.symbolTable == rhs.fields.symbolTable else { return false }
        guard associatedTraitType == rhs.associatedTraitType else { return false }
        guard associatedModuleName == rhs.associatedModuleName else { return false }

        return true
    }

    private var isComputingHash = false

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)

        // Avoid recursive computation of the hash.
        // This can occur with recursive types such as the following:
        //        struct LinkedList {
        //            next: *const LinkedList | None,
        //            key: u8,
        //            value: u8
        //        }
        guard !isComputingHash else { return }
        isComputingHash = true
        defer { isComputingHash = false }

        hasher.combine(fields)
        hasher.combine(associatedTraitType)
        hasher.combine(associatedModuleName)
    }

    public func push() {
        let top = Env(parent: symbols)
        symbols = top
    }

    public func pop() {
        guard let parent = symbols.parent else { return }
        symbols = parent
    }
}

/// Describe a generic struct type in detail
public final class GenericStructTypeInfo: Hashable, CustomStringConvertible {
    public let template: StructDeclaration
    public var instantiations: [[SymbolType]: SymbolType] = [:]

    public var name: String { template.name }

    /// Compilation of Impl nodes is deferred until the generic struct is
    /// instantiated with concrete types.
    public var implNodes: [Impl] = []

    /// Compilation of ImplFor nodes is deferred until the generic struct is
    /// instantiated with concrete types.
    public var implForNodes: [ImplFor] = []

    public func clone() -> GenericStructTypeInfo {
        GenericStructTypeInfo(template: template)
    }

    public init(template: StructDeclaration) {
        self.template = template
    }

    public var typeArguments: [Identifier] {
        template.typeArguments.map(\.identifier)
    }

    public var description: String {
        "\(template.name)\(template.typeArgumentsDescription)"
    }

    public static func == (lhs: GenericStructTypeInfo, rhs: GenericStructTypeInfo) -> Bool {
        lhs.template == rhs.template
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(template)
    }
}

/// Describe a trait type in detail
public final class TraitTypeInfo: Hashable, CustomStringConvertible {
    public let name: String
    public let symbols: Env
    public let nameOfTraitObjectType: String
    public let nameOfVtableType: String

    public init(
        name: String,
        nameOfTraitObjectType: String,
        nameOfVtableType: String,
        symbols: Env
    ) {
        self.name = name
        self.nameOfTraitObjectType = nameOfTraitObjectType
        self.nameOfVtableType = nameOfVtableType
        self.symbols = symbols
    }

    public static func == (lhs: TraitTypeInfo, rhs: TraitTypeInfo) -> Bool {
        lhs.isEqual(rhs)
    }

    private var isDoingEqualityTest = false

    private func isEqual(_ rhs: TraitTypeInfo) -> Bool {
        // Avoid recursive comparisons. These can occur if a trait contains a
        // method with a parameter whose type is a pointer to the trait. If we
        // don't detect these cases then we get infinite recursion.
        guard false == isDoingEqualityTest else { return true }
        isDoingEqualityTest = true
        defer { isDoingEqualityTest = false }

        guard name == rhs.name else { return false }
        guard nameOfVtableType == rhs.nameOfVtableType else { return false }
        guard symbols == rhs.symbols else { return false }
        return true
    }

    private var isDoingHash = false

    public func hash(into hasher: inout Hasher) {
        defer { isDoingHash = false }
        isDoingHash = true
        hasher.combine(name)
        hasher.combine(nameOfVtableType)
        if !isDoingHash {
            hasher.combine(symbols)
        }
    }

    public var description: String {
        """
        trait \(name) {
        \ttrait object type: \(nameOfTraitObjectType),
        \tvtable type: \(nameOfVtableType),
        \(makeMembersDescription())
        }
        """
    }

    public func makeMembersDescription() -> String {
        members
            .map { name, type in
                "\t\(name): \(type)"
            }
            .joined(separator: ",\n")
    }

    var members: [(name: String, type: SymbolType)] {
        symbols.symbolTable.map { name, symbol in
            (name: name, type: symbol.type)
        }
    }
}

/// Describe a generic trait type in details
public final class GenericTraitTypeInfo: Hashable, CustomStringConvertible {
    public let template: TraitDeclaration
    public var instantiations: [[SymbolType]: SymbolType] = [:]

    public var name: String { template.name }

    public init(template: TraitDeclaration) {
        self.template = template
    }

    public var typeArguments: [GenericTypeArgument] {
        template.typeArguments
    }

    public static func == (lhs: GenericTraitTypeInfo, rhs: GenericTraitTypeInfo) -> Bool {
        lhs.template == rhs.template
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(template)
    }

    public var description: String {
        "\(template.name)\(template.typeArgumentsDescription)"
    }
}

/// Describe a union type in detail
public final class UnionTypeInfo: Hashable, CustomStringConvertible {
    let members: [SymbolType]

    public init(_ members: [SymbolType]) {
        self.members = members
    }

    public var correspondingConstType: UnionTypeInfo {
        UnionTypeInfo(members.map({ $0.correspondingConstType }))
    }

    public var correspondingMutableType: UnionTypeInfo {
        UnionTypeInfo(members.map({ $0.correspondingMutableType }))
    }

    public static func == (lhs: UnionTypeInfo, rhs: UnionTypeInfo) -> Bool {
        lhs.members == rhs.members
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(members)
    }

    public var description: String {
        members.map(\.description).joined(separator: " | ")
    }
}

public enum SymbolVisibility: Hashable, CustomStringConvertible {
    case publicVisibility, privateVisibility

    public var description: String {
        switch self {
        case .publicVisibility: "public"
        case .privateVisibility: "private"
        }
    }
}

public struct Symbol: Hashable {
    public let type: SymbolType
    public let storage: SymbolStorage
    public let visibility: SymbolVisibility
    public let decl: AbstractSyntaxTreeNode.ID?
    
    /// As the compiler visits the program AST, it can keep track of facts about
    /// each symbol, such as statically known values, whether it's ever assigned
    /// to, and so on.
    public let facts: Facts
    
    public struct Facts: Hashable {
        public enum InitStatus: Hashable {
            case uninitialized, maybeInitialized, initialized
        }
        var initStatus: InitStatus
        
        public init(initStatus: InitStatus = .uninitialized) {
            self.initStatus = initStatus
        }
    }

    public init(
        type: SymbolType,
        offset: Int?,
        visibility: SymbolVisibility = .privateVisibility,
        facts: Facts = Facts()
    ) {
        self.init(
            type: type,
            storage: .staticStorage(offset: offset),
            visibility: visibility,
            facts: facts
        )
    }

    public init(
        type: SymbolType,
        storage: SymbolStorage = .staticStorage(offset: nil),
        visibility: SymbolVisibility = .privateVisibility,
        decl: AbstractSyntaxTreeNode.ID? = nil,
        facts: Facts = Facts()
    ) {
        self.type = type
        self.storage = storage
        self.visibility = visibility
        self.decl = decl
        self.facts = facts
    }

    public func withType(_ type: SymbolType) -> Symbol {
        Symbol(
            type: type,
            storage: storage,
            visibility: visibility,
            decl: decl,
            facts: facts
        )
    }

    public func withStorage(_ storage: SymbolStorage) -> Symbol {
        Symbol(
            type: type,
            storage: storage,
            visibility: visibility,
            decl: decl,
            facts: facts
        )
    }

    public func withVisibility(_ visibility: SymbolVisibility) -> Symbol {
        Symbol(
            type: type,
            storage: storage,
            visibility: visibility,
            decl: decl,
            facts: facts
        )
    }
    
    public func withDecl(_ decl: AbstractSyntaxTreeNode.ID) -> Symbol {
        Symbol(
            type: type,
            storage: storage,
            visibility: visibility,
            decl: decl,
            facts: facts
        )
    }
    
    public func withFacts(_ facts: Facts) -> Symbol {
        Symbol(
            type: type,
            storage: storage,
            visibility: visibility,
            decl: decl,
            facts: facts
        )
    }
}

/// Used to form a type binding in the environment
public struct TypeRecord: Hashable, CustomStringConvertible {
    public let symbolType: SymbolType
    public let visibility: SymbolVisibility

    public var description: String {
        "TypeRecord(symbolType: \(symbolType), visibility: \(visibility))"
    }
}
/// Instances of `Env` are connected in a linked list to represent nested
/// lexical scopes.
public final class Env: Hashable {
    public var declarationOrder: [String] = []
    public var symbolTable: [String: Symbol] = [:]
    public var typeTable: [String: TypeRecord]
    public var parent: Env?

    private lazy var internalTempNameCounter: Int = 0
    private var tempNameCounter: Int {
        guard let parent else {
            let result = internalTempNameCounter
            internalTempNameCounter += 1
            return result
        }
        return parent.tempNameCounter
    }

    /// Generate a unique identifier with the specified prefix
    public func tempName(prefix: String) -> String {
        "\(prefix)\(tempNameCounter)"
    }

    /// Generate a new label name, unique in the current scope
    public func nextLabel() -> String {
        let prefix = ".L"
        var counter = 0
        var label = "\(prefix)\(counter)"
        while exists(identifier: "\(prefix)\(counter)") {
            counter += 1
            label = "\(prefix)\(counter)"
        }
        bind(identifier: label, symbol: Symbol(type: .label))
        return label
    }

    private var internalLabelNameCounter: Int = 0

    public enum FrameLookupMode: Hashable {
        case inherit
        case set(Frame)

        public var isSet: Bool {
            if case .set(_) = self {
                true
            }
            else {
                false
            }
        }
    }
    public var frameLookupMode: FrameLookupMode = .inherit
    public var frame: Frame? {
        switch frameLookupMode {
        case .inherit:
            parent?.frame

        case .set(let frame):
            frame
        }
    }
    private var stackFrameIndex: Int {
        var index = 0
        var curr: Env? = self
        repeat {
            if case .set(_) = curr?.frameLookupMode {
                index += 1
            }
            curr = curr?.parent
        } while curr != nil
        return index
    }

    public enum Breadcrumb: Hashable, CustomStringConvertible {
        case functionType(FunctionTypeInfo)
        case module(name: String, useGlobalNamespace: Bool)
        case structType(String)
        case traitType(String)

        public var description: String {
            switch self {
            case .functionType(let typ): "function(\(typ))"
            case .module(let name, let g): "module(\(name), \(g)"
            case .structType(let name): "struct(\(name))"
            case .traitType(let name): "trait(\(name))"
            }
        }

        public var name: String? {
            switch self {
            case .functionType(let typ): typ.name
            case .module(let name, _): name
            case .structType(let name): name
            case .traitType(let name): name
            }
        }

        /// Return true if this is a module that should import it's symbols into
        /// the global namespace, false if the module should not, and nil if
        /// this breadcrumb is not a module at all.
        public var useGlobalNamespace: Bool? {
            switch self {
            case .module(_, let useGlobalNamespace): useGlobalNamespace
            default: nil
            }
        }
    }

    public var breadcrumb: Breadcrumb? = nil

    public var breadcrumbs: [Breadcrumb] {
        let myBreadcrumb: [Breadcrumb] =
            if let breadcrumb { [breadcrumb] }
            else { [] }
        let trail = (parent?.breadcrumbs ?? []) + myBreadcrumb
        return trail
    }

    public var enclosingFunctionType: FunctionTypeInfo? {
        switch breadcrumb {
        case .functionType(let typ):
            typ

        case .structType, .traitType, .module:
            nil

        case .none:
            parent?.enclosingFunctionType
        }
    }

    public var modulesAlreadyImported: Set<String> = []

    private var deferredActions: [() -> Void] = []

    public init(
        parent p: Env? = nil,
        frameLookupMode s: FrameLookupMode = .inherit,
        tuples: [(String, Symbol)] = [],
        typeDict: [String: SymbolType] = [:]
    ) {
        parent = p
        frameLookupMode = s
        typeTable = typeDict.mapValues({
            TypeRecord(symbolType: $0, visibility: .privateVisibility)
        })

        for (identifier, symbol) in tuples {
            bind(identifier: identifier, symbol: symbol)
        }
    }

    public func deferAction(block: @escaping () -> Void) {
        deferredActions.append(block)
    }

    public func performDeferredActions() {
        while !deferredActions.isEmpty {
            deferredActions.removeLast()()
        }
    }

    public func exists(identifier: String, maxDepth: Int = Int.max) -> Bool {
        if nil != symbolTable[identifier] {
            true
        }
        else if maxDepth > 0 {
            parent?.exists(identifier: identifier, maxDepth: maxDepth - 1) ?? false
        }
        else {
            false
        }
    }

    public func existsAsType(identifier: String, maxDepth: Int = Int.max) -> Bool {
        if nil != typeTable[identifier] {
            true
        }
        else if maxDepth > 0 {
            parent?.existsAsType(identifier: identifier, maxDepth: maxDepth - 1) ?? false
        }
        else {
            false
        }
    }

    private func maybeResolveTypeWithScopeDepth(
        sourceAnchor: SourceAnchor? = nil,
        identifier: String
    ) -> (SymbolType, Int)? {
        if let symbolType = typeTable[identifier] {
            (symbolType.symbolType, 0)
        }
        else if let parentResolution = parent?.maybeResolveTypeWithScopeDepth(
            sourceAnchor: sourceAnchor,
            identifier: identifier
        ) {
            (parentResolution.0, parentResolution.1 + 1)
        }
        else {
            nil
        }
    }

    public func bind(identifier: String, symbol: Symbol) {
        #if false
            let offset = symbol.maybeOffset == nil ? "nil" : "\(symbol.offset)"
            let stackFrameDesc: String
            if let frame {
                stackFrameDesc = "\(frame)"
            }
            else {
                stackFrameDesc = "nil"
            }
            print(
                "\(self) -- bind \(identifier): \(symbol.type) at offset=\(offset) and stackFrame=\(stackFrameDesc)"
            )
        #endif
        symbolTable[identifier] = symbol
        if let index = declarationOrder.firstIndex(of: identifier) {
            declarationOrder.remove(at: index)
        }
        declarationOrder.append(identifier)
    }

    /// Bind an identifier to a type record, convenient creating the type record from parameters
    /// See also bind(identifier:,typeRecord:)
    public func bind(
        identifier ident: String,
        symbolType: SymbolType,
        visibility: SymbolVisibility = .privateVisibility
    ) {
        let record = TypeRecord(symbolType: symbolType, visibility: visibility)
        bind(identifier: ident, typeRecord: record)
    }

    /// Bind an identifier to a type record.
    /// A type binding allows the program to use a string identifier to name a
    /// type, and to have that binding change with the environment. That is, the
    /// same name may refer to different types in different lexical scopes.
    public func bind(identifier: String, typeRecord: TypeRecord) {
        typeTable[identifier] = typeRecord
    }
    
    /// Given an identifier, resolve the corresponding symbol, and pass that
    /// symbol to the specified block. The closure may modify the symbol, which
    /// will update it in the environment when the block returns.
    public func withSymbol(
        sourceAnchor s: SourceAnchor? = nil,
        identifier ident: String,
        block: (inout Symbol) throws -> Void
    ) throws {
        if var symbol = symbolTable[ident] {
            try block(&symbol)
            symbolTable[ident] = symbol
        }
        else if let parent {
            try parent.withSymbol(
                sourceAnchor: s,
                identifier: ident,
                block: block
            )
        }
        else {
            throw CompilerError(
                sourceAnchor: s,
                message: "use of unresolved identifier: `\(ident)'"
            )
        }
    }
    
    /// Resolve the identifier and update symbol facts in the specified block
    public func withFacts(
        _ identifier: Identifier,
        block: (inout Symbol.Facts) throws -> Void
    ) throws {
        try withFacts(
            sourceAnchor: identifier.sourceAnchor,
            identifier: identifier.identifier,
            block: block
        )
    }
    
    /// Resolve the identifier and update symbol facts in the specified block
    public func withFacts(
        sourceAnchor s: SourceAnchor? = nil,
        identifier ident: String,
        block: (inout Symbol.Facts) throws -> Void
    ) throws {
        try withSymbol(sourceAnchor: s, identifier: ident) { symbol in
            var facts = symbol.facts
            try block(&facts)
            symbol = symbol.withFacts(facts)
        }
    }

    /// Given an identifier, resolve to the corresponding symbol, or return nil
    public func maybeResolve(identifier: String) -> Symbol? {
        maybeResolveWithScopeDepth(identifier: identifier)?.0
    }

    /// Given an identifier, resolve to the corresponding symbol, or throw
    public func resolve(
        sourceAnchor: SourceAnchor? = nil,
        identifier: String
    ) throws -> Symbol {
        let resolution = maybeResolveWithStackFrameDepth(
            sourceAnchor: sourceAnchor,
            identifier: identifier
        )
        guard let resolution else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "use of unresolved identifier: `\(identifier)'"
            )
        }
        return resolution.0
    }

    /// Given an identifier, resolve the type of the corresponding symbol, if
    /// the identifier names a symbol. Return the corresponding type if the
    /// identifier names a type. Otherwise, throw an error for an unresolve
    /// identifier.
    public func resolveTypeOfIdentifier(
        sourceAnchor: SourceAnchor?,
        identifier: String
    ) throws -> SymbolType {
        if let resolution = maybeResolve(identifier: identifier) {
            resolution.type
        }
        else if let resolution = maybeResolveType(identifier: identifier) {
            resolution
        }
        else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "use of unresolved identifier: `\(identifier)'"
            )
        }
    }

    /// Given an identifier, return the corresponding symbol and the number of
    /// stack frames needed to traverse to find storage backing the symbol.
    /// Otherwise, throw an error for an unresolved identifier.
    public func resolveWithStackFrameDepth(
        sourceAnchor: SourceAnchor?,
        identifier: String
    ) throws -> (Symbol, Int) {
        let resolution = maybeResolveWithStackFrameDepth(
            sourceAnchor: sourceAnchor,
            identifier: identifier
        )
        guard let resolution else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "use of unresolved identifier: `\(identifier)'"
            )
        }
        return (resolution.0, stackFrameIndex - resolution.1)
    }

    /// Given an identifier, return the corresponding symbol and the number of
    /// steps toward the Env graph root in which we find the binding.
    /// Otherwise, return nil.
    private func maybeResolveWithStackFrameDepth(
        sourceAnchor: SourceAnchor?,
        identifier: String
    ) -> (Symbol, Int)? {
        if let symbol = symbolTable[identifier] {
            (symbol, stackFrameIndex)
        }
        else {
            parent?.maybeResolveWithStackFrameDepth(
                sourceAnchor: sourceAnchor,
                identifier: identifier
            )
        }
    }

    /// Given an identifier, return the corresponding symbol and the number of
    /// steps toward the Env graph root in which we find the binding.
    /// Otherwise, throw an error for an unresolved identifier.
    public func resolveWithScopeDepth(
        sourceAnchor: SourceAnchor? = nil,
        identifier: String
    ) throws -> (Symbol, Int) {
        let resolution = maybeResolveWithScopeDepth(identifier: identifier)
        guard let resolution else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "use of unresolved identifier: `\(identifier)'"
            )
        }
        return resolution
    }

    /// Given an identifier, return the corresponding symbol and the number of
    /// steps toward the Env graph root in which we find the binding.
    /// Otherwise, return nil.
    private func maybeResolveWithScopeDepth(identifier: String) -> (Symbol, Int)? {
        if let symbol = symbolTable[identifier] {
            (symbol, 0)
        }
        else if let parentResolution = parent?.maybeResolveWithScopeDepth(identifier: identifier) {
            (parentResolution.0, parentResolution.1 + 1)
        }
        else {
            nil
        }
    }

    /// The UUID of the AST node associated with this scope, if any
    public var associatedNodeId: AbstractSyntaxTreeNode.ID?

    public typealias ScopeIdentifier = Int

    /// Return a value which uniquely identifies the scope, i.e., this specific
    /// node in the Env graph.
    public var id: ScopeIdentifier {
        Unmanaged.passUnretained(self).toOpaque().hashValue
    }

    /// Given an identifier for a symbol or type, return the ID of the scope in
    /// which it was defined. Otherwise, return NSNotFound.
    public func lookupIdOfEnclosingScope(identifier: String) -> ScopeIdentifier {
        let scope = lookupEnclosingScope(identifier: identifier)
        let scopeID = scope?.id ?? NSNotFound
        return scopeID
    }

    /// Given an identifier for a symbol or type, return the scope in which it
    /// was defined. Otherwise, return nil.
    public func lookupEnclosingScope(identifier id: String) -> Env? {
        lookupScopeEnclosingSymbol(identifier: id) ?? lookupScopeEnclosingType(identifier: id)
    }

    /// Given a symbol identifier, return the scope in which it was defined.
    /// Otherwise, return nil.
    public func lookupScopeEnclosingSymbol(identifier: String) -> Env? {
        if symbolTable[identifier] != nil {
            self
        }
        else {
            parent?.lookupScopeEnclosingSymbol(identifier: identifier)
        }
    }

    /// Given a type identifier, return the the scope in which it was defined.
    public func lookupScopeEnclosingType(identifier: String) -> Env? {
        if typeTable[identifier] != nil {
            self
        }
        else {
            parent?.lookupScopeEnclosingType(identifier: identifier)
        }
    }

    /// Given an identifier, return the type to which it refers.
    /// Otherwise, throw an error for an undeclared type.
    public func resolveType(
        sourceAnchor: SourceAnchor? = nil,
        identifier: String
    ) throws -> SymbolType {
        let type = maybeResolveType(identifier: identifier)
        guard let type else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "use of undeclared type `\(identifier)'"
            )
        }
        return type
    }

    /// Given an identifier, return the type to which it refers, or nil.
    public func maybeResolveType(
        identifier id: String,
        maxDepth: Int = Int.max
    ) -> SymbolType? {
        let maybeResolution = maybeResolveTypeWithScopeDepth(
            identifier: id,
            maxDepth: maxDepth
        )
        return maybeResolution?.0
    }

    /// Given a type identifier, return the type to which it refers as well as
    /// the number of nested scopes between the current scope and the one in
    /// which the type was declared, e.g., the scope depth fo the type binding.
    private func maybeResolveTypeWithScopeDepth(
        identifier: String,
        maxDepth: Int = Int.max
    ) -> (SymbolType, Int)? {
        if let typeRecord = typeTable[identifier] {
            (typeRecord.symbolType, stackFrameIndex)
        }
        else if maxDepth > 0 {
            parent?.maybeResolveTypeWithScopeDepth(
                identifier: identifier,
                maxDepth: maxDepth - 1
            )
        }
        else {
            nil
        }
    }

    /// Given a type identifier, return the corresponding type record, or throw
    /// an error for an undeclared type.
    public func resolveTypeRecord(
        sourceAnchor: SourceAnchor?,
        identifier: String
    ) throws -> TypeRecord {
        let typeRecord = maybeResolveTypeRecord(
            sourceAnchor: sourceAnchor,
            identifier: identifier
        )
        guard let typeRecord else {
            throw CompilerError(
                sourceAnchor: sourceAnchor,
                message: "use of undeclared type `\(identifier)'"
            )
        }
        return typeRecord
    }

    /// Given a type identifier, return the corresponding type record, or nil.
    private func maybeResolveTypeRecord(
        sourceAnchor: SourceAnchor?,
        identifier: String
    ) -> TypeRecord? {
        if let typeRecord = typeTable[identifier] {
            typeRecord
        }
        else {
            parent?.maybeResolveTypeRecord(
                sourceAnchor: sourceAnchor,
                identifier: identifier
            )
        }
    }

    public static func == (lhs: Env, rhs: Env) -> Bool {
        guard lhs.declarationOrder == rhs.declarationOrder else { return false }
        guard lhs.symbolTable == rhs.symbolTable else { return false }
        guard lhs.typeTable == rhs.typeTable else { return false }
        guard lhs.parent == rhs.parent else { return false }
        guard lhs.breadcrumb == rhs.breadcrumb else { return false }
        guard lhs.frameLookupMode == rhs.frameLookupMode else { return false }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(declarationOrder)
        hasher.combine(symbolTable)
        hasher.combine(typeTable)
        hasher.combine(parent)
        hasher.combine(breadcrumb)
        hasher.combine(frameLookupMode)
    }

    public func clone() -> Env {
        let result = Env()
        result.declarationOrder = declarationOrder
        result.symbolTable = symbolTable
        result.typeTable = typeTable
        result.parent = parent
        result.frameLookupMode = frameLookupMode
        result.breadcrumb = breadcrumb
        result.modulesAlreadyImported = modulesAlreadyImported
        return result
    }

    public func clear() {
        if case .set(let frame) = frameLookupMode {
            frame.reset()
        }
        declarationOrder = []
        symbolTable.removeAll()
        typeTable.removeAll()
        modulesAlreadyImported = []
        breadcrumb = nil
        deferredActions.removeAll()
    }
}

extension SymbolType {
    /// Return true if the type includes a Module type somewhere in the def'n
    public func hasModule(
        _ sym: Env,
        _ workingSet: [SymbolType] = []
    ) throws -> Bool {

        guard !workingSet.contains(self) else { return false }

        let typeChecker = TypeContextTypeChecker(symbols: sym)

        let anyExprHasModule: ([Expression]) throws -> Bool = { exprs in
            let result =
                try exprs
                .compactMap {
                    try? typeChecker.check(expression: $0)
                }
                .first {
                    try $0.hasModule(sym, workingSet.union(self))
                }
            return result != nil
        }

        return switch self {
        case .void, .booleanType, .arithmeticType, .label:
            false

        case .function(let typ):
            try typ.arguments.first {
                try $0.hasModule(sym, workingSet.union(self))
            } != nil

        case .genericFunction(let typ):
            try anyExprHasModule(typ.arguments + typ.typeArguments)

        case .array(count: _, let elementType),
            .constDynamicArray(let elementType),
            .dynamicArray(let elementType),
            .constPointer(let elementType),
            .pointer(let elementType):
            try elementType.hasModule(sym, workingSet.union(self))

        case .constStructType(let typ), .structType(let typ):
            try typ.fields.symbolTable.map(\.value.type).first {  // This specifically ignores methods.
                try $0.hasModule(sym, workingSet.union(self))
            } != nil || typ.isModule

        case .genericStructType(let typ):
            try anyExprHasModule(typ.typeArguments)

        case .constTraitType(let typ), .traitType(let typ):
            try typ.members.map(\.type).first {
                try $0.hasModule(sym, workingSet.union(self))
            } != nil

        case .genericTraitType(let typ):
            try anyExprHasModule(typ.typeArguments)

        case .unionType(let typ):
            try typ.members.first {
                try $0.hasModule(sym, workingSet.union(self))
            } != nil
        }
    }
}

extension Array where Element: Equatable {
    fileprivate func union(_ newElement: Element) -> [Element] {
        if contains(newElement) {
            self
        }
        else {
            self + [newElement]
        }
    }
}
