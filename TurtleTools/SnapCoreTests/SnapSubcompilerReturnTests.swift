//
//  SnapSubcompilerReturnTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 8/8/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class SnapSubcompilerReturnTests: XCTestCase {
    func testCompilationFailsBecauseReturnIsInvalidOutsideFunction() {
        let ast = Return(LiteralBool(true))
        let symbols = Env()
        let compiler = SnapSubcompilerReturn(symbols)
        XCTAssertThrowsError(try compiler.compile(ast)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "return is invalid outside of a function")
        }
    }

    func testUnexpectedNonVoidReturnValueInVoidFunction() {
        let input = Return(ExprUtils.makeU8(value: 1))
        let symbols = Env()
        symbols.breadcrumb = .functionType(
            FunctionTypeInfo(
                returnType: .void,
                arguments: []
            )
        )
        let compiler = SnapSubcompilerReturn(symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "unexpected non-void return value in void function"
            )
        }
    }

    func testItIsCompletelyValidToHaveMeaninglessReturnStatementAtBottomOfVoidFunction() {
        let input = Return()
        let symbols = Env()
        symbols.breadcrumb = .functionType(
            FunctionTypeInfo(
                returnType: .void,
                arguments: []
            )
        )
        let compiler = SnapSubcompilerReturn(symbols)
        XCTAssertNoThrow(try compiler.compile(input))
    }

    func testNonVoidFunctionShouldReturnAValue() {
        let input = Return()
        let symbols = Env()
        symbols.breadcrumb = .functionType(
            FunctionTypeInfo(
                returnType: .u8,
                arguments: []
            )
        )
        let compiler = SnapSubcompilerReturn(symbols)
        XCTAssertThrowsError(try compiler.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "non-void function should return a value")
        }
    }

    func testReturnAValue() {
        let input = Return(LiteralInt(1))
        let symbols = Env()
        symbols.breadcrumb = .functionType(
            FunctionTypeInfo(
                returnType: .u8,
                arguments: []
            )
        )
        let compiler = SnapSubcompilerReturn(symbols)
        var output: AbstractSyntaxTreeNode? = nil
        XCTAssertNoThrow(output = try compiler.compile(input))
        XCTAssertEqual(
            output,
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
