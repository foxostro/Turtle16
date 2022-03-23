//
//  SnapSubcompilerFunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapSubcompilerFunctionDeclaration: NSObject {
    public private(set) var symbols: SymbolTable? = nil
    public let memoryLayoutStrategy: MemoryLayoutStrategy
    
    public init(memoryLayoutStrategy: MemoryLayoutStrategy, symbols: SymbolTable) {
        self.symbols = symbols
        self.memoryLayoutStrategy = memoryLayoutStrategy
    }
    
    public func compile(_ node: FunctionDeclaration) throws -> FunctionDeclaration {
        let name = node.identifier.identifier
        
        guard symbols!.existsAndCannotBeShadowed(identifier: name) == false else {
            throw CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                                message: "function redefines existing symbol: `\(name)'")
        }
        
        let parent = symbols
        symbols = node.symbols
        
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        node.symbols.enclosingFunctionTypeMode = .set(functionType)
        node.symbols.enclosingFunctionNameMode = .set(name)
        
        bindFunctionArguments(functionType: functionType, argumentNames: node.argumentNames)
        try expectFunctionReturnExpressionIsCorrectType(func: node)
        
        let body: Block
        if try shouldSynthesizeTerminalReturnStatement(func: node) {
            let ret = Return(sourceAnchor: node.sourceAnchor, expression: nil)
            body = Block(sourceAnchor: node.body.sourceAnchor,
                         symbols: node.body.symbols,
                         children: node.body.children + [ret])
        } else {
            body = node.body
        }
        
        symbols = parent
        
        let symbol = Symbol(type: .function(functionType), offset: 0, storage: .automaticStorage, visibility: node.visibility)
        symbols!.bind(identifier: name, symbol: symbol)
        
        return FunctionDeclaration(sourceAnchor: node.sourceAnchor,
                                   identifier: node.identifier,
                                   functionType: node.functionType,
                                   argumentNames: node.argumentNames,
                                   body: body,
                                   visibility: node.visibility,
                                   symbols: node.symbols)
    }
    
    func evaluateFunctionTypeExpression(_ expr: Expression) throws -> FunctionType {
        return try TypeContextTypeChecker(symbols: symbols!).check(expression: expr).unwrapFunctionType()
    }
    
    func bindFunctionArguments(functionType: FunctionType, argumentNames: [String]) {
        var offset = memoryLayoutStrategy.sizeOfSaveArea
        
        for i in (0..<functionType.arguments.count).reversed() {
            let argumentType = functionType.arguments[i]
            let argumentName = argumentNames[i]
            let symbol = Symbol(type: argumentType.correspondingConstType,
                                offset: -offset,
                                storage: .automaticStorage)
            symbols!.bind(identifier: argumentName, symbol: symbol)
            let sizeOfArugmentType = memoryLayoutStrategy.sizeof(type: argumentType)
            offset += sizeOfArugmentType
        }
        
        // Bind a special symbol to contain the function return value.
        // This must be located just before the function arguments.
        let kReturnValueIdentifier = "__returnValue"
        symbols!.bind(identifier: kReturnValueIdentifier,
                      symbol: Symbol(type: functionType.returnType,
                                     offset: -offset,
                                     storage: .automaticStorage))
        let sizeOfFunctionReturnType = memoryLayoutStrategy.sizeof(type: functionType.returnType)
        offset += sizeOfFunctionReturnType
    }
    
    func expectFunctionReturnExpressionIsCorrectType(func node: FunctionDeclaration) throws {
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        let tracer = StatementTracer(symbols: symbols!)
        let traces = try tracer.trace(ast: node.body)
        for trace in traces {
            if let last = trace.last {
                switch last {
                case .Return:
                    break
                default:
                    if functionType.returnType != .void {
                        throw makeErrorForMissingReturn(node)
                    }
                }
            } else if functionType.returnType != .void {
                throw makeErrorForMissingReturn(node)
            }
        }
    }
    
    func makeErrorForMissingReturn(_ node: FunctionDeclaration) -> CompilerError {
        let functionType = try! evaluateFunctionTypeExpression(node.functionType)
        return CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                             message: "missing return in a function expected to return `\(functionType.returnType)'")
    }
    
    func shouldSynthesizeTerminalReturnStatement(func node: FunctionDeclaration) throws -> Bool {
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        guard functionType.returnType == .void else {
            return false
        }
        let tracer = StatementTracer(symbols: symbols!)
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
