//
//  SymbolTable.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public enum SymbolType: Equatable {
    case void, u8, bool, function
}

public enum SymbolStorage: Equatable {
    case staticStorage, stackStorage
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
    
    public convenience init(_ dict: [String:Symbol] = [:]) {
        self.init(parent: nil, dict: dict)
    }
    
    public init(parent p: SymbolTable?, dict: [String:Symbol] = [:]) {
        parent = p
        symbolTable = dict
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
