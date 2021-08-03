//
//  SnapASTTransformerFunctionDeclaration.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/2/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerFunctionDeclaration: SnapASTTransformerBase {
    public override func compile(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode {
        let name = node.identifier.identifier
        
        guard symbols!.existsAndCannotBeShadowed(identifier: name) == false else {
            throw CompilerError(sourceAnchor: node.identifier.sourceAnchor,
                                message: "function redefines existing symbol: `\(name)'")
        }
        
        let functionType = try evaluateFunctionTypeExpression(node.functionType)
        let typ: SymbolType = .function(functionType)
        let symbol = Symbol(type: typ, offset: 0, storage: .automaticStorage, visibility: node.visibility)
        symbols!.bind(identifier: name, symbol: symbol)
        
        return try super.compile(func: node)
    }
    
    func evaluateFunctionTypeExpression(_ expr: Expression) throws -> FunctionType {
        return try TypeContextTypeChecker(symbols: symbols!).check(expression: expr).unwrapFunctionType()
    }
}
