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
    public let typeChecker: RvalueExpressionTypeChecker
    
    public init(symbols: SymbolTable, globalEnvironment: GlobalEnvironment) {
        self.parent = symbols
        self.globalEnvironment = globalEnvironment
        typeChecker = RvalueExpressionTypeChecker(symbols: parent, globalEnvironment: globalEnvironment)
    }
    
    public func compile(_ node: Impl) throws {
        if node.isGeneric {
            guard let app = node.structTypeExpr as? Expression.GenericTypeApplication else {
                throw CompilerError(sourceAnchor: node.structTypeExpr.sourceAnchor, message: "expected a generic type application: `\(node.structTypeExpr)'")
            }
            
            let genericStructType = try parent.resolveTypeOfIdentifier(sourceAnchor: app.sourceAnchor, identifier: app.identifier.identifier)
            let typ = genericStructType.unwrapGenericStructType()
            typ.implNodes.append(node)
        }
        else {
            let implWhat = try typeChecker.check(expression: node.structTypeExpr)
            
            switch implWhat {
            case .constStructType(let typ), .structType(let typ):
                try compileImplStruct(node, typ)
                
            default:
                fatalError("unsupported expression: \(node)")
            }
        }
    }
    
    public func compileImplStruct(_ node: Impl, _ typ: StructType) throws {
        let symbols = SymbolTable(parent: parent)
        symbols.enclosingFunctionNameMode = .set(typ.name)
        symbols.enclosingFunctionTypeMode = .set(nil)
        
        SymbolTablesReconnector(symbols).reconnect(node)
        
        for child in node.children {
            let identifier = child.identifier.identifier
            if typ.symbols.exists(identifier: identifier) {
                throw CompilerError(sourceAnchor: child.sourceAnchor,
                                    message: "function redefines existing symbol: `\(identifier)'")
            }
            
            // Enqueue the function to be compiled later
            try SnapSubcompilerFunctionDeclaration()
                .compile(globalEnvironment: globalEnvironment,
                         symbols: symbols,
                         node: child)
            
            // Put the symbol back into the struct type's symbol table too.
            typ.symbols.bind(identifier: identifier, symbol: symbols.symbolTable[identifier]!)
        }
    }
}
