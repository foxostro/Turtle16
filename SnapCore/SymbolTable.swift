//
//  SymbolTable.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public indirect enum SymbolType: Equatable, Hashable {
    case void, u8, bool, function(FunctionType)
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
        return "(\(makeArgumentsDescription())) -> \(String(describing: returnType))"
    }
    
    public func makeArgumentsDescription() -> String {
        let result = arguments.map({"\($0.name) : \(String(describing: $0.argumentType))"}).joined(separator: ", ")
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
    public var storagePointer: Int = 0
    public var enclosingFunctionType: FunctionType? = nil
    
    public convenience init(_ dict: [String:Symbol] = [:]) {
        self.init(parent: nil, dict: dict)
    }
    
    public init(parent p: SymbolTable?, dict: [String:Symbol] = [:]) {
        parent = p
        symbolTable = dict
        enclosingFunctionType = p?.enclosingFunctionType
    }
    
    public func exists(identifier: String) -> Bool {
        if nil == symbolTable[identifier] {
            return parent?.exists(identifier: identifier) ?? false
        }
        return true
    }
    
    public func bind(identifier: String, symbol: Symbol) {
        symbolTable[identifier] = symbol
    }
    
    public func resolve(identifier: String) throws -> Symbol {
        guard let resolution = maybeResolve(identifier: identifier) else {
            throw CompilerError(message: "use of unresolved identifier: `\(identifier)'")
        }
        return resolution.0
    }
    
    public func resolve(identifierToken: TokenIdentifier) throws -> Symbol {
        guard let resolution = maybeResolve(identifier: identifierToken.lexeme) else {
            throw CompilerError(line: identifierToken.lineNumber,
                                format: "use of unresolved identifier: `%@'",
                                identifierToken.lexeme)
        }
        return resolution.0
    }
    
    public func resolveWithDepth(identifierToken: TokenIdentifier) throws -> (Symbol, Int) {
        guard let resolution = maybeResolve(identifier: identifierToken.lexeme) else {
            throw CompilerError(line: identifierToken.lineNumber,
                                format: "use of unresolved identifier: `%@'",
                                identifierToken.lexeme)
        }
        return resolution
    }
    
    private func maybeResolve(identifier: String) -> (Symbol, Int)? {
        if let symbol = symbolTable[identifier] {
            return (symbol, 0)
        } else if let parentResolution = parent?.maybeResolve(identifier: identifier) {
            return (parentResolution.0, parentResolution.1 + 1)
        }
        return nil
    }
}
