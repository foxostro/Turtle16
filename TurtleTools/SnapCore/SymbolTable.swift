//
//  SymbolTable.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore

public indirect enum SymbolType: Equatable, Hashable, CustomStringConvertible {
    case void
    case function(FunctionType)
    case genericFunction(Expression.GenericFunctionType)
    case booleanType(BooleanType)
    case arithmeticType(ArithmeticType)
    case array(count: Int?, elementType: SymbolType)
    case constDynamicArray(elementType: SymbolType), dynamicArray(elementType: SymbolType)
    case constPointer(SymbolType), pointer(SymbolType)
    case constStructType(StructType), structType(StructType)
    case genericStructType(GenericStructType)
    case constTraitType(TraitType), traitType(TraitType)
    case genericTraitType(GenericTraitType)
    case unionType(UnionType)
    case label
    
    public var isPrimitive: Bool {
        switch self {
        case .void, .booleanType, .arithmeticType, .pointer, .constPointer, .label:
            return true
        
        default:
            return false
        }
    }
    
    public var isConst: Bool {
        switch self {
        case .void, .function, .label:
            return true
        case .booleanType(let typ):
            return typ.isConst
        case .arithmeticType(let typ):
            return typ.isConst
        case .constDynamicArray, .constPointer, .constStructType, .constTraitType:
            return true
        default:
            return false
        }
    }
    
    public var correspondingConstType: SymbolType {
        switch self {
        case .booleanType:
            return .constBool
        case .arithmeticType(let arithmeticType):
            return .arithmeticType(.immutableInt(arithmeticType.intClass!))
        case .array(count: let n, elementType: let typ):
            return .array(count: n, elementType: typ.correspondingConstType)
        case .dynamicArray(elementType: let typ):
            return .constDynamicArray(elementType: typ)
        case .structType(let typ):
            return .constStructType(typ)
        case .pointer(let typ):
            return .constPointer(typ)
        case .unionType(let typ):
            return .unionType(typ.correspondingConstType)
        case .traitType(let typ):
            return .constTraitType(typ)
        default:
            return self
        }
    }
    
    public var correspondingMutableType: SymbolType {
        switch self {
        case .booleanType:
            return .bool
        case .arithmeticType(let arithmeticType):
            return .arithmeticType(.mutableInt(arithmeticType.intClass!))
        case .array(count: let n, elementType: let typ):
            return .array(count: n, elementType: typ.correspondingMutableType)
        case .constDynamicArray(elementType: let typ):
            return .dynamicArray(elementType: typ)
        case .constStructType(let typ):
            return .structType(typ)
        case .constPointer(let typ):
            return .pointer(typ)
        case .unionType(let typ):
            return .unionType(typ.correspondingMutableType)
        case .constTraitType(let typ):
            return .traitType(typ)
        default:
            return self
        }
    }
    
    public func unwrapGenericFunctionType() -> Expression.GenericFunctionType {
        switch self {
        case .genericFunction(let typ):
            return typ
        default:
            abort()
        }
    }
    
    public func unwrapPointerType() -> SymbolType {
        switch self {
        case .pointer(let typ), .constPointer(let typ):
            return typ
        default:
            abort()
        }
    }
    
    public func unwrapFunctionType() -> FunctionType {
        maybeUnwrapFunctionType()!
    }
    
    public func maybeUnwrapFunctionType() -> FunctionType? {
        switch self {
        case .function(let typ):
            typ
        default:
            nil
        }
    }
    
    public func unwrapStructType() -> StructType {
        maybeUnwrapStructType()!
    }
    
    public func maybeUnwrapStructType() -> StructType? {
        switch self {
        case .constStructType(let typ), .structType(let typ):
            typ
        default:
            nil
        }
    }
    
    public func unwrapGenericStructType() -> GenericStructType {
        maybeUnwrapGenericStructType()!
    }
    
    public func maybeUnwrapGenericStructType() -> GenericStructType? {
        switch self {
        case .genericStructType(let typ):
            typ
        default:
            nil
        }
    }
    
    public func unwrapTraitType() -> TraitType {
        maybeUnwrapTraitType()!
    }
    
    public func maybeUnwrapTraitType() -> TraitType? {
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
    
    public func unwrapGenericTraitType() -> GenericTraitType {
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
            return true
        default:
            return false
        }
    }
    
    public var isBooleanType: Bool {
        switch self {
        case .booleanType:
            return true
        default:
            return false
        }
    }
    
    public var isArithmeticType: Bool {
        switch self {
        case .arithmeticType:
            return true
        default:
            return false
        }
    }
    
    public var isPointerType: Bool {
        switch self {
        case .pointer, .constPointer:
            return true
        default:
            return false
        }
    }
    
    public var isStructType: Bool {
        maybeUnwrapStructType() != nil
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
        case .array(count: let count, elementType: _):
            return count
        default:
            abort()
        }
    }
    
    public var arrayElementType: SymbolType {
        switch self {
        case .array(count: _, elementType: let elementType):
            return elementType
        case .constDynamicArray(elementType: let elementType), .dynamicArray(elementType: let elementType):
            return elementType
        default:
            abort()
        }
    }
    
    public var description: String {
        switch self {
        case .void:
            return "void"
        case .booleanType(let a):
            return "\(a)"
        case .arithmeticType(let arithmeticType):
            return "\(arithmeticType)"
        case .array(count: let count, elementType: let elementType):
            if let count = count {
                return "[\(count)]\(elementType)"
            } else {
                return "[_]\(elementType)"
            }
        case .constDynamicArray(elementType: let elementType):
            return "const []\(elementType)"
        case .dynamicArray(elementType: let elementType):
            return "[]\(elementType)"
        case .function(let functionType):
            return functionType.description
        case .genericFunction(let genericFunctionType):
            return genericFunctionType.description
        case .constStructType(let typ):
            return "const \(typ.name)"
        case .structType(let typ):
            return "\(typ.name)"
        case .genericStructType(let typ):
            return "\(typ.description)"
        case .constTraitType(let typ):
            return "const \(typ.name)"
        case .traitType(let typ):
            return "\(typ.name)"
        case .genericTraitType(let genericTraitType):
            return genericTraitType.description
        case .constPointer(let pointee):
            return "const *\(pointee.description)"
        case .pointer(let pointee):
            return "*\(pointee.description)"
        case .unionType(let typ):
            return typ.description
        case .label:
            return "label"
        }
    }
    
    public var lift: Expression { // TODO: Remove the `SymbolType.lift` property entirely
        switch self {
        case .void:
            Expression.PrimitiveType(.void)
            
        case .function(let typ):
            Expression.FunctionType(
                name: typ.name,
                returnType: typ.returnType.lift,
                arguments: typ.arguments.map { $0.lift })
            
        case .genericFunction(let typ):
            Expression.GenericFunctionType(
                template: typ.template,
                enclosingImplId: typ.enclosingImplId)
            
        case .booleanType(let typ):
            switch typ {
            case .compTimeBool(let val):
                Expression.LiteralBool(val)
            case .immutableBool:
                Expression.ConstType(Expression.PrimitiveType(.bool))
            case .mutableBool:
                Expression.PrimitiveType(.bool)
            }
            
        case .arithmeticType(let typ):
            switch typ {
            case .compTimeInt(let val):
                Expression.LiteralInt(val)
            case .immutableInt(let cls):
                Expression.ConstType(Expression.PrimitiveType(.arithmeticType(.mutableInt(cls))))
            case .mutableInt(let cls):
                Expression.PrimitiveType(.arithmeticType(.mutableInt(cls)))
            }
            
        case .array(count: let count, elementType: let elementType):
            Expression.ArrayType(
                count: count == nil ? nil : Expression.LiteralInt(count!),
                elementType: elementType.lift)
            
        case .constDynamicArray(elementType: let elementType):
            Expression.ConstType(Expression.DynamicArrayType(elementType.lift))
            
        case .dynamicArray(elementType: let elementType):
            Expression.DynamicArrayType(elementType.lift)
            
        case .constPointer(let typ):
            Expression.ConstType(Expression.PointerType(typ.correspondingMutableType.lift))
            
        case .pointer(let typ):
            Expression.PointerType(typ.lift)
            
        case .constStructType:
            Expression.ConstType(Expression.PrimitiveType(self.correspondingMutableType))
                                 
        case .structType:
            Expression.PrimitiveType(self)
            
        case .genericStructType:
            Expression.PrimitiveType(self)
            
        case .constTraitType:
            Expression.ConstType(Expression.PrimitiveType(self.correspondingMutableType))
            
        case .traitType(let typ):
            Expression.Identifier(typ.name)
            
        case .genericTraitType(let typ):
            Expression.Identifier(typ.name)
            
        case .unionType(let typ):
            Expression.UnionType(typ.members.map { $0.lift })
            
        case .label:
            fatalError("cannot lift a label")
        }
    }
    
    public static let u8:  SymbolType = .arithmeticType(.mutableInt(.u8))
    public static let u16: SymbolType = .arithmeticType(.mutableInt(.u16))
    public static let i8:  SymbolType = .arithmeticType(.mutableInt(.i8))
    public static let i16: SymbolType = .arithmeticType(.mutableInt(.i16))
    
    public static let constU8:  SymbolType = .arithmeticType(.immutableInt(.u8))
    public static let constU16: SymbolType = .arithmeticType(.immutableInt(.u16))
    public static let constI8:  SymbolType = .arithmeticType(.immutableInt(.i8))
    public static let constI16: SymbolType = .arithmeticType(.immutableInt(.i16))
    
    public static let bool: SymbolType = .booleanType(.mutableBool)
    public static let constBool: SymbolType = .booleanType(.immutableBool)
}

