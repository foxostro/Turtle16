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
    case bool(BooleanType)
    case arithmeticType(ArithmeticType)
    case array(count: Int?, elementType: SymbolType)
    case constDynamicArray(elementType: SymbolType), dynamicArray(elementType: SymbolType)
    case constPointer(SymbolType), pointer(SymbolType)
    case constStructType(StructType), structType(StructType)
    case genericStructType(GenericStructType)
    case constTraitType(TraitType), traitType(TraitType)
    case genericTraitType(GenericTraitType)
    case unionType(UnionType)
    
    public var isPrimitive: Bool {
        switch self {
        case .void, .bool, .arithmeticType, .pointer, .constPointer:
            return true
        
        default:
            return false
        }
    }
    
    public var isConst: Bool {
        switch self {
        case .void, .function:
            return true
        case .bool(let typ):
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
        case .bool:
            return .bool(.immutableBool)
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
        case .bool:
            return .bool(.mutableBool)
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
        switch self {
        case .function(let typ):
            return typ
        default:
            abort()
        }
    }
    
    public func unwrapStructType() -> StructType {
        switch self {
        case .constStructType(let typ), .structType(let typ):
            return typ
        default:
            abort()
        }
    }
    
    public func unwrapGenericStructType() -> GenericStructType {
        switch self {
        case .genericStructType(let typ):
            return typ
        default:
            abort()
        }
    }
    
    public func unwrapTraitType() -> TraitType {
        switch self {
        case .constTraitType(let typ), .traitType(let typ):
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
        case .bool:
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
        case .bool(let a):
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
        }
    }
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

public class FunctionType: NSObject {
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
    
    public convenience init(name: String, returnType: SymbolType, arguments: [SymbolType]) {
        self.init(name: name,
                  mangledName: name,
                  returnType: returnType,
                  arguments: arguments)
    }
    
    public init(name: String?, mangledName: String?, returnType: SymbolType, arguments: [SymbolType], ast: FunctionDeclaration? = nil) {
        self.name = name
        self.mangledName = mangledName
        self.returnType = returnType
        self.arguments = arguments
        self.ast = ast
    }
    
    public override var description: String {
        let name = self.name ?? ""
        return "func \(name)(\(argumentsDescription)) -> \(returnType)"
    }
    
    public var argumentsDescription: String {
        let result = arguments.map({$0.description}).joined(separator: ", ")
        return result
    }
    
    public static func ==(lhs: FunctionType, rhs: FunctionType) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? FunctionType else {
            return false
        }
        guard name == rhs.name else {
            return false
        }
        guard mangledName == rhs.mangledName else {
            return false
        }
        guard returnType == rhs.returnType else {
            return false
        }
        guard arguments == rhs.arguments else {
            return false
        }
//        guard ast == rhs.ast else {
//            return false
//        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(mangledName)
        hasher.combine(returnType)
        hasher.combine(arguments)
//        hasher.combine(ast)
        return hasher.finalize()
    }
    
    public func eraseName() -> FunctionType {
        return FunctionType(name: nil,
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
}

public class StructType: NSObject {
    public let name: String
    public let symbols: SymbolTable
    
    public init(name: String, symbols: SymbolTable) {
        self.name = name
        self.symbols = symbols
    }
    
    public override var description: String {
        return """
struct \(name) {
\(makeMembersDescription())
}
"""
    }
    
    public func makeMembersDescription() -> String {
        var members: [String] = []
        for (name, symbol) in symbols.symbolTable {
            members.append("\(name): \(symbol.type)")
        }
        let result = members.map({"\t\($0)"}).joined(separator: ",\n")
        return result
    }
    
    public static func ==(lhs: StructType, rhs: StructType) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    private var isDoingEqualityTest = false
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        // Avoid recursive comparisons. These can occur if a trait contains a
        // method with a parameter whose type is a pointer to the trait. If we
        // don't detect these cases then we get infinite recursion.
        guard false == isDoingEqualityTest else {
            return true
        }
        isDoingEqualityTest = true
        defer { isDoingEqualityTest = false }
        
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? StructType else {
            return false
        }
        guard name == rhs.name else {
            return false
        }
        guard symbols == rhs.symbols else {
            return false
        }
        return true
    }
    
    private var isComputingHash = false
    
    public override var hash: Int {
        // Avoid recursive computation of the hash.
        // This can occur with recursive types such as the following:
        //        struct LinkedList {
        //            next: *const LinkedList | None,
        //            key: u8,
        //            value: u8
        //        }
        guard false == isComputingHash else {
            var hasher = Hasher()
            hasher.combine(name)
            return hasher.finalize()
        }
        isComputingHash = true
        defer { isComputingHash = false }
        
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(symbols)
        return hasher.finalize()
    }
}

public class GenericStructType: NSObject {
    public let template: StructDeclaration
    public var instantiations: [ [SymbolType] : SymbolType ] = [:]
    
    // Compilation of Impl nodes is deferred until the generic struct is
    // instantiated with concrete types.
    public var implNodes: [Impl] = []
    
    // Compilation of ImplFor nodes is deferred until the generic struct is
    // instantiated with concrete types.
    public var implForNodes: [ImplFor] = []
    
    public init(template: StructDeclaration) {
        self.template = template
    }
    
    public var typeArguments: [Expression.GenericTypeArgument] {
        template.typeArguments
    }
    
    public override var description: String {
        return "\(template.name)\(template.typeArgumentsDescription)"
    }
    
    public static func ==(lhs: GenericStructType, rhs: GenericStructType) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? GenericStructType else {
            return false
        }
        guard template == rhs.template else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(template)
        return hasher.finalize()
    }
}

