//
//  SymbolTable.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public indirect enum SymbolType: Equatable, Hashable, CustomStringConvertible {
    case constInt(Int), constBool(Bool)
    case u16, u8, bool, void
    case function(name: String, mangledName: String, functionType: FunctionType)
    case array(count: Int?, elementType: SymbolType)
    
    public var isBooleanType: Bool {
        switch self {
        case .bool, .constBool:
            return true
        default:
            return false
        }
    }
    
    public var isArithmeticType: Bool {
        switch self {
        case .u8, .u16, .constInt:
            return true
        default:
            return false
        }
    }
    
    public var sizeof: Int {
        switch self {
        case .constInt, .constBool, .void, .function:
            return 0
        case .u8, .bool:
            return 1
        case .u16:
            return 2
        case .array(count: let count, elementType: let elementType):
            return (count ?? 0) * elementType.sizeof
        }
    }
    
    public var description: String {
        switch self {
        case .constInt:
            return "const int"
        case .constBool:
            return "const bool"
        case .void:
            return "void"
        case .u16:
            return "u16"
        case .u8:
            return "u8"
        case .bool:
            return "bool"
        case .array(count: let count, elementType: let elementType):
            if let count = count {
                return "[\(count), \(elementType)]"
            } else {
                return "[\(elementType)]"
            }
        case .function(name: _, mangledName: _, functionType: let functionType):
            let argumentTypeDescription = functionType.arguments.compactMap({"\($0.argumentType)"}).joined(separator: ", ")
            let result = "(\(argumentTypeDescription)) -> \(functionType.returnType)"
            return result
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .constInt(let value):
            return "constInt(\(value))"
        case .constBool(let value):
            return "constBool(\(value))"
        case .void:
            return "void"
        case .u16:
            return "u16"
        case .u8:
            return "u8"
        case .bool:
            return "bool"
        case .array(count: let count, elementType: let elementType):
            if let count = count {
                return "array(\(count), \(elementType.debugDescription))"
            } else {
                return "array(\(elementType.debugDescription))"
            }
        case .function(name: _, mangledName: _, functionType: let functionType):
            let arg = functionType.arguments.compactMap({"\($0.argumentType.debugDescription)"}).joined(separator: ", ")
            let result = "(\(arg.debugDescription)) -> \(functionType.returnType.debugDescription)"
            return result
        }
    }
}

public enum SymbolStorage: Equatable {
    case staticStorage, stackStorage
}

public class FunctionType: NSObject {
    public class Argument: NSObject {
        public let name: String
        public let argumentType: SymbolType
        
        public init(name: String, type: SymbolType) {
            self.name = name
            self.argumentType = type
        }
        
        public static func ==(lhs: Argument, rhs: Argument) -> Bool {
            return lhs.isEqual(rhs)
        }
        
        public override func isEqual(_ rhs: Any?) -> Bool {
            guard rhs != nil else { return false }
            guard type(of: rhs!) == type(of: self) else { return false }
            guard let rhs = rhs as? Argument else { return false }
            guard name == rhs.name else { return false }
            guard argumentType == rhs.argumentType else { return false }
            return true
        }
        
        public override var hash: Int {
            var hasher = Hasher()
            hasher.combine(name)
            hasher.combine(argumentType)
            return hasher.finalize()
        }
    }
    
    public let returnType: SymbolType
    public let arguments: [Argument]
    
    public init(returnType: SymbolType, arguments: [Argument]) {
        self.returnType = returnType
        self.arguments = arguments
    }
    
    public override var description: String {
        return "(\(makeArgumentsDescription())) -> \(returnType)"
    }
    
    public func makeArgumentsDescription() -> String {
        let result = arguments.map({"\($0.name) : \($0.argumentType)"}).joined(separator: ", ")
        return result
    }
    
    public static func ==(lhs: FunctionType, rhs: FunctionType) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? FunctionType else { return false }
        guard returnType == rhs.returnType else { return false }
        guard arguments == rhs.arguments else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(returnType)
        hasher.combine(arguments)
        return hasher.finalize()
    }
}

public struct Symbol: Equatable {
    public let type: SymbolType
    public let offset: Int
    public let isMutable: Bool
    public let storage: SymbolStorage
    
    public init(type: SymbolType, offset: Int, isMutable: Bool, storage: SymbolStorage = .staticStorage) {
        self.type = type
        self.offset = offset
        self.isMutable = isMutable
        self.storage = storage
    }
}

// Maps a name to symbol information.
public class SymbolTable: NSObject {
    private var symbolTable: [String:Symbol]
    public let parent: SymbolTable?
    public var storagePointer: Int
    public var enclosingFunctionType: FunctionType? = nil
    public var enclosingFunctionName: String? = nil
    public var stackFrameIndex: Int
    
    public convenience init(_ dict: [String:Symbol] = [:]) {
        self.init(parent: nil, dict: dict)
    }
    
    public init(parent p: SymbolTable?, dict: [String:Symbol] = [:]) {
        parent = p
        symbolTable = dict
        storagePointer = p?.storagePointer ?? 1
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
    
    public func existsAndCannotBeShadowed(identifier: String) -> Bool {
        guard let resolution = maybeResolveWithScopeDepth(identifier: identifier) else {
            return false
        }
        return resolution.1 == 0
    }
    
    public func bind(identifier: String, symbol: Symbol) {
        symbolTable[identifier] = symbol
    }
    
    public func resolve(identifier: String) throws -> Symbol {
        guard let resolution = maybeResolveWithStackFrameDepth(identifier: identifier) else {
            throw CompilerError(message: "use of unresolved identifier: `\(identifier)'")
        }
        return resolution.0
    }
    
    public func resolve(identifierToken: TokenIdentifier) throws -> Symbol {
        guard let resolution = maybeResolveWithStackFrameDepth(identifier: identifierToken.lexeme) else {
            throw CompilerError(line: identifierToken.lineNumber,
                                format: "use of unresolved identifier: `%@'",
                                identifierToken.lexeme)
        }
        return resolution.0
    }
    
    public func resolveWithStackFrameDepth(identifierToken: TokenIdentifier) throws -> (Symbol, Int) {
        guard let resolution = maybeResolveWithStackFrameDepth(identifier: identifierToken.lexeme) else {
            throw CompilerError(line: identifierToken.lineNumber,
                                format: "use of unresolved identifier: `%@'",
                                identifierToken.lexeme)
        }
        return resolution
    }
    
    private func maybeResolveWithStackFrameDepth(identifier: String) -> (Symbol, Int)? {
        if let symbol = symbolTable[identifier] {
            return (symbol, stackFrameIndex)
        }
        return parent?.maybeResolveWithStackFrameDepth(identifier: identifier)
    }
    
    public func resolveWithScopeDepth(identifierToken: TokenIdentifier) throws -> (Symbol, Int) {
        guard let resolution = maybeResolveWithScopeDepth(identifier: identifierToken.lexeme) else {
            throw CompilerError(line: identifierToken.lineNumber,
                                format: "use of unresolved identifier: `%@'",
                                identifierToken.lexeme)
        }
        return resolution
    }
    
    private func maybeResolveWithScopeDepth(identifier: String) -> (Symbol, Int)? {
        if let symbol = symbolTable[identifier] {
            return (symbol, 0)
        } else if let parentResolution = parent?.maybeResolveWithScopeDepth(identifier: identifier) {
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
}
