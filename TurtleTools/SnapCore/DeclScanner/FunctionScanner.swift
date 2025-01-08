//
//  FunctionScanner.swift
//  SnapCore
//
//  Created by Andrew Fox on 9/15/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import Foundation
import TurtleCore

/// Scans a function declaration and binds the function symbol in the environment
public class FunctionScanner: NSObject {
    public let globalEnvironment: GlobalEnvironment
    public let symbols: SymbolTable
    public let enclosingImplId: AbstractSyntaxTreeNode.ID?
    
    private var memoryLayoutStrategy: MemoryLayoutStrategy {
        globalEnvironment.memoryLayoutStrategy
    }
    
    public init(
        globalEnvironment: GlobalEnvironment = GlobalEnvironment(),
        symbols: SymbolTable = SymbolTable(),
        enclosingImplId: AbstractSyntaxTreeNode.ID? = nil) {

        self.globalEnvironment = globalEnvironment
        self.symbols = symbols
        self.enclosingImplId = enclosingImplId
    }
    
    public func scan(func node: FunctionDeclaration) throws {
        assert(node.symbols.frameLookupMode.isSet)
        let name = node.identifier.identifier
        
        guard !symbols.exists(identifier: name) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "function redefines existing symbol: `\(name)'")
        }
        
        guard !symbols.existsAsType(identifier: name) else {
            throw CompilerError(
                sourceAnchor: node.identifier.sourceAnchor,
                message: "function redefines existing type: `\(name)'")
        }
        
        if node.isGeneric {
            try doGeneric(node: node)
        }
        else {
            try doNonGeneric(node: node)
        }
    }
    
    public func scanInside(func node: FunctionDeclaration) throws {
        assert(!node.isGeneric)
        try doNonGeneric(node: node)
    }
    
    private func doGeneric(node: FunctionDeclaration) throws {
        try checkDoesNotShadowExistingSymbolOrType(typeParameters: node.typeArguments)
        
        let name = node.identifier.identifier
        let typ = Expression.GenericFunctionType(
            template: node,
            enclosingImplId: enclosingImplId)
        let symbol = Symbol(
            type: .genericFunction(typ),
            offset: 0,
            storage: .automaticStorage,
            visibility: node.visibility)
        symbols.bind(identifier: name, symbol: symbol)
    }
    
    /// Throw an error if any of the type parameters would shadow an existing symbol or type
    private func checkDoesNotShadowExistingSymbolOrType(typeParameters: [Expression.GenericTypeArgument]) throws {
        try typeParameters.forEach { param in
            let ident: String = param.identifier.identifier
            
            guard !symbols.exists(identifier: ident) else {
                throw CompilerError(
                    sourceAnchor: param.identifier.sourceAnchor,
                    message: "generic type parameter redefines existing symbol: `\(ident)'")
            }
            
            guard !symbols.existsAsType(identifier: ident) else {
                throw CompilerError(
                    sourceAnchor: param.identifier.sourceAnchor,
                    message: "generic type parameter redefines existing type: `\(ident)'")
            }
        }
    }
    
    private func doNonGeneric(node node0: FunctionDeclaration) throws {
        let functionType = try TypeContextTypeChecker(symbols: symbols)
            .check(expression: node0.functionType)
            .unwrapFunctionType()
        
        node0.symbols.breadcrumb = .functionType(functionType)
        node0.body.symbols.parent = node0.symbols
        
        var offset = memoryLayoutStrategy.sizeOfSaveArea
        
        for i in (0..<functionType.arguments.count).reversed() {
            let argumentType = functionType.arguments[i]
            let argumentName = node0.argumentNames[i]
            let symbol = Symbol(
                type: argumentType.correspondingConstType,
                offset: -offset,
                storage: .automaticStorage)
            node0.symbols.bind(identifier: argumentName, symbol: symbol)
            let sizeOfArugmentType = memoryLayoutStrategy.sizeof(type: argumentType)
            offset += sizeOfArugmentType
        }
        
        // Bind a special symbol to contain the function return value.
        // This must be located just before the function arguments.
        let kReturnValueIdentifier = "__returnValue"
        node0.symbols.bind(
            identifier: kReturnValueIdentifier,
            symbol: Symbol(
                type: functionType.returnType,
                offset: -offset,
                storage: .automaticStorage))
        let sizeOfFunctionReturnType = memoryLayoutStrategy.sizeof(type: functionType.returnType)
        offset += sizeOfFunctionReturnType
        
        let node1 = node0.withFunctionType(Expression.FunctionType(
            sourceAnchor: node0.functionType.sourceAnchor,
            name: functionType.name,
            returnType: Expression.PrimitiveType(functionType.returnType),
            arguments: functionType.arguments.map(\.lift)))
        
        functionType.ast = node1
        
        let symbol = Symbol(
            type: .function(functionType),
            offset: 0,
            storage: .automaticStorage,
            visibility: node1.visibility)
        symbols.bind(identifier: node1.identifier.identifier, symbol: symbol)
    }
}
