//
//  TackToTurtle16CompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 9/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleCore
import Turtle16SimulatorCore

class PrintLogger: NSObject, Logger {
    public func append(_ format: String, _ args: CVarArg...) {
        let message = String(format:format, arguments:args)
        print(message)
    }
}

class TackToTurtle16CompilerTests: XCTestCase {
    fileprivate func makeDebugger(assembly: AbstractSyntaxTreeNode?) -> DebugConsole {
        let topLevel0 = TopLevel(children: [
            InstructionNode(instruction: kNOP),
            assembly!,
            InstructionNode(instruction: kHLT)
        ])
        let topLevel1 = try! SnapASTTransformerFlattenSeq().compile(topLevel0)! as! TopLevel
        let assembler = AssemblerCompiler()
        assembler.compile(topLevel1)
        if assembler.hasError {
            XCTFail()
        }
        let cpu = SchematicLevelCPUModel()
        let computer = Turtle16Computer(cpu)
        computer.instructions = assembler.instructions
        computer.reset()
        let debugger = DebugConsole(computer: computer)
        return debugger
    }
    
    func compile(_ input: AbstractSyntaxTreeNode) throws -> AbstractSyntaxTreeNode? {
        let compiler = TackToTurtle16Compiler()
        let registerAllocator = RegisterAllocatorNaive()
        let stage0 = try compiler.compile(input)
        let stage1 = try registerAllocator.compile(stage0)
        return stage1
    }
    
