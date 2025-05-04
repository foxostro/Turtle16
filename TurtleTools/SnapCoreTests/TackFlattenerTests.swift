//
//  TackFlattenerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/6/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import XCTest

final class TackFlattenerTests: XCTestCase {
    func testFlattenEmptyProgram() throws {
        let expected = TackProgram(instructions: [], labels: [:])
        let program = Seq()
        let actual = try TackFlattener.compile(program)
        XCTAssertEqual(actual, expected)
    }

    func testUnsupportedNode() throws {
        let program = LiteralInt(0)
        XCTAssertThrowsError(try TackFlattener.compile(program)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "unsupported node: `0'")
        }
    }

    func testSingleInstruction() throws {
        let program = TackInstructionNode(.nop)
        let expected = TackProgram(instructions: [.nop], labels: [:], ast: program)
        let actual = try TackFlattener.compile(program)
        XCTAssertEqual(actual, expected)
    }

    func testSeqWithOneLevel() throws {
        let program = Seq(children: [TackInstructionNode(.nop)])
        let expected = TackProgram(instructions: [.nop], labels: [:], ast: program)
        let actual = try TackFlattener.compile(program)
        XCTAssertEqual(actual, expected)
    }

    func testSeqWithTwoLevels() throws {
        let program = Seq(children: [Seq(children: [TackInstructionNode(.nop)])])
        let expected = TackProgram(instructions: [.nop], labels: [:], ast: program)
        let actual = try TackFlattener.compile(program)
        XCTAssertEqual(actual, expected)
    }

    func testLabelDeclaration() throws {
        let program = Seq(children: [LabelDeclaration(ParameterIdentifier("foo"))])
        let expected = TackProgram(instructions: [], labels: ["foo": 0], ast: program)
        let actual = try TackFlattener.compile(program)
        XCTAssertEqual(actual, expected)
    }

    func testLabelDeclarationRedeclaration() throws {
        let program = Seq(children: [
            LabelDeclaration(ParameterIdentifier("foo")),
            LabelDeclaration(ParameterIdentifier("foo"))
        ])
        XCTAssertThrowsError(try TackFlattener.compile(program)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "label redefines existing symbol: `foo'")
        }
    }

    func testSubroutine() throws {
        // There must be a HLT instruction separating the first compiled
        // subroutine body from the initial portion of the program. Execution
        // starts at PC=0 and must not run blindly into the subroutine bodies.
        let program = Subroutine(
            identifier: "foo",
            children: [
                TackInstructionNode(.nop)
            ]
        )
        let expected = TackProgram(
            instructions: [
                .hlt,
                .nop
            ],
            subroutines: [
                nil,
                "foo"
            ],
            labels: [
                "foo": 1
            ],
            ast: program
        )
        let actual = try TackFlattener.compile(program)
        XCTAssertEqual(actual, expected)
    }
}
