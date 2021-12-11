//
//  RegisterAllocatorDriverTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/23/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import Turtle16SimulatorCore
import TurtleCore

class RegisterAllocatorDriverTests: XCTestCase {
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
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD_0() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD_1() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr4"),
                ParameterIdentifier("vr3"),
                ParameterIdentifier("ra")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("ra")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD_2() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("sp"),
                ParameterIdentifier("fp"),
                ParameterIdentifier("vr3")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("sp"),
                ParameterIdentifier("fp"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSUB() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kSUB, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kSUB, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testAND() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kAND, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kAND, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testOR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kOR, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kOR, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testXOR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kXOR, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kXOR, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNOT() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kNOT, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kNOT, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCMPI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kCMPI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kCMPI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADDI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kADDI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kADDI, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSUBI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kSUBI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kSUBI, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testANDI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kANDI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kANDI, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testORI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kORI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kORI, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testXORI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kXORI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kXORI, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADC() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kADC, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kADC, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSBC() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kSBC, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kSBC, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(1)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLIU() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(1)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLUI() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(1)
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testJR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kJR, parameters:[
                ParameterIdentifier("vr1")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kJR, parameters:[
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCALLPTR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kCALLPTR, parameters:[
                ParameterIdentifier("vr1")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kCALLPTR, parameters:[
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testJALR() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kJALR, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kJALR, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLOAD() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSTORE() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kSTORE, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kSTORE, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLA() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            InstructionNode(instruction: kLA, parameters: [
                ParameterIdentifier("vr0"),
                ParameterIdentifier("foo"),
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kLA, parameters: [
                ParameterIdentifier("r0"),
                ParameterIdentifier("foo"),
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSubroutine() throws {
        let driver = RegisterAllocatorDriver()
        let input = TopLevel(children: [
            Subroutine(children: [
                LabelDeclaration(identifier: ""),
                InstructionNode(instruction: kADD, parameters:[
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("vr3")
                ])
            ])
        ])
        let expected = TopLevel(children: [
            Subroutine(children: [
                LabelDeclaration(identifier: ""),
                InstructionNode(instruction: kADD, parameters:[
                    ParameterIdentifier("sp"),
                    ParameterIdentifier("fp"),
                    ParameterIdentifier("r0")
                ])
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testRunViaTheCompileChildrenEntryPoint() throws {
        let driver = RegisterAllocatorDriver()
        let input: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("sp"),
                ParameterIdentifier("fp"),
                ParameterIdentifier("vr3")
            ])
        ]
        let expected: [AbstractSyntaxTreeNode] = [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("sp"),
                ParameterIdentifier("fp"),
                ParameterIdentifier("r0")
            ])
        ]
        let actual = try driver.compile(children: input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSpillFails_InsufficientRegisters() throws {
        let driver = RegisterAllocatorDriver(numRegisters: 0)
        let input = TopLevel(children: [
            InstructionNode(instruction: kENTER),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr0"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterNumber(2)
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr0")
            ])
        ])
        XCTAssertThrowsError(try driver.compile(topLevel: input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Register allocation failed: insufficient physical registers")
        }
    }
    
    func testSpillFails_MissingLeadingEnter() throws {
        let driver = RegisterAllocatorDriver(numRegisters: 2)
        let input = TopLevel(children: [
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr0"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterNumber(2)
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr0")
            ])
        ])
        XCTAssertThrowsError(try driver.compile(topLevel: input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "Register allocation failed: missing leading enter")
        }
    }
    
    func testSpill() throws {
        let driver = RegisterAllocatorDriver(numRegisters: 2)
        let input = TopLevel(children: [
            InstructionNode(instruction: kENTER),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr0"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterNumber(2)
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr0")
            ])
        ])
        let expected = TopLevel(children: [
            InstructionNode(instruction: kENTER, parameter: ParameterNumber(3)),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r1"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kSTORE, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("fp"),
                ParameterNumber(8)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r1"),
                ParameterNumber(1)
            ]),
            InstructionNode(instruction: kSTORE, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("fp"),
                ParameterNumber(9)
            ]),
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r1"),
                ParameterNumber(2)
            ]),
            InstructionNode(instruction: kSTORE, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("fp"),
                ParameterNumber(10)
            ]),
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("fp"),
                ParameterNumber(8)
            ]),
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("r0"),
                ParameterIdentifier("fp"),
                ParameterNumber(9)
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("r0"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("fp"),
                ParameterNumber(8)
            ]),
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("r0"),
                ParameterIdentifier("fp"),
                ParameterNumber(10)
            ]),
            InstructionNode(instruction: kCMP, parameters:[
                ParameterIdentifier("r0"),
                ParameterIdentifier("r1")
            ])
        ])
        let actual = try driver.compile(topLevel: input)
        XCTAssertEqual(actual, expected)
    }
}
