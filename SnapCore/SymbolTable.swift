//
//  SymbolTable.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

public enum SymbolType: Equatable {
    case u8, boolean
}

public struct Symbol: Equatable {
    public let type: SymbolType
    public let offset: Int
    public let isMutable: Bool
    
    public init(type: SymbolType, offset: Int, isMutable: Bool) {
        self.type = type
        self.offset = offset
        self.isMutable = isMutable
    }
}

// Maps a name to symbol information.
public class SymbolTable: NSObject {
    private var symbolTable: [String:Symbol]
    public let parent: SymbolTable?
    
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
        } else {
            return true
        }
    }
    
    public func bind(identifier: String, symbol: Symbol) {
        symbolTable[identifier] = symbol
    }
    
    public func resolve(identifier: String) throws -> Symbol {
        guard let symbol = maybeResolve(identifier: identifier) else {
            throw CompilerError(message: "use of unresolved identifier: `\(identifier)'")
        }
        return symbol
    }
    
    public func resolve(identifierToken: TokenIdentifier) throws -> Symbol {
        guard let symbol = maybeResolve(identifier: identifierToken.lexeme) else {
            throw CompilerError(line: identifierToken.lineNumber,
                                format: "use of unresolved identifier: `%@'",
                                identifierToken.lexeme)
        }
        return symbol
    }
    
    private func maybeResolve(identifier: String) -> Symbol? {
        if let symbol = symbolTable[identifier] {
            return symbol
        } else {
            return parent?.maybeResolve(identifier: identifier) ?? nil
        }
    }
}
