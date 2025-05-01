//
//  RegisterAllocatorDriverTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/23/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleSimulatorCore
import XCTest

final class RegisterAllocatorDriverTests: XCTestCase {
    func testNOP() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kNOP)
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kNOP)
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testLabel() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            LabelDeclaration(identifier: "")
        ])
        let expected = TopLevel(children: [
            LabelDeclaration(identifier: "")
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testCMP() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testADD_0() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testADD_1() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("vr4"),
                    ParameterIdentifier("vr3"),
                    ParameterIdentifier("ra"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("ra"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testADD_2() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("vr3"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testSUB() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kSUB,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kSUB,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testAND() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kAND,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kAND,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testOR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kOR,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kOR,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testXOR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kXOR,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kXOR,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testNOT() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kNOT,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kNOT,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testCMPI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kCMPI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kCMPI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(0),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testADDI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testSUBI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testANDI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kANDI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kANDI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testORI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kORI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kORI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testXORI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kXORI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kXORI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                    ParameterNumber(0),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testADC() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kADC,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kADC,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testSBC() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kSBC,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kSBC,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testLI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(1),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(1),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testLUI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(1),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(1),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testJR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kJR,
                parameters: [
                    ParameterIdentifier("vr1")
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kJR,
                parameters: [
                    ParameterIdentifier("r0")
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testCALLPTR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kCALLPTR,
                parameters: [
                    ParameterIdentifier("vr1")
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kCALLPTR,
                parameters: [
                    ParameterIdentifier("r0")
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testJALR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kJALR,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kJALR,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r0"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testLA() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterIdentifier("foo"),
                ]
            )
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kLA,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("foo"),
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testSubroutine() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            Subroutine(
                identifier: "",
                children: [
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("sp"),
                            ParameterIdentifier("fp"),
                            ParameterIdentifier("vr3"),
                        ]
                    )
                ]
            )
        ])
        let expected = TopLevel(children: [
            Subroutine(
                identifier: "",
                children: [
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("sp"),
                            ParameterIdentifier("fp"),
                            ParameterIdentifier("r0"),
                        ]
                    )
                ]
            )
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testRunViaTheCompileChildrenEntryPoint() throws {
        let driver = RegisterAllocatorDriver()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("vr3"),
                ]
            )
        ]
        let expected: [AbstractSyntaxTreeNode] = [
            InstructionNode(
                instruction: kADD,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("r0"),
                ]
            )
        ]
        let actual = try driver.compile(children: input)
        XCTAssertEqual(actual, expected)
    }

    func testSpillFails_InsufficientRegisters() throws {
        let driver = RegisterAllocatorDriver(numRegisters: 0)
        let input = TopLevel(children: [
            InstructionNode(instruction: kENTER),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ])
        XCTAssertThrowsError(try driver.compile(topLevel: input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(
                compilerError?.message,
                "Register allocation failed: insufficient physical registers"
            )
        }
    }

    func testSpillFails_MissingLeadingEnter() throws {
        // When there is no leading ENTER instruction, insert one.
        let driver = RegisterAllocatorDriver(numRegisters: 2)
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kENTER,
                parameters: [
                    ParameterNumber(3)
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-3),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("r1"),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-3),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("r1"),
                ]
            ),
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testSpill() throws {
        let driver = RegisterAllocatorDriver(numRegisters: 2)
        let input = TopLevel(children: [
            InstructionNode(instruction: kENTER),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterIdentifier("vr0"),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr0"),
                ]
            ),
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kENTER, parameter: ParameterNumber(3)),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-3),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-2),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("r1"),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("fp"),
                    ParameterNumber(-3),
                ]
            ),
            InstructionNode(
                instruction: kCMP,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterIdentifier("r1"),
                ]
            ),
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }

    func testFixBugWhenInsertedSpillCodeChangesTheLiveRanges() throws {
        let driver = RegisterAllocatorDriver(numRegisters: 5)
        let input = TopLevel(children: [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(16),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("vr0"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(18),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("vr1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr2"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr3"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr3"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr4"),
                    ParameterNumber(3),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr4"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr5"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(3),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr6"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr7"),
                    ParameterIdentifier("vr6"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr8"),
                    ParameterIdentifier("vr1"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr9"),
                    ParameterIdentifier("vr8"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr9"),
                    ParameterIdentifier("vr7"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr7"),
                    ParameterIdentifier("vr7"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr8"),
                    ParameterIdentifier("vr8"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr9"),
                    ParameterIdentifier("vr8"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr9"),
                    ParameterIdentifier("vr7"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr7"),
                    ParameterIdentifier("vr7"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr8"),
                    ParameterIdentifier("vr8"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr9"),
                    ParameterIdentifier("vr8"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr9"),
                    ParameterIdentifier("vr7"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr7"),
                    ParameterIdentifier("vr7"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("vr8"),
                    ParameterIdentifier("vr8"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kCALL,
                parameters: [
                    ParameterIdentifier("sum")
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr10"),
                    ParameterNumber(17),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("vr10"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr11"),
                    ParameterIdentifier("vr5"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr11"),
                    ParameterIdentifier("vr10"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(4),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("vr12"),
                    ParameterNumber(17),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("vr12"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("vr13"),
                    ParameterIdentifier("vr12"),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("vr13"),
                    ParameterIdentifier("vr0"),
                ]
            ),
            Subroutine(
                identifier: "sum",
                children: [
                    InstructionNode(instruction: kENTER, parameter: ParameterNumber(0)),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("vr14"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(10),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("vr15"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(7),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLI,
                        parameters: [
                            ParameterIdentifier("vr16"),
                            ParameterNumber(2),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("vr17"),
                            ParameterIdentifier("vr16"),
                            ParameterIdentifier("vr15"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("vr18"),
                            ParameterIdentifier("vr17"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("vr19"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(7),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLI,
                        parameters: [
                            ParameterIdentifier("vr20"),
                            ParameterNumber(1),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("vr21"),
                            ParameterIdentifier("vr20"),
                            ParameterIdentifier("vr19"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("vr22"),
                            ParameterIdentifier("vr21"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("vr23"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(7),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLI,
                        parameters: [
                            ParameterIdentifier("vr24"),
                            ParameterNumber(0),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("vr25"),
                            ParameterIdentifier("vr24"),
                            ParameterIdentifier("vr23"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("vr26"),
                            ParameterIdentifier("vr25"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("vr27"),
                            ParameterIdentifier("vr26"),
                            ParameterIdentifier("vr22"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("vr28"),
                            ParameterIdentifier("vr27"),
                            ParameterIdentifier("vr18"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kSTORE,
                        parameters: [
                            ParameterIdentifier("vr28"),
                            ParameterIdentifier("vr14"),
                        ]
                    ),
                    InstructionNode(instruction: kLEAVE),
                    InstructionNode(instruction: kRET),
                ]
            ),
        ])
        let expected = TopLevel(children: [
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(16),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("r0"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(18),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterNumber(3),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                    ParameterNumber(2),
                ]
            ),
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSUBI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(3),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r4"),
                    ParameterIdentifier("r3"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("r1"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r3"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r4"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r4"),
                    ParameterIdentifier("r4"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("r3"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r3"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r4"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r4"),
                    ParameterIdentifier("r4"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("r3"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r3"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterIdentifier("r4"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r4"),
                    ParameterIdentifier("r4"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("r3"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kCALL,
                parameters: [
                    ParameterIdentifier("sum")
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(17),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("r2"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r3"),
                    ParameterIdentifier("r1"),
                    ParameterNumber(0),
                ]
            ),
            InstructionNode(
                instruction: kADDI,
                parameters: [
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("sp"),
                    ParameterNumber(4),
                ]
            ),
            InstructionNode(
                instruction: kLI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(17),
                ]
            ),
            InstructionNode(
                instruction: kLUI,
                parameters: [
                    ParameterIdentifier("r1"),
                    ParameterNumber(1),
                ]
            ),
            InstructionNode(
                instruction: kLOAD,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r1"),
                ]
            ),
            InstructionNode(
                instruction: kSTORE,
                parameters: [
                    ParameterIdentifier("r2"),
                    ParameterIdentifier("r0"),
                ]
            ),
            Subroutine(
                identifier: "sum",
                children: [
                    InstructionNode(
                        instruction: kENTER,
                        parameters: [
                            ParameterNumber(2)
                        ]
                    ),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("r4"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(10),
                        ]
                    ),
                    InstructionNode(
                        instruction: kSTORE,
                        parameters: [
                            ParameterIdentifier("r4"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(-1),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("r0"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(7),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLI,
                        parameters: [
                            ParameterIdentifier("r1"),
                            ParameterNumber(2),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("r2"),
                            ParameterIdentifier("r1"),
                            ParameterIdentifier("r0"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("r4"),
                            ParameterIdentifier("r2"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kSTORE,
                        parameters: [
                            ParameterIdentifier("r4"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(-2),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("r0"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(7),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLI,
                        parameters: [
                            ParameterIdentifier("r1"),
                            ParameterNumber(1),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("r2"),
                            ParameterIdentifier("r1"),
                            ParameterIdentifier("r0"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("r0"),
                            ParameterIdentifier("r2"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADDI,
                        parameters: [
                            ParameterIdentifier("r1"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(7),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLI,
                        parameters: [
                            ParameterIdentifier("r2"),
                            ParameterNumber(0),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("r3"),
                            ParameterIdentifier("r2"),
                            ParameterIdentifier("r1"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("r1"),
                            ParameterIdentifier("r3"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("r2"),
                            ParameterIdentifier("r1"),
                            ParameterIdentifier("r0"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("r4"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(-2),
                        ]
                    ),
                    InstructionNode(
                        instruction: kADD,
                        parameters: [
                            ParameterIdentifier("r0"),
                            ParameterIdentifier("r2"),
                            ParameterIdentifier("r4"),
                        ]
                    ),
                    InstructionNode(
                        instruction: kLOAD,
                        parameters: [
                            ParameterIdentifier("r4"),
                            ParameterIdentifier("fp"),
                            ParameterNumber(-1),
                        ]
                    ),
                    InstructionNode(
                        instruction: kSTORE,
                        parameters: [
                            ParameterIdentifier("r0"),
                            ParameterIdentifier("r4"),
                        ]
                    ),
                    InstructionNode(instruction: kLEAVE),
                    InstructionNode(instruction: kRET),
                ]
            ),
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
}