public enum SymbolStorage: Equatable {
    case staticStorage, automaticStorage
}

public enum BooleanType: Equatable, Hashable, CustomStringConvertible {
    case mutableBool, immutableBool, compTimeBool(Bool)
    
    public func canValueBeTriviallyReinterpretedAs(type: BooleanType) -> Bool {
        return !(self.isCompTime || type.isCompTime)
    }
    
    public var isCompTime: Bool {
        switch self {
        case .compTimeBool:
            return true
            
        case .immutableBool, .mutableBool:
            return false
        }
    }
    
    public var isConst: Bool {
        switch self {
        case .mutableBool:
            return false
            
        case .immutableBool, .compTimeBool:
            return true
        }
    }
    
    public var description: String {
        switch self {
        case .mutableBool:
            return "bool"
            
        case .immutableBool:
            return "const bool"
            
        case .compTimeBool(let a):
            return "boolean constant \(a)"
        }
    }
}

public enum IntClass: Equatable, Hashable, CustomStringConvertible, CaseIterable {
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
            return true
            
        case .u8, .u16:
            return false
        }
    }
    
    public var description: String {
        switch self {
        case .i8:
            return "i8"
            
        case .i16:
            return "i16"
            
        case .u8:
            return "u8"
            
        case .u16:
            return "u16"
        }
    }
    
    public var min: Int {
        switch self {
        case .i8:
            return -128
            
        case .i16:
            return -32768
            
        case .u8:
            return 0
            
        case .u16:
            return 0
        }
    }
    
    public var max: Int {
        switch self {
        case .i8:
            return 127
            
        case .i16:
            return 32767
            
        case .u8:
            return 255
            
        case .u16:
            return 65535
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

public enum ArithmeticType: Equatable, Hashable, CustomStringConvertible {
    case mutableInt(IntClass), immutableInt(IntClass), compTimeInt(Int)
    
    public static func binaryResultType(left: ArithmeticType, right: ArithmeticType) -> ArithmeticType? {
        if let intClass = IntClass.binaryResultType(left: left.intClass, right: right.intClass) {
            return .mutableInt(intClass)
        }
        else {
            return nil
        }
    }
    
    public var intClass: IntClass? {
        switch self {
        case .mutableInt(let a), .immutableInt(let a):
            return a
            
        case .compTimeInt(let value):
            return IntClass.smallestClassContaining(value: value)
        }
    }
    
    public var min: Int {
        switch self {
        case .compTimeInt(let constantValue):
            return constantValue
            
        case .mutableInt(let a), .immutableInt(let a):
            return a.min
        }
    }
    
    public var max: Int {
        switch self {
        case .compTimeInt(let constantValue):
            return constantValue
            
        case .mutableInt(let a), .immutableInt(let a):
            return a.max
        }
    }
    
    public func canValueBeTriviallyReinterpretedAs(type dst: ArithmeticType) -> Bool {
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
            return true
            
        case .mutableInt, .immutableInt:
            return false
        }
    }
    
    public var isConst: Bool {
        switch self {
        case .mutableInt:
            return false
            
        case .immutableInt, .compTimeInt:
            return true
        }
    }
    
    public var description: String {
        switch self {
        case .mutableInt(let width):
            return "\(width)"
            
        case .immutableInt(let width):
            return "const \(width)"
            
        case .compTimeInt(let value):
            return "integer constant \(value)"
        }
    }
}

public final class FunctionType: Equatable, Hashable, CustomStringConvertible {
    public let name: String?
    public let mangledName: String?
    public let returnType: SymbolType
    public let arguments: [SymbolType]
    public var ast: FunctionDeclaration?
    
    public convenience init(returnType: SymbolType, arguments: [SymbolType]) {
        self.init(name: nil,
                  mangledName: nil,
                  returnType: returnType,
                  arguments: arguments)
    }
    
    public convenience init(
        name: String,
        returnType: SymbolType,
        arguments: [SymbolType]
    ) {
        self.init(name: name,
                  mangledName: name,
                  returnType: returnType,
                  arguments: arguments)
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
        arguments.map({$0.description}).joined(separator: ", ")
    }
    
    public static func ==(lhs: FunctionType, rhs: FunctionType) -> Bool {
        guard type(of: lhs) == type(of: rhs) else { return false }
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
    
    public func eraseName() -> FunctionType {
        FunctionType(name: nil,
                     mangledName: nil,
                     returnType: returnType,
                     arguments: arguments,
                     ast: ast)
    }
    
    public func withBody(_ body: Block) -> FunctionType {
        FunctionType(name: name,
                     mangledName: mangledName,
                     returnType: returnType,
                     arguments: arguments,
                     ast: ast?.withBody(body))
    }
    
    public func withName(_ name: String) -> FunctionType {
        FunctionType(name: name,
                     mangledName: mangledName,
                     returnType: returnType,
                     arguments: arguments,
                     ast: ast)
    }
}

public final class StructType: Equatable, Hashable, CustomStringConvertible {
    public let name: String
    public let symbols: SymbolTable
    
    /// If the struct was synthesized to represent a Trait then this is the
    /// name of the associated trait, else nil.
    public let associatedTraitType: String?
    
    /// If the struct was synthesized to represent a Module then this is the
    /// name of the associated module, else nil.
    public let associatedModuleName: String?
    
    /// Indicates whether the struct was synthesized to represent a Module
    public var isModule: Bool { associatedModuleName != nil }
    
    public init(name: String,
                symbols: SymbolTable,
                associatedTraitType: String? = nil,
                associatedModuleName: String? = nil) {
        self.name = name
        self.symbols = symbols
        self.associatedTraitType = associatedTraitType
        self.associatedModuleName = associatedModuleName
    }
    
    public func clone() -> StructType {
        StructType(name: name,
                   symbols: symbols.clone(),
                   associatedTraitType: associatedTraitType,
                   associatedModuleName: associatedModuleName)
    }
    
    public func withAssociatedModule(_ associatedModuleName: String?) -> StructType {
        StructType(name: name,
                   symbols: symbols.clone(),
                   associatedTraitType: associatedTraitType,
                   associatedModuleName: associatedModuleName)
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
        var members: [String] = []
        for (name, symbol) in symbols.symbolTable {
            members.append("\(name): \(symbol.type)")
        }
        let result = members.map({"\t\t\($0)"}).joined(separator: "\n")
        return result
    }
    
    public static func ==(lhs: StructType, rhs: StructType) -> Bool {
        lhs.isEqual(rhs)
    }
    
    private var isDoingEqualityTest = false
    
    private func isEqual(_ rhs: StructType) -> Bool {
        // Avoid recursive comparisons. These can occur if a trait contains a
        // method with a parameter whose type is a pointer to the trait. If we
        // don't detect these cases then we get infinite recursion.
        guard !isDoingEqualityTest else { return true }
        isDoingEqualityTest = true
        defer { isDoingEqualityTest = false }
        
        guard name == rhs.name else { return false }
        
        // TODO: StructType can persist in the AST across compiler passes. This makes it possible to have an AST node which refers to an outdated version of StructType from a previous compiler pass. To work around this, we're forced to ignore function symbols when comparing the two StructType instances. It might be better to instead refuse to ever put fully resolved struct types into the AST at all. This jives with other plans I've written about involving replacing SymbolType with type expressions completely.
        #if false
        guard symbols == rhs.symbols else { return false }
        #else
        guard symbols.isEqualExceptFunctions(rhs.symbols) else { return false }
        guard associatedTraitType == rhs.associatedTraitType else { return false }
        guard associatedModuleName == rhs.associatedModuleName else { return false }
        #endif
        
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
        
        hasher.combine(symbols)
        hasher.combine(associatedTraitType)
        hasher.combine(associatedModuleName)
    }
}

public final class GenericStructType: Equatable, Hashable, CustomStringConvertible {
    public let template: StructDeclaration
    public var instantiations: [ [SymbolType] : SymbolType ] = [:]
    
    public var name: String { template.name }
    
    // Compilation of Impl nodes is deferred until the generic struct is
    // instantiated with concrete types.
    public var implNodes: [Impl] = []
    
    // Compilation of ImplFor nodes is deferred until the generic struct is
    // instantiated with concrete types.
    public var implForNodes: [ImplFor] = []
    
    public func clone() -> GenericStructType {
        GenericStructType(template: template)
    }
    
    public init(template: StructDeclaration) {
        self.template = template
    }
    
    public var typeArguments: [Expression.Identifier] {
        template.typeArguments.map(\.identifier)
    }
    
    public var description: String {
        return "\(template.name)\(template.typeArgumentsDescription)"
    }
    
    public static func ==(lhs: GenericStructType, rhs: GenericStructType) -> Bool {
        guard lhs.template == rhs.template else { return false }
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(template)
    }
}

public final class TraitType: Equatable, Hashable, CustomStringConvertible {
    public let name: String
    public let symbols: SymbolTable
    public let nameOfTraitObjectType: String
    public let nameOfVtableType: String
    
    public init(
        name: String,
        nameOfTraitObjectType: String,
        nameOfVtableType: String,
        symbols: SymbolTable
    ) {
        self.name = name
        self.nameOfTraitObjectType = nameOfTraitObjectType
        self.nameOfVtableType = nameOfVtableType
        self.symbols = symbols
    }
    
    public static func ==(lhs: TraitType, rhs: TraitType) -> Bool {
        lhs.isEqual(rhs)
    }
    
    private var isDoingEqualityTest = false
    
    private func isEqual(_ rhs: TraitType) -> Bool {
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
        members.map { name, type in
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

public final class GenericTraitType: Equatable, Hashable, CustomStringConvertible {
    public let template: TraitDeclaration
    public var instantiations: [ [SymbolType] : SymbolType ] = [:]
    
    public var name: String { template.name }
    
    public init(template: TraitDeclaration) {
        self.template = template
    }
    
    public var typeArguments: [Expression.GenericTypeArgument] {
        template.typeArguments
    }
    
    public static func ==(lhs: GenericTraitType, rhs: GenericTraitType) -> Bool {
        guard lhs.template == rhs.template else { return false }
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(template)
    }
    
    public var description: String {
        "\(template.name)\(template.typeArgumentsDescription)"
    }
}

public class UnionType: NSObject {
    let members: [SymbolType]
    
    public init(_ members: [SymbolType]) {
        self.members = members
    }
    
    public override var description: String {
        let result = members.map({"\($0)"}).joined(separator: " | ")
        return result
    }
    
    public static func ==(lhs: UnionType, rhs: UnionType) -> Bool {
        lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? UnionType else {
            return false
        }
        guard members == rhs.members else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(members)
        return hasher.finalize()
    }
    
    public var correspondingConstType: UnionType {
        return UnionType(members.map({$0.correspondingConstType}))
    }
    
    public var correspondingMutableType: UnionType {
        return UnionType(members.map({$0.correspondingMutableType}))
    }
}

public enum SymbolVisibility: Equatable {
    case publicVisibility
    case privateVisibility
    
    public var description: String {
        switch self {
        case .publicVisibility:  return "public"
        case .privateVisibility: return "private"
        }
    }
}

public struct Symbol: Hashable, Equatable {
    public let type: SymbolType
    public let maybeOffset: Int?
    public var offset: Int {
        maybeOffset!
    }
    public let storage: SymbolStorage
    public let visibility: SymbolVisibility
    
    public init(type: SymbolType, offset: Int? = nil, storage: SymbolStorage = .staticStorage, visibility: SymbolVisibility = .privateVisibility) {
        self.type = type
        self.maybeOffset = offset
        self.storage = storage
        self.visibility = visibility
    }
    
    public func withOffset(_ offset: Int?) -> Symbol {
        return Symbol(type: type,
                      offset: offset,
                      storage: storage,
                      visibility: visibility)
    }
    
    public func withType(_ type: SymbolType) -> Symbol {
        return Symbol(type: type,
                      offset: maybeOffset,
                      storage: storage,
                      visibility: visibility)
    }
}

// Maps a name to symbol information.
public final class SymbolTable: NSObject {
    public struct TypeRecord: Hashable, Equatable {
        let symbolType: SymbolType
        let visibility: SymbolVisibility
    }
    public var declarationOrder: [String] = []
    public var symbolTable: [String:Symbol] = [:]
    public var typeTable: [String:TypeRecord]
    public var parent: SymbolTable?
    
    private lazy var internalTempNameCounter: Int = 0
    private var tempNameCounter: Int {
        if let parent {
            return parent.tempNameCounter
        }
        else {
            let result = internalTempNameCounter
            internalTempNameCounter += 1
            return result
        }
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
    
    public enum FrameLookupMode: Hashable, Equatable {
        case inherit, set(Frame)
        
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
        var curr: SymbolTable? = self
        repeat {
            if case .set(_) = curr?.frameLookupMode {
                index += 1
            }
            curr = curr?.parent
        } while curr != nil
        return index
    }
    
    public enum Breadcrumb: Hashable, Equatable, CustomStringConvertible {
        case functionType(FunctionType)
        case module(name: String, useGlobalNamespace: Bool)
        case structType(String)
        case traitType(String)
        
        public var description: String {
            switch self {
            case .functionType(let typ):   "function(\(typ.description))"
            case .module(let name, let g): "module(\(name), \(g)"
            case .structType(let name):    "struct(\(name))"
            case .traitType(let name):     "trait(\(name))"
            }
        }
        
        public var name: String? {
            switch self {
            case .functionType(let typ): typ.name
            case .module(let name, _):   name
            case .structType(let name):  name
            case .traitType(let name):   name
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
        let myBreadcrumb: [Breadcrumb] = if let breadcrumb { [breadcrumb] } else { [] }
        let trail = (parent?.breadcrumbs ?? []) + myBreadcrumb
        return trail
    }
    
    public var enclosingFunctionType: FunctionType? {
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
    
    public init(parent p: SymbolTable? = nil, frameLookupMode s: FrameLookupMode = .inherit, tuples: [(String, Symbol)] = [], typeDict: [String:SymbolType] = [:]) {
        parent = p
        frameLookupMode = s
        typeTable = typeDict.mapValues({TypeRecord(symbolType: $0, visibility: .privateVisibility)})
        
        super.init()
        
        for (identifier, symbol) in tuples {
            bind(identifier: identifier, symbol: symbol)
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
    
    private func maybeResolveTypeWithScopeDepth(sourceAnchor: SourceAnchor? = nil, identifier: String) -> (SymbolType, Int)? {
        if let symbolType = typeTable[identifier] {
            return (symbolType.symbolType, 0)
        } else if let parentResolution = parent?.maybeResolveTypeWithScopeDepth(sourceAnchor: sourceAnchor, identifier: identifier) {
            return (parentResolution.0, parentResolution.1 + 1)
        }
        return nil
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
        print("\(self) -- bind \(identifier): \(symbol.type) at offset=\(offset) and stackFrame=\(stackFrameDesc)")
#endif
        symbolTable[identifier] = symbol
        if let index = declarationOrder.firstIndex(of: identifier) {
            declarationOrder.remove(at: index)
        }
        declarationOrder.append(identifier)
    }
    
    public func bind(identifier: String, symbolType: SymbolType, visibility: SymbolVisibility = .privateVisibility) {
        typeTable[identifier] = TypeRecord(symbolType: symbolType, visibility: visibility)
    }
    
    public func resolve(identifier: String) throws -> Symbol {
        return try resolve(sourceAnchor: nil, identifier: identifier)
    }
    
    public func maybeResolve(identifier: String) -> Symbol? {
        let maybeResolution: (Symbol, Int)? = maybeResolveWithScopeDepth(sourceAnchor: nil, identifier: identifier)
        return maybeResolution?.0
    }
    
    public func resolve(sourceAnchor: SourceAnchor?, identifier: String) throws -> Symbol {
        guard let resolution = maybeResolveWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier) else {
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "use of unresolved identifier: `\(identifier)'")
        }
        return resolution.0
    }
    
    public func resolveTypeOfIdentifier(sourceAnchor: SourceAnchor?, identifier: String) throws -> SymbolType {
        if let resolution = maybeResolveWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier) {
            return resolution.0.type
        }
        if let resolution = maybeResolveTypeWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier) {
            return resolution.0
        }
        throw CompilerError(sourceAnchor: sourceAnchor, message: "use of unresolved identifier: `\(identifier)'")
    }
    
    public func resolveWithStackFrameDepth(sourceAnchor: SourceAnchor?, identifier: String) throws -> (Symbol, Int) {
        guard let resolution = maybeResolveWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier) else {
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "use of unresolved identifier: `\(identifier)'")
        }
        return (resolution.0, stackFrameIndex - resolution.1)
    }
    
    private func maybeResolveWithStackFrameDepth(sourceAnchor: SourceAnchor?, identifier: String) -> (Symbol, Int)? {
        if let symbol = symbolTable[identifier] {
            return (symbol, stackFrameIndex)
        }
        return parent?.maybeResolveWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier)
    }
    
    public func resolveWithScopeDepth(sourceAnchor: SourceAnchor? = nil, identifier: String) throws -> (Symbol, Int) {
        guard let resolution = maybeResolveWithScopeDepth(sourceAnchor: sourceAnchor, identifier: identifier) else {
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "use of unresolved identifier: `\(identifier)'")
        }
        return resolution
    }
    
    private func maybeResolveWithScopeDepth(sourceAnchor: SourceAnchor? = nil, identifier: String) -> (Symbol, Int)? {
        if let symbol = symbolTable[identifier] {
            return (symbol, 0)
        } else if let parentResolution = parent?.maybeResolveWithScopeDepth(sourceAnchor: sourceAnchor, identifier: identifier) {
            return (parentResolution.0, parentResolution.1 + 1)
        }
        return nil
    }
    
    /// The UUID of the AST node associated with this scope, if any
    public var associatedNodeId: AbstractSyntaxTreeNode.ID?
    
    /// Return an Int which uniquely identifies this specific symbol table
    public var id: Int {
        Unmanaged.passUnretained(self).toOpaque().hashValue
    }
    
    public typealias ScopeIdentifier = Int
    
    /// Given an identifier for a symbol or type, return the ID of the scope in which it was defined
    public func lookupIdOfEnclosingScope(identifier id: String) -> ScopeIdentifier {
        let scope = lookupEnclosingScope(identifier: id)
        let scopeID = scope?.id ?? NSNotFound
        return scopeID
    }
    
    /// Given an identifier for a symbol or type, return the scope in which it was defined
    public func lookupEnclosingScope(identifier id: String) -> SymbolTable? {
        lookupScopeEnclosingSymbol(identifier: id) ?? lookupScopeEnclosingType(identifier: id)
    }
    
    /// Given a symbol identifier, return the scope in which it was defined
    public func lookupScopeEnclosingSymbol(identifier: String) -> SymbolTable? {
        if let _ = symbolTable[identifier] {
            self
        }
        else {
            parent?.lookupScopeEnclosingSymbol(identifier: identifier)
        }
    }
    
    /// Given a type identifier, return the the scope in which it was defined
    public func lookupScopeEnclosingType(identifier: String) -> SymbolTable? {
        if let _ = typeTable[identifier] {
            self
        }
        else {
            parent?.lookupScopeEnclosingType(identifier: identifier)
        }
    }
    
    public func maybeResolveType(
        sourceAnchor: SourceAnchor? = nil,
        identifier: String,
        maxDepth: Int = Int.max
    ) -> SymbolType? {
        let maybeResolution = maybeResolveTypeWithStackFrameDepth(
            sourceAnchor: sourceAnchor,
            identifier: identifier,
            maxDepth: maxDepth)
        return maybeResolution?.0
    }
    
    public func resolveType(sourceAnchor: SourceAnchor? = nil, identifier: String) throws -> SymbolType {
        guard let resolution = maybeResolveTypeWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier) else {
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "use of undeclared type `\(identifier)'")
        }
        return resolution.0
    }
    
    private func maybeResolveTypeWithStackFrameDepth(
        sourceAnchor: SourceAnchor?,
        identifier: String,
        maxDepth: Int = Int.max
    ) -> (SymbolType, Int)? {
        if let symbolRecord = typeTable[identifier] {
            (symbolRecord.symbolType, stackFrameIndex)
        }
        else if maxDepth > 0 {
            parent?.maybeResolveTypeWithStackFrameDepth(
                sourceAnchor: sourceAnchor,
                identifier: identifier,
                maxDepth: maxDepth - 1)
        }
        else {
            nil
        }
    }
    
    public func resolveTypeRecord(sourceAnchor: SourceAnchor?, identifier: String) throws -> TypeRecord {
        guard let resolution = maybeResolveTypeRecord(sourceAnchor: sourceAnchor, identifier: identifier) else {
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "use of undeclared type `\(identifier)'")
        }
        return resolution.0
    }
    
    private func maybeResolveTypeRecord(sourceAnchor: SourceAnchor?, identifier: String) -> (TypeRecord, Int)? {
        if let symbolRecord = typeTable[identifier] {
            return (symbolRecord, stackFrameIndex)
        }
        return parent?.maybeResolveTypeRecord(sourceAnchor: sourceAnchor, identifier: identifier)
    }
    
    public static func ==(lhs: SymbolTable, rhs: SymbolTable) -> Bool {
        lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? SymbolTable else { return false }
        guard declarationOrder == rhs.declarationOrder else { return false }
        guard symbolTable == rhs.symbolTable else { return false }
        guard typeTable == rhs.typeTable else { return false }
        guard parent == rhs.parent else { return false }
        guard breadcrumb == rhs.breadcrumb else { return false }
        guard frameLookupMode == rhs.frameLookupMode else { return false }
        return true
    }
    
    // TODO: Remove isEqualExceptFunctions(). This is part of a workaround for an issue with StructType persisting in the AST across compiler passes. This is described in more detail in StructType, above.
    public func isEqualExceptFunctions(_ rhs: SymbolTable) -> Bool {
        let rejectFunctions = { (ident: String, sym: Symbol) in
            switch sym.type {
            case .function, .genericFunction: false
            default: true
            }
        }
        guard symbolTable.filter(rejectFunctions) == rhs.symbolTable.filter(rejectFunctions) else {
            return false
        }
        guard typeTable == rhs.typeTable else {
            return false
        }
        guard parent == rhs.parent else {
            return false
        }
        guard enclosingFunctionType == rhs.enclosingFunctionType else {
            return false
        }
        guard frameLookupMode.isSet == rhs.frameLookupMode.isSet else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(declarationOrder)
        hasher.combine(symbolTable)
        hasher.combine(typeTable)
        hasher.combine(parent)
        hasher.combine(breadcrumb)
        hasher.combine(frameLookupMode)
        return hasher.finalize()
    }
    
    public func clone() -> SymbolTable {
        let result = SymbolTable()
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
    }
}

extension SymbolType {
    /// Return true if the type includes a Module type somewhere in the def'n
    public func hasModule(
        _ sym: SymbolTable,
        _ workingSet: [SymbolType] = []
    ) throws -> Bool {
        
        guard !workingSet.contains(self) else { return false }
        
        let typeChecker = TypeContextTypeChecker(symbols: sym)
        
        let anyExprHasModule: ([Expression]) throws -> Bool = { exprs in
            let result = try exprs
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
            
        case .array(count: _, elementType: let elementType),
             .constDynamicArray(elementType: let elementType),
             .dynamicArray(elementType: let elementType),
             .constPointer(let elementType),
             .pointer(let elementType):
            try elementType.hasModule(sym, workingSet.union(self))
            
        case .constStructType(let typ), .structType(let typ):
            try typ.symbols.symbolTable.map(\.value.type).first {
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

fileprivate extension Array where Element: Equatable {
    func union(_ newElement: Element) -> Array<Element> {
        if contains(newElement) {
            self
        }
        else {
            self + [newElement]
        }
    }
}
