//
//  CompilerPassReturnTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/8/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class CompilerPassReturnTests: XCTestCase {
    func testCompilationFailsBecauseReturnIsInvalidOutsideFunction() {
        let ast = Block(
            children: [
                Return(LiteralBool(true))
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try ast.returnPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "return is invalid outside of a function")
        }
    }

    func testUnexpectedNonVoidReturnValueInVoidFunction() {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("test"),
                    functionType: FunctionType(
                        name: "test",
                        returnType: PrimitiveType(.void),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return(ExprUtils.makeU8(value: 1))
                        ]
                    )
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try input.returnPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "unexpected non-void return value in void function"
            )
        }
    }

    func testItIsCompletelyValidToHaveMeaninglessReturnStatementAtBottomOfVoidFunction() {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("test"),
                    functionType: FunctionType(
                        name: "test",
                        returnType: PrimitiveType(.void),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return()
                        ]
                    )
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertNoThrow(try input.returnPass())
    }

    func testNonVoidFunctionShouldReturnAValue() {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("test"),
                    functionType: FunctionType(
                        name: "test",
                        returnType: PrimitiveType(.u8),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return()
                        ]
                    )
                )
            ]
        )
        .reconnect(parent: nil)

        XCTAssertThrowsError(try input.returnPass()) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "non-void function should return a value")
        }
    }

    func testReturnAValue() throws {
        let input = Block(
            children: [
                FunctionDeclaration(
                    identifier: Identifier("test"),
                    functionType: FunctionType(
                        name: "test",
                        returnType: PrimitiveType(.u8),
                        arguments: []
                    ),
                    argumentNames: [],
                    body: Block(
                        children: [
                            Return(LiteralInt(1))
                        ]
                    )
                )
            ]
        )
        .reconnect(parent: nil)

        let output = try input.returnPass()

        // Navigate to the return statement in the transformed AST
        guard let block = output as? Block,
              let fn = (block.children.first) as? FunctionDeclaration,
              let ret = fn.body.children.first as? Seq else {
            XCTFail("Expected transformed function with return statement")
            return
        }

        XCTAssertEqual(
            ret,
            Seq(children: [
                Assignment(
                    lexpr: Identifier("__returnValue"),
                    rexpr: LiteralInt(1)
                ),
                Return()
            ])
        )
    }
}
