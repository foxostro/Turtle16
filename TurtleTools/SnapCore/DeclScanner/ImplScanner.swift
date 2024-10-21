//
//  ImplScanner.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

/// Scans an Impl declaration and binds the function symbols in the environment
public class ImplScanner: NSObject {
    public let globalEnvironment: GlobalEnvironment
    public let parent: SymbolTable
    private let typeChecker: RvalueExpressionTypeChecker
    
    public init(
        globalEnvironment: GlobalEnvironment = GlobalEnvironment(),
        symbols parent: SymbolTable = SymbolTable()) {
            
            self.globalEnvironment = globalEnvironment
            self.parent = parent
            typeChecker = RvalueExpressionTypeChecker(
                symbols: parent, globalEnvironment: globalEnvironment)
        }
    
    public func scan(impl node: Impl) throws {
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
                try scanImplStruct(node, typ)
                
            default:
                fatalError("unsupported expression: \(node)")
            }
        }
    }
    
    private func scanImplStruct(_ node: Impl, _ typ: StructType) throws {
        let symbols = SymbolTable(parent: parent)
        symbols.enclosingFunctionNameMode = .set(typ.name)
        symbols.enclosingFunctionTypeMode = .set(nil)
        
        for child in node.children {
            let identifier = child.identifier.identifier
            if typ.symbols.exists(identifier: identifier) {
                throw CompilerError(sourceAnchor: child.sourceAnchor,
                                    message: "function redefines existing symbol: `\(identifier)'")
            }
            
            // Enqueue the function to be compiled later
            let scanner = FunctionScanner(
                globalEnvironment: globalEnvironment,
                symbols: symbols, enclosingImplId: node.id)
            try scanner.scan(func: child)
            
            // Put the symbol back into the struct type's symbol table too.
            typ.symbols.bind(identifier: identifier, symbol: symbols.symbolTable[identifier]!)
        }
    }
}
