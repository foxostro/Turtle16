//
//  CompilerPassReturn.swift
//  SnapCore
//
//  Created by Andrew Fox on 8/26/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Compiler pass to lower and erase "return" statements
public final class CompilerPassReturn: CompilerPassWithDeclScan {
    public override func visit(return node0: Return) throws -> AbstractSyntaxTreeNode? {
        let node1 = try super.visit(return: node0) as! Return

        guard let symbols else {
            throw CompilerError(
                sourceAnchor: node1.sourceAnchor,
                message: "internal compiler error: missing symbols"
            )
        }

        guard let enclosingFunctionType = symbols.enclosingFunctionType else {
            throw CompilerError(
                sourceAnchor: node1.sourceAnchor,
                message: "return is invalid outside of a function"
            )
        }

        var output: [AbstractSyntaxTreeNode] = []

        if let expr = node1.expression {
            guard enclosingFunctionType.returnType != .void else {
                throw CompilerError(
                    sourceAnchor: node1.expression?.sourceAnchor ?? node1.sourceAnchor,
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
                sourceAnchor: node1.sourceAnchor,
                messageWhenNotConvertible: "cannot convert return expression of type `\(returnExpressionType)' to return type `\(enclosingFunctionType.returnType)'"
            )
            let lexpr = Identifier(
                sourceAnchor: node1.sourceAnchor,
                identifier: kReturnValueIdentifier
            )
            output.append(
                Assignment(
                    sourceAnchor: node1.sourceAnchor,
                    lexpr: lexpr,
                    rexpr: expr
                )
            )
        }
        else if enclosingFunctionType.returnType != .void {
            throw CompilerError(
                sourceAnchor: node1.sourceAnchor,
                message: "non-void function should return a value"
            )
        }

        output.append(Return(sourceAnchor: node1.sourceAnchor, expression: nil))

        return Seq(sourceAnchor: node1.sourceAnchor, children: output)
    }
}

public extension AbstractSyntaxTreeNode {
    /// Compiler pass to lower and erase "return" statements
    func returnPass() throws -> AbstractSyntaxTreeNode? {
        try CompilerPassReturn().run(self)
    }
}
