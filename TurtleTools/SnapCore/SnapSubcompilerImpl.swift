//
//  SnapSubcompilerImpl.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/4/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerImpl: NSObject {
    public let parent: SymbolTable
    
    public init(_ parent: SymbolTable) {
        self.parent = parent
    }
    
    public func compile(_ node: Impl) throws -> Block {
        let typ = try parent.resolveType(sourceAnchor: node.identifier.sourceAnchor, identifier: node.identifier.identifier).unwrapStructType()
        
        let symbols = SymbolTable(parent: parent)
        symbols.enclosingFunctionNameMode = .set(node.identifier.identifier)
        symbols.enclosingFunctionTypeMode = .set(nil)
        
        SymbolTablesReconnector(symbols).reconnect(node)
        
        var modifiedChildren: [FunctionDeclaration] = []
        
        for child in node.children {
            let identifier = child.identifier.identifier
            if typ.symbols.exists(identifier: identifier) {
                throw CompilerError(sourceAnchor: child.sourceAnchor,
                                    message: "function redefines existing symbol: `\(identifier)'")
            }
            
            let modifiedChild = try SnapSubcompilerFunctionDeclaration(symbols).compile(child)
            modifiedChildren.append(modifiedChild)
            
            // Put the symbol back into the struct type's symbol table too.
            typ.symbols.bind(identifier: identifier, symbol: symbols.symbolTable[identifier]!)
        }
        
        let block = Block(sourceAnchor: node.sourceAnchor,
                          symbols: symbols,
                          children: modifiedChildren)
        return block
    }
}
