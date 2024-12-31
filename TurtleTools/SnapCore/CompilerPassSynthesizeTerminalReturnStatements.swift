//
//  CompilerPassSynthesizeTerminalReturnStatements.swift
//  SnapCore
//
//  Created by Andrew Fox on 12/16/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import TurtleCore

/// Synthesize an explicit terminal return statement on functions with an implicit return
public class CompilerPassSynthesizeTerminalReturnStatements: CompilerPassWithDeclScan {
    public override func visit(func node: FunctionDeclaration) throws -> AbstractSyntaxTreeNode? {
        FunctionDeclaration(
            sourceAnchor: node.sourceAnchor,
            identifier: try visit(identifier: node.identifier) as! Expression.Identifier,
            functionType: try visit(expr: node.functionType) as! Expression.FunctionType,
            argumentNames: node.argumentNames,
            typeArguments: try node.typeArguments.compactMap {
                try visit(genericTypeArgument: $0) as! Expression.GenericTypeArgument?
            },
            body: try visitFunctionBody(func: node),
            visibility: node.visibility,
            symbols: node.symbols,
            id: node.id)
    }
    
    private func visitFunctionBody(func fn: FunctionDeclaration) throws -> Block {
        try expectFunctionReturnExpressionIsCorrectType(fn)
        let body0 = fn.body
        let body1 = try super.visit(block: body0) as! Block
        let body2 = if try shouldSynthesizeTerminalReturnStatement(fn) {
            body1.appending(children: [
                Return(
                    sourceAnchor: body1.sourceAnchor,
                    expression: nil)
            ])
        } else {
            body1
        }
        return body2
    }
    
    private func expectFunctionReturnExpressionIsCorrectType(_ node: FunctionDeclaration) throws {
        let functionType = try TypeContextTypeChecker(symbols: symbols!)
            .check(expression: node.functionType)
            .unwrapFunctionType()
        guard functionType.returnType != .void else { return }
        for trace in try trace(node) {
            if trace.last != .Return {
                throw CompilerError(
                    sourceAnchor: node.identifier.sourceAnchor,
                    message: "missing return in a function expected to return `\(functionType.returnType)'")
            }
        }
    }
    
    private func trace(_ node: FunctionDeclaration) throws -> [StatementTracer.Trace] {
        try StatementTracer(symbols: symbols!).trace(ast: node.body)
    }
    
    private func shouldSynthesizeTerminalReturnStatement(_ node: FunctionDeclaration) throws -> Bool {
        let functionType = try TypeContextTypeChecker(symbols: symbols!)
            .check(expression: node.functionType)
            .unwrapFunctionType()
        guard functionType.returnType == .void else { return false }
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

extension AbstractSyntaxTreeNode {
    /// Synthesize an explicit terminal return statement on functions with an implicit return
    public func synthesizeTerminalReturnStatements(_ globalEnvironment: GlobalEnvironment) throws -> AbstractSyntaxTreeNode? {
        try CompilerPassSynthesizeTerminalReturnStatements(globalEnvironment: globalEnvironment).run(self)
    }
}
