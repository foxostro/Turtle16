//
//  SymbolTable.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCompilerToolbox

// Maps a name to symbol information.
public class SymbolTable: NSObject {
    public enum StorageInt: Equatable {
        case constant(Int)
        case staticStorage(address: Int, isMutable: Bool)
    }
    
    public enum StorageBool: Equatable {
        case constant(Bool)
        case staticStorage(address: Int, isMutable: Bool)
    }
    
    public enum Symbol: Equatable {
        case label(Int)
        case word(StorageInt)
        case boolean(StorageBool)
    }
    
    var symbolTable: [String:Symbol]
    
    public init(_ dict: [String:Symbol] = [:]) {
        symbolTable = dict
    }
    
    public func exists(identifier: String) -> Bool {
        return nil != symbolTable[identifier]
    }
    
    public func bindLabel(identifier: String, value: Int) {
        bind(identifier: identifier, symbol: .label(value))
    }
    
    public func bind(identifier: String, symbol: Symbol) {
        symbolTable[identifier] = symbol
    }
    
    public func resolve(identifier: String) throws -> Symbol {
        guard let symbol = symbolTable[identifier] else {
            throw CompilerError(message: "use of unresolved identifier: `\(identifier)'")
        }
        return symbol
    }
    
    public func resolve(identifierToken: TokenIdentifier) throws -> Symbol {
        guard let symbol = symbolTable[identifierToken.lexeme] else {
            throw CompilerError(line: identifierToken.lineNumber,
                                format: "use of unresolved identifier: `%@'",
                                identifierToken.lexeme)
        }
        return symbol
    }
}
