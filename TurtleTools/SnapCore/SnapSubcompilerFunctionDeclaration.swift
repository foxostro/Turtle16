//
//  SnapSubcompilerFunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerFunctionDeclaration: NSObject {
    private let enclosingImplId: AbstractSyntaxTreeNode.ID?
    private let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(enclosingImplId: AbstractSyntaxTreeNode.ID? = nil,
                memoryLayoutStrategy: MemoryLayoutStrategy = MemoryLayoutStrategyTurtle16()) {
        self.enclosingImplId = enclosingImplId
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(symbols: SymbolTable, node: FunctionDeclaration) throws {
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
            try doGeneric(symbols: symbols, node: node)
        }
        else {
            try doNonGeneric(symbols: symbols, node: node)
        }
    }
    
    private func doGeneric(symbols: SymbolTable, node: FunctionDeclaration) throws {
        let name = node.identifier.identifier
        let typ = Expression.GenericFunctionType(template: node, enclosingImplId: enclosingImplId)
        let symbol = Symbol(type: .genericFunction(typ),
                            offset: 0,
                            storage: .automaticStorage,
                            visibility: node.visibility)
        symbols.bind(identifier: name, symbol: symbol)
    }
    
    private func doNonGeneric(symbols: SymbolTable, node: FunctionDeclaration) throws {
        let functionType = try evaluateFunctionTypeExpression(symbols, node.functionType)
        try instantiate(functionType: functionType,
                        functionDeclaration: node)
        
        let name = node.identifier.identifier
        let symbol = Symbol(type: .function(functionType),
                            offset: 0,
                            storage: .automaticStorage,
                            visibility: node.visibility)
        symbols.bind(identifier: name, symbol: symbol)
    }
    
    public func instantiate(functionType: FunctionType,
                            functionDeclaration node0: FunctionDeclaration) throws {
        
        node0.symbols.breadcrumb = .functionType(functionType)
        node0.body.symbols.parent = node0.symbols
        
        bindFunctionArguments(symbols: node0.symbols,
                              functionType: functionType,
                              argumentNames: node0.argumentNames)
        try expectFunctionReturnExpressionIsCorrectType(symbols: node0.symbols,
                                                        functionType: functionType,
                                                        func: node0)
        
        let body: Block
        if try shouldSynthesizeTerminalReturnStatement(symbols: node0.symbols,
                                                       functionType: functionType,
                                                       func: node0) {
            let ret = Return(sourceAnchor: node0.sourceAnchor, expression: nil)
            body = node0.body.appending(children: [ret])
        } else {
            body = node0.body
        }
        
        let node1 = node0.withBody(body)
        
        let node2 = node1.withFunctionType(Expression.FunctionType(
            sourceAnchor: node1.functionType.sourceAnchor,
            name: functionType.name,
            returnType: Expression.PrimitiveType(functionType.returnType),
            arguments: functionType.arguments.map{
                Expression.PrimitiveType($0)
            }))
        
        functionType.ast = node2
    }
    
    private func evaluateFunctionTypeExpression(
        _ symbols: SymbolTable,
        _ expr: Expression
    ) throws -> FunctionType {
        try TypeContextTypeChecker(
            symbols: symbols,
            memoryLayoutStrategy: memoryLayoutStrategy)
        .check(expression: expr)
        .unwrapFunctionType()
    }
    
    private func bindFunctionArguments(symbols: SymbolTable,
                                       functionType: FunctionType,
                                       argumentNames: [String]) {
        var offset = memoryLayoutStrategy.sizeOfSaveArea
        
        for i in (0..<functionType.arguments.count).reversed() {
            let argumentType = functionType.arguments[i]
            let argumentName = argumentNames[i]
            let symbol = Symbol(type: argumentType.correspondingConstType,
                                offset: -offset,
                                storage: .automaticStorage)
            symbols.bind(identifier: argumentName, symbol: symbol)
            let sizeOfArugmentType = memoryLayoutStrategy.sizeof(type: argumentType)
            offset += sizeOfArugmentType
        }
        
        // Bind a special symbol to contain the function return value.
        // This must be located just before the function arguments.
        let kReturnValueIdentifier = "__returnValue"
        symbols.bind(identifier: kReturnValueIdentifier,
                     symbol: Symbol(type: functionType.returnType,
                                    offset: -offset,
                                    storage: .automaticStorage))
        let sizeOfFunctionReturnType = memoryLayoutStrategy.sizeof(type: functionType.returnType)
        offset += sizeOfFunctionReturnType
    }
    
    private func expectFunctionReturnExpressionIsCorrectType(symbols: SymbolTable,
                                                             functionType: FunctionType,
                                                             func node: FunctionDeclaration) throws {
        let tracer = StatementTracer(symbols: symbols)
        let traces = try tracer.trace(ast: node.body)
        for trace in traces {
            if let last = trace.last {
                switch last {
                case .Return:
                    break
                default:
                    if functionType.returnType != .void {
                        throw makeErrorForMissingReturn(symbols, functionType, node)
                    }
                }
            } else if functionType.returnType != .void {
                throw makeErrorForMissingReturn(symbols, functionType, node)
            }
        }
    }
    
    private func makeErrorForMissingReturn(_ symbols: SymbolTable,
                                           _ functionType: FunctionType,
                                           _ node: FunctionDeclaration) -> CompilerError {
        return CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                             message: "missing return in a function expected to return `\(functionType.returnType)'")
    }
    
    private func shouldSynthesizeTerminalReturnStatement(symbols: SymbolTable,
                                                         functionType: FunctionType,
                                                         func node: FunctionDeclaration) throws -> Bool {
        guard functionType.returnType == .void else {
            return false
        }
        let tracer = StatementTracer(symbols: symbols)
        let traces = try! tracer.trace(ast: node.body)
        var allTracesEndInReturnStatement = true
        for trace in traces {
            if let last = trace.last {
                switch last {
                case .Return:
                    break
                default:
                    allTracesEndInReturnStatement = false
                }
            } else {
                allTracesEndInReturnStatement = false
            }
        }
        return !allTracesEndInReturnStatement
    }
}
