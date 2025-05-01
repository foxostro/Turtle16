//
//  AssemblerListingMakerTests.swift
//  TurtleSimulatorCoreTests
//
//  Created by Andrew Fox on 7/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore
import XCTest

final class AssemblerListingMakerTests: XCTestCase {
    func testEmptyProgram() throws {
        let ast = TopLevel(children: [])
        let actual = AssemblerListingMaker().makeListing(ast)
        XCTAssertEqual(actual, "")
    }

    func testNOP() throws {
        let ast = TopLevel(children: [
            InstructionNode(instruction: "NOP", parameters: [])
        ])
        let actual = AssemblerListingMaker().makeListing(ast)
        XCTAssertEqual(actual, "NOP")
    }

    func testADD() throws {
        let ast = TopLevel(children: [
            InstructionNode(
                instruction: "ADD",
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = AssemblerListingMaker().makeListing(ast)
        XCTAssertEqual(actual, "ADD r2, r1, r0")
    }

    func testADDI() throws {
        let ast = TopLevel(children: [
            InstructionNode(
                instruction: "ADDI",
                parameters: [
                    ParameterIdentifier("r0"), ParameterIdentifier("r0"), ParameterNumber(1),
                ]
            )
        ])
        let actual = AssemblerListingMaker().makeListing(ast)
        XCTAssertEqual(actual, "ADDI r0, r0, 1")
    }

    func testLabel() throws {
        let ast = TopLevel(children: [
            LabelDeclaration(identifier: "foo")
        ])
        let actual = AssemblerListingMaker().makeListing(ast)
        XCTAssertEqual(actual, "foo:")
    }

    func testComment() throws {
        let ast = TopLevel(children: [
            CommentNode(string: "comment")
        ])
        let actual = AssemblerListingMaker().makeListing(ast)
        XCTAssertEqual(actual, "# comment")
    }

    func testCommentSpansMultipleLines() throws {
        let ast = TopLevel(children: [
            CommentNode(string: "first line\nsecond line")
        ])
        let actual = AssemblerListingMaker().makeListing(ast)
        XCTAssertEqual(actual, "# first line\n# second line")
    }
}
