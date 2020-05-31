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
    public enum SymbolEnum: Equatable {
        case constantAddress(SymbolConstantAddress)
        case constantWord(SymbolConstantWord)
        case staticWord(SymbolStaticWord)
    }
    
    var table: [String:SymbolEnum]
    
    public init(_ dict: [String:SymbolEnum] = [:]) {
        table = dict
    }
    
    public func exists(identifier: String) -> Bool {
        return nil != table[identifier]
    }
    
    public func bindConstantAddress(identifier: String, value: Int) {
        table[identifier] = .constantAddress(SymbolConstantAddress(identifier: identifier, value: value))
    }
    
    public func bindConstantWord(identifier: String, value: UInt8) {
        table[identifier] = .constantWord(SymbolConstantWord(identifier: identifier, value: value))
    }
    
    public func bindStaticWord(identifier: String, address: Int, isMutable: Bool = true) {
        table[identifier] = .staticWord(SymbolStaticWord(identifier: identifier, address: address, isMutable: isMutable))
    }
    
    public func resolve(identifier: String) throws -> SymbolEnum {
        guard let symbol = table[identifier] else {
            throw useOfUnresolvedIdentifierError(identifier: identifier)
        }
        return symbol
    }
    
    private func useOfUnresolvedIdentifierError(identifier: String) -> CompilerError {
        return CompilerError(message: "use of unresolved identifier: `\(identifier)'")
    }
    
    public func resolve(identifierToken: TokenIdentifier) throws -> SymbolEnum {
        guard let symbol = table[identifierToken.lexeme] else {
            throw useOfUnresolvedIdentifierError(identifierToken: identifierToken)
        }
        return symbol
    }
    
    private func useOfUnresolvedIdentifierError(identifierToken: TokenIdentifier) -> CompilerError {
        return CompilerError(line: identifierToken.lineNumber,
                              format: "use of unresolved identifier: `%@'",
                              identifierToken.lexeme)
    }
}
