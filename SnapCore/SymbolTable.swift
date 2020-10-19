//
//  SymbolTable.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox
import TurtleCore

public indirect enum SymbolType: Equatable, Hashable, CustomStringConvertible {
    case void
    case function(FunctionType)
    case compTimeBool(Bool)
    case constBool, bool
    case compTimeInt(Int)
    case constU8, u8
    case constU16, u16
    case array(count: Int?, elementType: SymbolType)
    case constDynamicArray(elementType: SymbolType), dynamicArray(elementType: SymbolType)
    case constPointer(SymbolType), pointer(SymbolType)
    case constStructType(StructType), structType(StructType)
    case traitType(TraitType)
    case unionType(UnionType)
    
    public var isConst: Bool {
        switch self {
        case .void, .function:
            return true
        case .compTimeBool, .constBool, .compTimeInt, .constU8, .constU16, .constDynamicArray, .constPointer, .constStructType, .traitType:
            return true
        default:
            return false
        }
    }
    
    public var correspondingConstType: SymbolType {
        switch self {
        case .bool:
            return .constBool
        case .u8:
            return .constU8
        case .u16:
            return .constU16
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
        default:
            return self
        }
    }
    
    public var correspondingMutableType: SymbolType {
        switch self {
        case .constBool:
            return .bool
        case .constU8:
            return .u8
        case .constU16:
            return .u16
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
        default:
            return self
        }
    }
    
    public func max() -> Int {
        switch self {
        case .compTimeInt(let a):
            return a
        case .constU8, .u8:
            return 255
        case .constU16, .u16:
            return 65536
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
    
    public func unwrapTraitType() -> TraitType {
        switch self {
        case .traitType(let typ):
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
        case .bool, .constBool, .compTimeBool:
            return true
        default:
            return false
        }
    }
    
    public var isArithmeticType: Bool {
        switch self {
        case .compTimeInt, .constU8, .u8, .constU16, .u16:
            return true
        default:
            return false
        }
    }
    
    public var sizeof: Int {
        switch self {
        case .compTimeInt, .compTimeBool, .void, .function:
            return 0
        case .constU8, .u8, .bool, .constBool:
            return 1
        case .constU16, .u16:
            return 2
        case .constPointer, .pointer:
            return 2
        case .constDynamicArray(elementType: _), .dynamicArray(elementType: _), .traitType(_):
            return 4
        case .array(count: let count, elementType: let elementType):
            return (count ?? 0) * elementType.sizeof
        case .constStructType(let typ), .structType(let typ):
            return typ.sizeof
        case .unionType(let typ):
            return typ.sizeof
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
        case .compTimeBool(let a):
            return "boolean constant \(a)"
        case .constBool:
            return "const bool"
        case .bool:
            return "bool"
        case .compTimeInt(let a):
            return "integer constant \(a)"
        case .constU16:
            return "const u16"
        case .u16:
            return "u16"
        case .constU8:
            return "const u8"
        case .u8:
            return "u8"
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
        case .constStructType(let typ):
            return "const \(typ.name)"
        case .structType(let typ):
            return "\(typ.name)"
        case .traitType(let typ):
            return "\(typ.name)"
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
    case staticStorage, stackStorage
}

public class FunctionType: NSObject {
    public let name: String?
    public let mangledName: String?
    public let returnType: SymbolType
    public let arguments: [SymbolType]
    
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
    
    public init(name: String?, mangledName: String?, returnType: SymbolType, arguments: [SymbolType]) {
        self.name = name
        self.mangledName = mangledName
        self.returnType = returnType
        self.arguments = arguments
    }
    
    public override var description: String {
        if let name = name {
            return "\(name) :: func (\(makeArgumentsDescription())) -> \(returnType)"
        } else {
            return "func (\(makeArgumentsDescription())) -> \(returnType)"
        }
    }
    
    public func makeArgumentsDescription() -> String {
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
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(mangledName)
        hasher.combine(returnType)
        hasher.combine(arguments)
        return hasher.finalize()
    }
    
    public func eraseName() -> FunctionType {
        return FunctionType(returnType: returnType, arguments: arguments)
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
    
    public var sizeof: Int {
        var accum = 0
        for (_, symbol) in symbols.symbolTable {
            accum += symbol.type.sizeof
        }
        return accum
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
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(symbols)
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
    
    public var sizeof: Int {
        var accum = 0
        for (_, symbol) in symbols.symbolTable {
            accum += symbol.type.sizeof
        }
        return accum
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

public class UnionType: NSObject {
    let members: [SymbolType]
    
    public init(_ members: [SymbolType]) {
        self.members = members
    }
    
    public override var description: String {
        let result = members.map({"\($0)"}).joined(separator: " | ")
        return result
    }
    
    public var sizeof: Int {
        let kTagSize = SymbolType.u8.sizeof
        let kBufferSize = members.reduce(0) { (result, member) -> Int in
            return max(result, member.sizeof)
        }
        return kTagSize + kBufferSize
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

public struct Symbol: Equatable {
    public let type: SymbolType
    public let offset: Int
    public let storage: SymbolStorage
    public let visibility: SymbolVisibility
    
    public init(type: SymbolType, offset: Int, storage: SymbolStorage = .staticStorage, visibility: SymbolVisibility = .privateVisibility) {
        self.type = type
        self.offset = offset
        self.storage = storage
        self.visibility = visibility
    }
}

// Maps a name to symbol information.
public class SymbolTable: NSObject {
    public struct TypeRecord: Equatable {
        let symbolType: SymbolType
        let visibility: SymbolVisibility
    }
    public private(set) var symbolTable: [String:Symbol]
    public private(set) var typeTable: [String:TypeRecord]
    public var parent: SymbolTable?
    public var storagePointer: Int
    public var enclosingFunctionType: FunctionType? = nil
    public var enclosingFunctionName: String? = nil
    public var stackFrameIndex: Int
    
    public convenience init(_ dict: [String:Symbol] = [:]) {
        self.init(parent: nil, dict: dict)
    }
    
    public init(parent p: SymbolTable?, dict: [String:Symbol] = [:], typeDict: [String:SymbolType] = [:]) {
        parent = p
        symbolTable = dict
        typeTable = typeDict.mapValues({TypeRecord(symbolType: $0, visibility: .privateVisibility)})
        storagePointer = p?.storagePointer ?? 0
        enclosingFunctionType = p?.enclosingFunctionType
        enclosingFunctionName = p?.enclosingFunctionName
        stackFrameIndex = p?.stackFrameIndex ?? 0
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
        symbolTable[identifier] = symbol
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
        return resolution
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
        guard symbolTable == rhs.symbolTable else {
            return false
        }
        guard typeTable == rhs.typeTable else {
            return false
        }
        return true
    }
}