public class TraitType: NSObject {
    public let name: String
    public let symbols: SymbolTable
    public let nameOfTraitObjectType: String
    public let nameOfVtableType: String
    
    public init(name: String, nameOfTraitObjectType: String, nameOfVtableType: String, symbols: SymbolTable) {
        self.name = name
        self.nameOfTraitObjectType = nameOfTraitObjectType
        self.nameOfVtableType = nameOfVtableType
        self.symbols = symbols
    }
    
    public override var description: String {
        return """
trait \(name) {
\ttrait object type: \(nameOfTraitObjectType),
\tvtable type: \(nameOfVtableType),
\(makeMembersDescription())
}
"""
    }
    
    public func makeMembersDescription() -> String {
        var members: [String] = []
        for (name, symbol) in symbols.symbolTable {
            members.append("\(name): \(symbol.type)")
        }
        let result = members.map({"\t\($0)"}).joined(separator: ",\n")
        return result
    }
    
    public static func ==(lhs: TraitType, rhs: TraitType) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    private var isDoingEqualityTest = false
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        // Avoid recursive comparisons. These can occur if a trait contains a
        // method with a parameter whose type is a pointer to the trait. If we
        // don't detect these cases then we get infinite recursion.
        guard false == isDoingEqualityTest else {
            return true
        }
        isDoingEqualityTest = true
        defer { isDoingEqualityTest = false }
        
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? TraitType else {
            return false
        }
        guard name == rhs.name else {
            return false
        }
        guard nameOfVtableType == rhs.nameOfVtableType else {
            return false
        }
        guard symbols == rhs.symbols else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(nameOfVtableType)
        hasher.combine(symbols)
        return hasher.finalize()
    }
}

public class GenericTraitType: NSObject {
    public let template: TraitDeclaration
    public var instantiations: [ [SymbolType] : SymbolType ] = [:]
    
    public init(template: TraitDeclaration) {
        self.template = template
    }
    
    public var typeArguments: [Expression.GenericTypeArgument] {
        template.typeArguments
    }
    
    public override var description: String {
        return "\(template.name)\(template.typeArgumentsDescription)"
    }
    
    public static func ==(lhs: GenericTraitType, rhs: GenericTraitType) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? GenericTraitType else {
            return false
        }
        guard template == rhs.template else {
            return false
        }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(template)
        return hasher.finalize()
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
        return lhs.isEqual(rhs)
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
public class SymbolTable: NSObject {
    public struct TypeRecord: Hashable, Equatable {
        let symbolType: SymbolType
        let visibility: SymbolVisibility
    }
    public var declarationOrder: [String] = []
    public var symbolTable: [String:Symbol] = [:]
    public var typeTable: [String:TypeRecord]
    public var parent: SymbolTable?
    
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
    
    // This is a code sequence which needs to execute when entering this scope.
    // Used to insert code for setting up vtables and such.
    public var scopePrologue: Seq = Seq()
    
    public enum EnclosingFunctionType: Hashable, Equatable {
        case inherit, set(FunctionType?)
    }
    public var enclosingFunctionTypeMode: EnclosingFunctionType = .inherit
    public var enclosingFunctionType: FunctionType? {
        switch enclosingFunctionTypeMode {
        case .inherit:
            return parent?.enclosingFunctionType
            
        case .set(let val):
            return val
        }
    }
    
