//
//  SnapSubcompilerReturn.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/8/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore

public struct SnapSubcompilerReturn {
    public let symbols: Env

    public init(_ symbols: Env) {
        self.symbols = symbols
    }

    public func compile(_ node: Return) throws -> Seq {
        guard let enclosingFunctionType = symbols.enclosingFunctionType else {
            throw CompilerError(
                sourceAnchor: node.sourceAnchor,
                message: "return is invalid outside of a function"
            )
        }

        var output: [AbstractSyntaxTreeNode] = []

        if let expr = node.expression {
            guard enclosingFunctionType.returnType != .void else {
                throw CompilerError(
                    sourceAnchor: node.expression?.sourceAnchor ?? node.sourceAnchor,
                    message: "unexpected non-void return value in void function"
                )
            }

            // Synthesize an assignment to the special return value symbol.
            let kReturnValueIdentifier = "__returnValue"
            let typeChecker = RvalueExpressionTypeChecker(symbols: symbols)
            let returnExpressionType = try typeChecker.check(expression: expr)
            try typeChecker.checkTypesAreConvertibleInAssignment(
                ltype: enclosingFunctionType.returnType,
                rtype: returnExpressionType,
                sourceAnchor: node.sourceAnchor,
                messageWhenNotConvertible: "cannot convert return expression of type `\(returnExpressionType)' to return type `\(enclosingFunctionType.returnType)'"
            )
            let lexpr = Identifier(
                sourceAnchor: node.sourceAnchor,
                identifier: kReturnValueIdentifier
            )
            output.append(
                Assignment(
                    sourceAnchor: node.sourceAnchor,
                    lexpr: lexpr,
                    rexpr: expr
                )
            )
        }
        else if enclosingFunctionType.returnType != .void {
            throw CompilerError(
                sourceAnchor: node.sourceAnchor,
                message: "non-void function should return a value"
            )
        }

        output.append(Return(sourceAnchor: node.sourceAnchor, expression: nil))

        return Seq(sourceAnchor: node.sourceAnchor, children: output)
    }
}
