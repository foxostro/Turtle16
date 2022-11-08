//
//  TackFlattenerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 11/6/22.
//  Copyright © 2022 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore

final class TackFlattenerTests: XCTestCase {
    func testFlattenEmptyProgram() throws {
        let expected = FlatTack(instructions: [], labels: [:])
        let program = Seq()
        let actual = try TackFlattener().compile(program)
        XCTAssertEqual(actual, expected)
    }
    
    func testUnsupportedNode() throws {
        let program = Expression.LiteralInt(0)
        XCTAssertThrowsError(try TackFlattener().compile(program)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "unsupported node: `0'")
        }
    }
    
    func testSingleInstruction() throws {
        let expected = FlatTack(instructions: [.nop], labels: [:])
        let program = TackInstructionNode(.nop)
        let actual = try TackFlattener().compile(program)
        XCTAssertEqual(actual, expected)
    }
    
    func testSeqWithOneLevel() throws {
        let expected = FlatTack(instructions: [.nop], labels: [:])
        let program = Seq(children: [TackInstructionNode(.nop)])
        let actual = try TackFlattener().compile(program)
        XCTAssertEqual(actual, expected)
    }
    
    func testSeqWithTwoLevels() throws {
        let expected = FlatTack(instructions: [.nop], labels: [:])
        let program = Seq(children: [Seq(children: [TackInstructionNode(.nop)])])
        let actual = try TackFlattener().compile(program)
        XCTAssertEqual(actual, expected)
    }
    
    func testLabelDeclaration() throws {
        let expected = FlatTack(instructions: [], labels: ["foo":0])
        let program = Seq(children: [LabelDeclaration(ParameterIdentifier("foo"))])
        let actual = try TackFlattener().compile(program)
        XCTAssertEqual(actual, expected)
    }
    
    func testLabelDeclarationRedeclaration() throws {
        let program = Seq(children: [
            LabelDeclaration(ParameterIdentifier("foo")),
            LabelDeclaration(ParameterIdentifier("foo"))
        ])
        XCTAssertThrowsError(try TackFlattener().compile(program)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "label redefines existing symbol: `foo'")
        }
    }
    
    func testSubroutine() throws {
        let expected = FlatTack(instructions: [.nop], labels: ["foo":0])
        let program = Subroutine(identifier: "foo", children: [
            TackInstructionNode(.nop)
        ])
        let actual = try TackFlattener().compile(program)
        XCTAssertEqual(actual, expected)
    }
}