    public enum EnclosingFunctionName: Hashable, Equatable  {
        case inherit, set(String?)
    }
    public var enclosingFunctionNameMode: EnclosingFunctionName = .inherit
    public var enclosingFunctionName: String? {
        switch enclosingFunctionNameMode {
        case .inherit:
            return parent?.enclosingFunctionName
            
        case .set(let val):
            return val
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
    
    public func exists(identifier: String) -> Bool {
        if nil == symbolTable[identifier] {
            return parent?.exists(identifier: identifier) ?? false
        }
        return true
    }
    
    public func existsAsType(identifier: String) -> Bool {
        if nil == typeTable[identifier] {
            return parent?.existsAsType(identifier: identifier) ?? false
        }
        return true
    }
    
    public func existsAsTypeAndCannotBeShadowed(identifier: String) -> Bool {
        guard let resolution = maybeResolveTypeWithScopeDepth(identifier: identifier) else {
            return false
        }
        return resolution.1 == 0
    }
    
    private func maybeResolveTypeWithScopeDepth(sourceAnchor: SourceAnchor? = nil, identifier: String) -> (SymbolType, Int)? {
        if let symbolType = typeTable[identifier] {
            return (symbolType.symbolType, 0)
        } else if let parentResolution = parent?.maybeResolveTypeWithScopeDepth(sourceAnchor: sourceAnchor, identifier: identifier) {
            return (parentResolution.0, parentResolution.1 + 1)
        }
        return nil
    }
    
    public func existsAndCannotBeShadowed(identifier: String) -> Bool {
        guard let resolution = maybeResolveWithScopeDepth(identifier: identifier) else {
            return false
        }
        return resolution.1 == 0
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
    
    // The UUID of the block associated with this scope, if any
    public var associatedBlockId: Block.ID?
    
    // Given a symbol identifier, return the Id of the Block associated with the
    // scope in which it was defined.
    public func lookupScopeEnclosingSymbol(identifier: String) -> SymbolTable? {
        if let _ = symbolTable[identifier] {
            self
        }
        else {
            parent?.lookupScopeEnclosingSymbol(identifier: identifier)
        }
    }
    
    // Given a type identifier, return the Id of the Block associated with the
    // scope in which it was defined.
    public func lookupScopeEnclosingType(identifier: String) -> SymbolTable? {
        if let _ = typeTable[identifier] {
            self
        }
        else {
            parent?.lookupScopeEnclosingType(identifier: identifier)
        }
    }
    
    public func allEnclosingFunctionNames() -> [String] {
        if let enclosingFunctionName = enclosingFunctionName {
            if let parent = parent {
                return parent.allEnclosingFunctionNames() + [enclosingFunctionName]
            } else {
                return [enclosingFunctionName]
            }
        } else {
            return []
        }
    }
    
    public func resolveType(identifier: String) throws -> SymbolType {
        return try resolveType(sourceAnchor: nil, identifier: identifier)
    }
    
    public func resolveType(sourceAnchor: SourceAnchor?, identifier: String) throws -> SymbolType {
        guard let resolution = maybeResolveTypeWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier) else {
            throw CompilerError(sourceAnchor: sourceAnchor,
                                message: "use of undeclared type `\(identifier)'")
        }
        return resolution.0
    }
    
    private func maybeResolveTypeWithStackFrameDepth(sourceAnchor: SourceAnchor?, identifier: String) -> (SymbolType, Int)? {
        if let symbolRecord = typeTable[identifier] {
            return (symbolRecord.symbolType, stackFrameIndex)
        }
        return parent?.maybeResolveTypeWithStackFrameDepth(sourceAnchor: sourceAnchor, identifier: identifier)
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
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else {
            return false
        }
        guard type(of: rhs!) == type(of: self) else {
            return false
        }
        guard let rhs = rhs as? SymbolTable else {
            return false
        }
        guard declarationOrder == rhs.declarationOrder else {
            return false
        }
        guard symbolTable == rhs.symbolTable else {
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
        guard enclosingFunctionName == rhs.enclosingFunctionName else {
            return false
        }
        guard frameLookupMode == rhs.frameLookupMode else {
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
        hasher.combine(enclosingFunctionType)
        hasher.combine(enclosingFunctionName)
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
        result.scopePrologue = scopePrologue
        result.enclosingFunctionTypeMode = enclosingFunctionTypeMode
        result.enclosingFunctionNameMode = enclosingFunctionNameMode
        result.modulesAlreadyImported = modulesAlreadyImported
        return result
    }
}
