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
    
    public init(_ symbols: SymbolTable? = nil) {
        self.symbols = symbols
    }
    
    public func compile(_ node: FunctionDeclaration) throws -> FunctionDeclaration {
        let name = node.identifier.identifier
        
        guard symbols!.existsAndCannotBeShadowed(identifier: name) == false else {
            throw CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                                message: "function redefines existing symbol: `\(name)'")
        }
        
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        node.symbols.enclosingFunctionTypeMode = .set(functionType)
        node.symbols.enclosingFunctionNameMode = .set(name)
        
        let symbol = Symbol(type: .function(functionType), offset: 0, storage: .automaticStorage, visibility: node.visibility)
        symbols!.bind(identifier: name, symbol: symbol)
        
        return node
    }
    
    func evaluateFunctionTypeExpression(_ expr: Expression) throws -> FunctionType {
        return try TypeContextTypeChecker(symbols: symbols!).check(expression: expr).unwrapFunctionType()
    }
}
