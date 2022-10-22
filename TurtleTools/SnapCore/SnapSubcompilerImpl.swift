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
    public let globalEnvironment: GlobalEnvironment
    
    public init(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) {
        self.parent = symbols
        self.globalEnvironment = globalEnvironment
    }
    
    public func compile(_ node: Impl) throws -> Block {
        let implWhat = try parent.resolveType(sourceAnchor: node.identifier.sourceAnchor,
                                              identifier: node.identifier.identifier)
        
        switch implWhat {
        case .constStructType(let typ), .structType(let typ):
            return try compileImplStruct(node, typ)
            
        case .genericStructType(let typ):
            return try compileImplGenericStruct(node, typ)
            
        default:
            fatalError("unsupported expression: \(node)")
        }
    }
    
    public func compileImplStruct(_ node: Impl, _ typ: StructType) throws -> Block {
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
            
            let subcompiler = SnapSubcompilerFunctionDeclaration()
            let modifiedChild = try subcompiler.compile(memoryLayoutStrategy: globalEnvironment.memoryLayoutStrategy,
                                                        symbols: symbols,
                                                        node: child)
            if let modifiedChild {
                modifiedChildren.append(modifiedChild)
            }
            
            // Put the symbol back into the struct type's symbol table too.
            typ.symbols.bind(identifier: identifier, symbol: symbols.symbolTable[identifier]!)
        }
        
        let block = Block(sourceAnchor: node.sourceAnchor,
                          symbols: symbols,
                          children: modifiedChildren)
        return block
    }
    
    public func compileImplGenericStruct(_ node: Impl, _ typ: GenericStructType) throws -> Block {
        typ.implNodes.append(node)
        return Block()
    }
}
