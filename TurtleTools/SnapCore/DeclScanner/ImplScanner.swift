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
public struct ImplScanner {
    private let memoryLayoutStrategy: MemoryLayoutStrategy
    private let parent: SymbolTable
    private let typeChecker: RvalueExpressionTypeChecker
    
    public init(
        memoryLayoutStrategy: MemoryLayoutStrategy,
        symbols parent: SymbolTable = SymbolTable()
    ) {
        self.memoryLayoutStrategy = memoryLayoutStrategy
        self.parent = parent
        typeChecker = RvalueExpressionTypeChecker(
            symbols: parent,
            memoryLayoutStrategy: memoryLayoutStrategy)
    }
    
    public func scan(impl node: Impl) throws {
        if node.isGeneric {
            try doGenericCase(node)
        }
        else {
            try doNonGenericCase(node)
        }
    }
    
    private func doGenericCase(_ node: Impl) throws {
        assert(node.isGeneric)
        
        guard let app = node.structTypeExpr as? Expression.GenericTypeApplication else {
            throw CompilerError(
                sourceAnchor: node.structTypeExpr.sourceAnchor,
                message: "expected a generic type application: `\(node.structTypeExpr)'")
        }
        
        let originalStructType = try parent
            .resolveTypeOfIdentifier(
                sourceAnchor: app.sourceAnchor,
                identifier: app.identifier.identifier)
            .unwrapGenericStructType()
        let name = originalStructType.name
        
        // If the struct type was not defined in the current scope then
        // clone it for the current scope. This ensures that changes we make
        // in an Impl block do not propagate outside the current scope.
        let structType: GenericStructTypeInfo
        if parent.typeTable.contains(where: { $0.key == name }) {
            structType = originalStructType
        }
        else {
            structType = originalStructType.clone()
            parent.bind(
                identifier: name,
                symbolType: .genericStructType(structType))
        }
        
        structType.implNodes.append(node)
    }
    
    private func doNonGenericCase(_ node: Impl) throws {
        assert(!node.isGeneric)
        
        let type = try typeChecker.check(expression: node.structTypeExpr)
        guard let originalStructType = type.maybeUnwrapStructType() else {
            fatalError("unsupported expression: \(node)")
        }
        let name = originalStructType.name
        
        // If the struct type was not defined in the current scope then
        // clone it for the current scope. This ensures that changes we make
        // in an Impl block do not propagate outside the current scope.
        let structType: StructTypeInfo
        if parent.typeTable.contains(where: { $0.key == name }) {
            structType = originalStructType
        }
        else {
            let shadower: SymbolType = switch type {
            case .constStructType(let typ): .constStructType(typ.clone())
            case .structType(let typ): .structType(typ.clone())
            default: fatalError("unreachable")
            }
            parent.bind(identifier: name, symbolType: shadower)
            structType = shadower.unwrapStructType()
        }
        
        try scanImplStruct(node, structType)
    }
    
    private func scanImplStruct(_ node: Impl, _ typ: StructTypeInfo) throws {
        let symbols = SymbolTable(parent: parent)
        symbols.breadcrumb = .structType(typ.name)
        
        for child in node.children {
            let identifier = child.identifier.identifier
            guard !typ.symbols.exists(identifier: identifier) else {
                throw CompilerError(
                    sourceAnchor: child.sourceAnchor,
                    message: "function redefines existing symbol: `\(identifier)'")
            }
            
            let scanner = FunctionScanner(
                memoryLayoutStrategy: memoryLayoutStrategy,
                symbols: symbols, enclosingImplId: node.id)
            try scanner.scan(func: child)
            
            // Put the symbol back into the struct type's symbol table too.
            typ.symbols.bind(
                identifier: identifier,
                symbol: symbols.symbolTable[identifier]!)
        }
    }
}