    func testCompileEmptyProgram() throws {
        let compiler = TackToTurtle16Compiler()
        let input = Seq(children: [])
        let expected = Seq(children: [])
        let actual = try compiler.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCompileUnknownInstruction() throws {
        let compiler = TackToTurtle16Compiler()
        let input = InstructionNode(instruction: "")
        let expected = InstructionNode(instruction: "")
        let actual = try compiler.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD16() throws {
        let input = InstructionNode(instruction: Tack.kADD16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD16_sp_and_fp_and_ra() throws {
        let input = InstructionNode(instruction: Tack.kADD16, parameters:[
            ParameterIdentifier("sp"),
            ParameterIdentifier("fp"),
            ParameterIdentifier("ra")
        ])
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("sp"),
            ParameterIdentifier("fp"),
            ParameterIdentifier("ra")
        ])
        let compiler = TackToTurtle16Compiler()
        let actual = try compiler.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSUB16() throws {
        let input = InstructionNode(instruction: Tack.kSUB16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kSUB, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNEG16() throws {
        let input = InstructionNode(instruction: Tack.kNEG16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kNOT, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testXOR16() throws {
        let input = InstructionNode(instruction: Tack.kXOR16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kXOR, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testOR16() throws {
        let input = InstructionNode(instruction: Tack.kOR16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kOR, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testAND16() throws {
        let input = InstructionNode(instruction: Tack.kAND16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kAND, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testJMP() throws {
        let input = InstructionNode(instruction: Tack.kJMP, parameters:[
            ParameterIdentifier("foo")
        ])
        let expected = InstructionNode(instruction: kJMP, parameters:[
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testRET() throws {
        let input = InstructionNode(instruction: Tack.kRET)
        let expected = InstructionNode(instruction: kRET)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testENTER() throws {
        let input = InstructionNode(instruction: Tack.kENTER)
        let expected = InstructionNode(instruction: kENTER)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLEAVE() throws {
        let input = InstructionNode(instruction: Tack.kLEAVE)
        let expected = InstructionNode(instruction: kLEAVE)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNOT() throws {
        let input = InstructionNode(instruction: Tack.kNOT, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kNOT, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kANDI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ])
        ])
        let compiler = TackToTurtle16Compiler()
        let actual = try compiler.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNOT_subsequent_use_of_registers_map_correctly() throws {
        let input = Seq(children: [
            InstructionNode(instruction: Tack.kNOT, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: Tack.kCALLPTR, parameters:[
                ParameterIdentifier("vr1")
            ])
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kNOT, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kANDI, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterNumber(1)
            ]),
            InstructionNode(instruction: kCALLPTR, parameters:[
                ParameterIdentifier("vr2")
            ])
        ])
        let compiler = TackToTurtle16Compiler()
        let actual = try compiler.compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLA() throws {
        let input = InstructionNode(instruction: Tack.kLA, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("foo")
        ])
        let expected = InstructionNode(instruction: kLA, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCALL() throws {
        let input = InstructionNode(instruction: Tack.kCALL, parameters:[
            ParameterIdentifier("foo")
        ])
        let expected = InstructionNode(instruction: kCALL, parameters:[
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCALLPTR() throws {
        let input = InstructionNode(instruction: Tack.kCALLPTR, parameters:[
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kCALLPTR, parameters:[
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testBZ() throws {
        let input = InstructionNode(instruction: Tack.kBZ, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("foo")
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kCMPI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kBEQ, parameters:[
                ParameterIdentifier("foo")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testBNZ() throws {
        let input = InstructionNode(instruction: Tack.kBNZ, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("foo")
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kCMPI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kBNE, parameters:[
                ParameterIdentifier("foo")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLOAD_small_offset_pos() throws {
        let input = InstructionNode(instruction: Tack.kLOAD, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(15)
        ])
        let expected = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLOAD_small_offset_neg() throws {
        let input = InstructionNode(instruction: Tack.kLOAD, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-16)
        ])
        let expected = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLOAD_large_offset_pos() throws {
        let input = InstructionNode(instruction: Tack.kLOAD, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(16)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(16)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("vr3"),
                ParameterIdentifier("vr2")
            ])
        ])
        let actual = try TackToTurtle16Compiler().compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLOAD_large_offset_neg() throws {
        let input = InstructionNode(instruction: Tack.kLOAD, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-17)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(Int((UInt16(0) &- 17) & 0x00ff))
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(Int(((UInt16(0) &- 17) & 0xff00) >> 8))
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kLOAD, parameters:[
                ParameterIdentifier("vr3"),
                ParameterIdentifier("vr2")
            ])
        ])
        let actual = try TackToTurtle16Compiler().compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSTORE_small_offset_pos() throws {
        let input = InstructionNode(instruction: Tack.kSTORE, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(15)
        ])
        let expected = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSTORE_small_offset_neg() throws {
        let input = InstructionNode(instruction: Tack.kSTORE, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-16)
        ])
        let expected = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSTORE_large_offset_pos() throws {
        let input = InstructionNode(instruction: Tack.kSTORE, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(16)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(16)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kSTORE, parameters:[
                ParameterIdentifier("vr3"),
                ParameterIdentifier("vr2")
            ])
        ])
        let actual = try TackToTurtle16Compiler().compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSTORE_large_offset_neg() throws {
        let input = InstructionNode(instruction: Tack.kSTORE, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-17)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(Int((UInt16(0) &- 17) & 0x00ff))
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("vr1"),
                ParameterNumber(Int(((UInt16(0) &- 17) & 0xff00) >> 8))
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("vr2"),
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            InstructionNode(instruction: kSTORE, parameters:[
                ParameterIdentifier("vr3"),
                ParameterIdentifier("vr2")
            ])
        ])
        let actual = try TackToTurtle16Compiler().compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADDI16_small_imm_pos() throws {
        let input = InstructionNode(instruction: Tack.kADDI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(15)
        ])
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADDI16_small_imm_neg() throws {
        let input = InstructionNode(instruction: Tack.kADDI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-16)
        ])
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADDI16_large_imm_pos() throws {
        let input = InstructionNode(instruction: Tack.kADDI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(16)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("r1"),
                ParameterNumber(16)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r1"),
                ParameterNumber(0)
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r1")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADDI16_large_imm_neg() throws {
        let input = InstructionNode(instruction: Tack.kADDI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-17)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("r1"),
                ParameterNumber(Int((UInt16(0) &- 17) & 0x00ff))
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r1"),
                ParameterNumber(Int(((UInt16(0) &- 17) & 0xff00) >> 8))
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r1")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testSUBI16() throws {
        let input = InstructionNode(instruction: Tack.kSUBI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(15)
        ])
        let expected = InstructionNode(instruction: kSUBI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testANDI16() throws {
        let input = InstructionNode(instruction: Tack.kANDI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(15)
        ])
        let expected = InstructionNode(instruction: kANDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_zero() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(0)
        ])
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_one() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(1)
        ])
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(0)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_two() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(2)
        ])
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_three() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(3)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_four() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(4)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_five() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(5)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_six() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(6)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r3"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r2")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_seven() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(7)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r3"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r2")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r3"),
                ParameterIdentifier("r3"),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_pos_eight() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(8)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_neg_one() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-1)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kNOT, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADDI, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1"),
                ParameterNumber(1)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_neg_two() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(-2)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kNOT, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kADDI, parameters:[
                ParameterIdentifier("r3"),
                ParameterIdentifier("r2"),
                ParameterNumber(1)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMULI16_three_element_sum() throws {
        let input = InstructionNode(instruction: Tack.kMULI16, parameters:[
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0"),
            ParameterNumber(14)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r1")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r2"),
                ParameterIdentifier("r2"),
                ParameterIdentifier("r2")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r3"),
                ParameterIdentifier("r0"),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r4"),
                ParameterIdentifier("r1"),
                ParameterIdentifier("r2")
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier("r4"),
                ParameterIdentifier("r4"),
                ParameterIdentifier("r3")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLI16_small_pos() throws {
        let input = InstructionNode(instruction: Tack.kLI16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(127)
        ])
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(127)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLI16_small_neg() throws {
        let input = InstructionNode(instruction: Tack.kLI16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(-128)
        ])
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(-128)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLI16_med_pos() throws {
        let input = InstructionNode(instruction: Tack.kLI16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(255)
        ])
        let expected = InstructionNode(instruction: kLIU, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(255)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLI16_large_pos() throws {
        let input = InstructionNode(instruction: Tack.kLI16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(0x7fff)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0xff)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0x7f)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLIU16_small_pos() throws {
        let input = InstructionNode(instruction: Tack.kLIU16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(255)
        ])
        let expected = InstructionNode(instruction: kLIU, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(255)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLIU16_large_pos() throws {
        let input = InstructionNode(instruction: Tack.kLIU16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(0x8000)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kLIU, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0x00)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0x80)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testMUL16_0_x_0() throws {
        let input = InstructionNode(instruction: Tack.kMUL16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let computer = makeDebugger(assembly: try compile(input)).computer
        computer.setRegister(0, 0)
        computer.setRegister(1, 0)
        computer.setRegister(3, 42)
        computer.run()
        XCTAssertEqual(computer.getRegister(3), 0)
    }
    
    func testMUL16_1_x_1() throws {
        let input = InstructionNode(instruction: Tack.kMUL16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(3, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 1)
    }
    
    func testMUL16_2_x_2() throws {
        let input = InstructionNode(instruction: Tack.kMUL16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 2)
        debugger.computer.setRegister(1, 2)
        debugger.computer.setRegister(3, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 4)
    }
    
    func testDIV16_0_div_0() throws {
        let input = InstructionNode(instruction: Tack.kDIV16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0)
        debugger.computer.setRegister(2, 100)
        debugger.computer.setRegister(3, 100)
        debugger.computer.run()
//        while !debugger.computer.isHalted {
//            print("---")
//            debugger.computer.step()
//            debugger.interpreter.runOne(instruction: .disassemble(.baseCount(debugger.computer.cpu.getPipelineStageInfo(2).pc ?? 0, 1)))
//            debugger.interpreter.runOne(instruction: .reg)
//        }
        XCTAssertEqual(debugger.computer.getRegister(3), 0)
    }
    
    func testDIV16_1_div_1() throws {
        let input = InstructionNode(instruction: Tack.kDIV16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(2, 100)
        debugger.computer.setRegister(3, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 1)
    }
    
    func testDIV16_12_div_4() throws {
        let input = InstructionNode(instruction: Tack.kDIV16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 4)
        debugger.computer.setRegister(1, 12)
        debugger.computer.setRegister(2, 100)
        debugger.computer.setRegister(3, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 3)
    }
    
    func testDIV16_0_mod_0() throws {
        let input = InstructionNode(instruction: Tack.kMOD16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0)
        debugger.computer.setRegister(2, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }
    
    func testDIV16_3_mod_2() throws {
        let input = InstructionNode(instruction: Tack.kMOD16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 2)
        debugger.computer.setRegister(1, 3)
        debugger.computer.setRegister(2, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }
}
