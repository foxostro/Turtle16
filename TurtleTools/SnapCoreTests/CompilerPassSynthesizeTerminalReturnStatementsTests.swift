//
//  CompilerPassSynthesizeTerminalReturnStatementsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/16/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleCore
import SnapCore

final class CompilerPassSynthesizeTerminalReturnStatementsTests: XCTestCase {
    func testFunctionBodyMissingReturn() throws {
        let ast = Block(children: [
            FunctionDeclaration(
                identifier: Expression.Identifier("foo"),
                functionType: Expression.FunctionType(
                    name: "foo",
                    returnType: Expression.PrimitiveType(.u8),
                    arguments: []),
                argumentNames: [],
                body: Block(children: []))
        ])
            .reconnect(parent: nil)
        
        XCTAssertThrowsError(try ast.synthesizeTerminalReturnStatements()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "missing return in a function expected to return `u8'")
        }
    }
    
    func testSynthesizeTerminalReturnStatementInSimpleFunctionBody() throws {
        let outerBlockId = AbstractSyntaxTreeNode.ID()
        let fnBodyId = AbstractSyntaxTreeNode.ID()
        
        let ast0 = Block(
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("foo"),
                    functionType: Expression.FunctionType(
                        name: "foo",
                        returnType: Expression.PrimitiveType(.void),
                        arguments: []),
                    argumentNames: [],
                    body: Block(children: [], id: fnBodyId))
            ],
            id: outerBlockId)
            .reconnect(parent: nil)
        
        let expected = Block(
            children: [
                FunctionDeclaration(
                    identifier: Expression.Identifier("foo"),
                    functionType: Expression.FunctionType(
                        name: "foo",
                        returnType: Expression.PrimitiveType(.void),
                        arguments: []),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return()
                        ],
                        id: fnBodyId))
            ],
            id: outerBlockId)
            .reconnect(parent: nil)
        
        let ast1 = try ast0.synthesizeTerminalReturnStatements()
        
        XCTAssertEqual(ast1, expected)
    }
}
