//
//  RegisterAllocatorNaiveTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/23/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import Turtle16SimulatorCore
import TurtleCore

class RegisterAllocatorNaiveTests: XCTestCase {
    func testCMP() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kCMP, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kCMP, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD_0() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD_1() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("vr4"),
            ParameterIdentifier("vr3"),
            ParameterIdentifier("ra")
        ])
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("r4"),
            ParameterIdentifier("r3"),
            ParameterIdentifier("r5")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD_2() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("sp"),
            ParameterIdentifier("fp"),
            ParameterIdentifier("vr3")
        ])
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("r6"),
            ParameterIdentifier("r7"),
            ParameterIdentifier("r3")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD_cant_map_virtual_register() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("foo"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        XCTAssertThrowsError(try registerAllocator.compile(input)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "unable to map virtual register to physical register: `foo'")
        }
    }
    
    func testSUB() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kSUB, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kSUB, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testAND() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kAND, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kAND, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testOR() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kOR, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kOR, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testXOR() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kXOR, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kXOR, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNOT() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kNOT, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kNOT, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCMPI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kCMPI, parameters:[
            ParameterIdentifier("vr1"),
            ParameterNumber(0)
        ])
        let expected = InstructionNode(instruction: kCMPI, parameters:[
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADDI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterNumber(0)
        ])
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSUBI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kSUBI, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterNumber(0)
        ])
        let expected = InstructionNode(instruction: kSUBI, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testANDI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kANDI, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterNumber(0)
        ])
        let expected = InstructionNode(instruction: kANDI, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testORI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kORI, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterNumber(0)
        ])
        let expected = InstructionNode(instruction: kORI, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testXORI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kXORI, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterNumber(0)
        ])
        let expected = InstructionNode(instruction: kXORI, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADC() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kADC, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kADC, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSBC() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kSBC, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kSBC, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("vr1"),
            ParameterNumber(1)
        ])
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r1"),
            ParameterNumber(1)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLUI() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kLUI, parameters:[
            ParameterIdentifier("vr1"),
            ParameterNumber(1)
        ])
        let expected = InstructionNode(instruction: kLUI, parameters:[
            ParameterIdentifier("r1"),
            ParameterNumber(1)
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testJR() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kJR, parameters:[
            ParameterIdentifier("vr1")
        ])
        let expected = InstructionNode(instruction: kJR, parameters:[
            ParameterIdentifier("r1")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCALLPTR() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kCALLPTR, parameters:[
            ParameterIdentifier("vr1")
        ])
        let expected = InstructionNode(instruction: kCALLPTR, parameters:[
            ParameterIdentifier("r1")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testJALR() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kJALR, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1")
        ])
        let expected = InstructionNode(instruction: kJALR, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLOAD() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1")
        ])
        let expected = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSTORE() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1")
        ])
        let expected = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1")
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLA() throws {
        let registerAllocator = RegisterAllocatorNaive()
        let input =  InstructionNode(instruction: kLA, parameters: [
            ParameterIdentifier("vr0"),
            ParameterIdentifier("foo"),
        ])
        let expected =  InstructionNode(instruction: kLA, parameters: [
            ParameterIdentifier("r0"),
            ParameterIdentifier("foo"),
        ])
        let actual = try registerAllocator.compile(input)
        XCTAssertEqual(actual, expected)
    }
}
