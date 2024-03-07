//
//  SnapSubcompilerFunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerFunctionDeclaration: NSObject {
    public func compile(globalEnvironment: GlobalEnvironment,
                        symbols: SymbolTable,
                        node: FunctionDeclaration) throws {
        assert(node.symbols.frameLookupMode.isSet)
        let name = node.identifier.identifier
        
        guard symbols.existsAndCannotBeShadowed(identifier: name) == false else {
            throw CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                                message: "function redefines existing symbol: `\(name)'")
        }
        
        if node.isGeneric {
            try doGeneric(symbols: symbols,
                          node: node)
        }
        else {
            try doNonGeneric(globalEnvironment: globalEnvironment,
                             symbols: symbols,
                             node: node)
        }
    }
    
    private func doGeneric(symbols: SymbolTable,
                           node: FunctionDeclaration) throws {
        let name = node.identifier.identifier
        let typ = Expression.GenericFunctionType(template: node)
        let symbol = Symbol(type: .genericFunction(typ),
                            offset: 0,
                            storage: .automaticStorage,
                            visibility: node.visibility)
        symbols.bind(identifier: name, symbol: symbol)
    }
    
    private func doNonGeneric(globalEnvironment: GlobalEnvironment,
                              symbols: SymbolTable,
                              node: FunctionDeclaration) throws {
        let functionType = try evaluateFunctionTypeExpression(symbols, node.functionType)
        try instantiate(memoryLayoutStrategy: globalEnvironment.memoryLayoutStrategy,
                        functionType: functionType,
                        functionDeclaration: node)
        
        let name = node.identifier.identifier
        let symbol = Symbol(type: .function(functionType),
                            offset: 0,
                            storage: .automaticStorage,
                            visibility: node.visibility)
        symbols.bind(identifier: name, symbol: symbol)
        
        globalEnvironment.functionsToCompile.enqueue(functionType)
    }
    
    public func instantiate(memoryLayoutStrategy: MemoryLayoutStrategy,
                            functionType: FunctionType,
                            functionDeclaration node: FunctionDeclaration) throws {
        let name = node.identifier.identifier
        
        node.symbols.enclosingFunctionTypeMode = .set(functionType)
        node.symbols.enclosingFunctionNameMode = .set(name)
        node.body.symbols.parent = node.symbols
        
        bindFunctionArguments(memoryLayoutStrategy: memoryLayoutStrategy,
                              symbols: node.symbols,
                              functionType: functionType,
                              argumentNames: node.argumentNames)
        try expectFunctionReturnExpressionIsCorrectType(symbols: node.symbols,
                                                        functionType: functionType,
                                                        func: node)
        
        let body: Block
        if try shouldSynthesizeTerminalReturnStatement(symbols: node.symbols,
                                                       functionType: functionType,
                                                       func: node) {
            let ret = Return(sourceAnchor: node.sourceAnchor, expression: nil)
            body = Block(sourceAnchor: node.body.sourceAnchor,
                         symbols: node.body.symbols,
                         children: node.body.children + [ret])
        } else {
            body = node.body
        }
        
        let rewrittenFunctionDeclaration = FunctionDeclaration(sourceAnchor: node.sourceAnchor,
                                                               identifier: node.identifier,
                                                               functionType: node.functionType,
                                                               argumentNames: node.argumentNames,
                                                               body: body,
                                                               visibility: node.visibility,
                                                               symbols: node.symbols)
        functionType.ast = rewrittenFunctionDeclaration
    }
    
    private func evaluateFunctionTypeExpression(_ symbols: SymbolTable,
                                                _ expr: Expression) throws -> FunctionType {
        return try TypeContextTypeChecker(symbols: symbols).check(expression: expr).unwrapFunctionType()
    }
    
    private func bindFunctionArguments(memoryLayoutStrategy: MemoryLayoutStrategy,
                                       symbols: SymbolTable,
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
