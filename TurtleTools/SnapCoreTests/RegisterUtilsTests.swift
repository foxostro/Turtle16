//
//  RegisterUtilsTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 12/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleSimulatorCore
import XCTest

final class RegisterUtilsTests: XCTestCase {
    func testGetReferencedRegisters_Label() throws {
        let result = RegisterUtils.getReferencedRegisters(LabelDeclaration(identifier: ""))
        XCTAssertTrue(result.isEmpty)
    }

    func testGetReferencedRegisters_RET() throws {
        let result = RegisterUtils.getReferencedRegisters(InstructionNode(instruction: kRET))
        XCTAssertTrue(result.isEmpty)
    }

    func testGetReferencedRegisters_LA() throws {
        let result = RegisterUtils.getReferencedRegisters(
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("foo")
                ]
            )
        )
        XCTAssertEqual(result, ["r0"])
    }

    func testGetReferencedRegisters_ADD() throws {
        let result = RegisterUtils.getReferencedRegisters(
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0")
                ]
            )
        )
        XCTAssertEqual(result, ["r0", "r1", "r2"])
    }

    func testGetSourceRegisters_Label() throws {
        let result = RegisterUtils.getSourceRegisters(LabelDeclaration(identifier: ""))
        XCTAssertTrue(result.isEmpty)
    }

    func testGetSourceRegisters_LA() throws {
        let result = RegisterUtils.getSourceRegisters(
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("foo")
                ]
            )
        )
        XCTAssertTrue(result.isEmpty)
    }

    func testGetSourceRegisters_ADD() throws {
        let result = RegisterUtils.getSourceRegisters(
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0")
                ]
            )
        )
        XCTAssertEqual(result, ["r0", "r1"])
    }

    func testGetSourceRegisters_CMP() throws {
        let result = RegisterUtils.getSourceRegisters(
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0")
                ]
            )
        )
        XCTAssertEqual(result, ["r0", "r1"])
    }

    func testGetSourceRegisters_CMPI() throws {
        let result = RegisterUtils.getSourceRegisters(
            InstructionNode(
                instruction: kCMPI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(42)
                ]
            )
        )
        XCTAssertEqual(result, ["r0"])
    }

    func testGetSourceRegisters_RET() throws {
        let result = RegisterUtils.getSourceRegisters(InstructionNode(instruction: kRET))
        XCTAssertTrue(result.isEmpty)
    }

    func testGetSourceRegisters_STORE() throws {
        let result = RegisterUtils.getSourceRegisters(
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("r1"),
                    ParameterNumber(42)
                ]
            )
        )
        XCTAssertEqual(result, ["r1", "r0"])
    }

    func testGetDestinationRegisters_Label() throws {
        let result = RegisterUtils.getDestinationRegisters(LabelDeclaration(identifier: ""))
        XCTAssertTrue(result.isEmpty)
    }

    func testGetDestinationRegisters_LA() throws {
        let result = RegisterUtils.getDestinationRegisters(
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("foo")
                ]
            )
        )
        XCTAssertEqual(result, ["r0"])
    }

    func testGetDestinationRegisters_ADD() throws {
        let result = RegisterUtils.getDestinationRegisters(
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0")
                ]
            )
        )
        XCTAssertEqual(result, ["r2"])
    }

    func testGetDestinationRegisters_CMP() throws {
        let result = RegisterUtils.getDestinationRegisters(
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0")
                ]
            )
        )
        XCTAssertEqual(result, [])
    }

    func testGetDestinationRegisters_CMPI() throws {
        let result = RegisterUtils.getDestinationRegisters(
            InstructionNode(
                instruction: kCMPI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(42)
                ]
            )
        )
        XCTAssertEqual(result, [])
    }

    func testGetDestinationRegisters_STORE() throws {
        let result = RegisterUtils.getDestinationRegisters(
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("r1"),
                    ParameterNumber(42)
                ]
            )
        )
        XCTAssertEqual(result, [])
    }

    func testRewriteNOP() throws {
        let input = [
            InstructionNode(instruction: kNOP)
        ]
        let expected = [
            InstructionNode(instruction: kNOP)
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteLabel() throws {
        let input = [
            LabelDeclaration(identifier: "")
        ]
        let expected = [
            LabelDeclaration(identifier: "")
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteCMP() throws {
        let input = [
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteADD() throws {
        let input = [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteSUB() throws {
        let input = [
            InstructionNode(
                instruction: kSUB,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kSUB,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteAND() throws {
        let input = [
            InstructionNode(
                instruction: kAND,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kAND,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteOR() throws {
        let input = [
            InstructionNode(
                instruction: kOR,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kOR,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteXOR() throws {
        let input = [
            InstructionNode(
                instruction: kXOR,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kXOR,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteNOT() throws {
        let input = [
            InstructionNode(
                instruction: kNOT,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kNOT,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteCMPI() throws {
        let input = [
            InstructionNode(
                instruction: kCMPI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kCMPI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteADDI() throws {
        let input = [
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteSUBI() throws {
        let input = [
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteANDI() throws {
        let input = [
            InstructionNode(
                instruction: kANDI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kANDI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteORI() throws {
        let input = [
            InstructionNode(
                instruction: kORI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kORI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteXORI() throws {
        let input = [
            InstructionNode(
                instruction: kXORI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kXORI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteADC() throws {
        let input = [
            InstructionNode(
                instruction: kADC,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kADC,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteSBC() throws {
        let input = [
            InstructionNode(
                instruction: kSBC,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kSBC,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteLI() throws {
        let input = [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(1)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(1)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteLUI() throws {
        let input = [
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(1)
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(1)
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteJR() throws {
        let input = [
            InstructionNode(
                instruction: kJR,
                parameters: [
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kJR,
                parameters: [
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteCALLPTR() throws {
        let input = [
            InstructionNode(
                instruction: kCALLPTR,
                parameters: [
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kCALLPTR,
                parameters: [
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteJALR() throws {
        let input = [
            InstructionNode(
                instruction: kJALR,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kJALR,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteLOAD() throws {
        let input = [
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteSTORE() throws {
        let input = [
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("r0")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }

    func testRewriteLA() throws {
        let input = [
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterIdentifier("foo")
                ]
            )
        ]
        let expected = [
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("foo")
                ]
            )
        ]
        let actual = RegisterUtils.rewrite(nodes: input, from: "vr0", to: "r0")
        XCTAssertEqual(actual, expected)
    }
}
