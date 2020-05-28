//
//  SymbolTable.swift
//  TurtleCompilerToolbox
//
//  Created by Andrew Fox on 9/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

public enum Symbol: Equatable {
    case constant(Int)
}

// Maps a name to symbol information.
public class SymbolTable: NSObject {
    var table: [String:Symbol]
    
    public init(_ dict: [String:Symbol] = [:]) {
        table = dict
    }
    
    public subscript(name: String) -> Symbol? {
        get {
            return table[name]
        }
        set(newValue) {
            return table[name] = newValue
        }
    }
    
    public func resolve(identifier: TokenIdentifier) throws -> Int {
        guard let symbol = table[identifier.lexeme] else {
            throw useOfUnresolvedIdentifierError(identifier)
        }
        switch symbol {
        case .constant(let value):
            return value
        }
    }
    
    private func useOfUnresolvedIdentifierError(_ identifier: TokenIdentifier) -> CompilerError {
        return CompilerError(line: identifier.lineNumber,
                              format: "use of unresolved identifier: `%@'",
                              identifier.lexeme)
    }
}
