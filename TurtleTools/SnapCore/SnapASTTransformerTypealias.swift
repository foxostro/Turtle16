//
//  SnapASTTransformerTypealias.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/3/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public class SnapASTTransformerTypealias: SnapASTTransformerBase {
    public override func compile(typealias node: Typealias) throws -> AbstractSyntaxTreeNode {
        guard false == symbols!.existsAsTypeAndCannotBeShadowed(identifier: node.lexpr.identifier) else {
            throw CompilerError(sourceAnchor: node.lexpr.sourceAnchor,
                                message: "typealias redefines existing type: `\(node.lexpr.identifier)'")
        }
        let typeChecker = RvalueExpressionTypeChecker(symbols: symbols!)
        let symbolType = try typeChecker.check(expression: node.rexpr)
        symbols!.bind(identifier: node.lexpr.identifier,
                      symbolType: symbolType,
                      visibility: node.visibility)
        
        return try super.compile(typealias: node)
    }
}
