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
            InstructionNode(instruction: kNOP),
            InstructionNode(instruction: kHLT)
        ])
        let topLevel1 = try! SnapASTTransformerFlattenSeq().compile(topLevel0)! as! TopLevel
        let assembler = AssemblerCompiler()
        assembler.compile(topLevel1)
        if assembler.hasError {
            XCTFail()
        }
        let cpu = SchematicLevelCPUModel()
        var ram = Array<UInt16>(repeating: 0, count: 65536)
        cpu.store = {(value: UInt16, addr: UInt16) in
            ram[Int(addr)] = value
        }
        cpu.load = {(addr: UInt16) in
            return ram[Int(addr)]
        }
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
        let input = TackInstructionNode(instruction: .add16, parameters:[
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
        let input = TackInstructionNode(instruction: .add16, parameters:[
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
        let input = TackInstructionNode(instruction: .sub16, parameters:[
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
        let input = TackInstructionNode(instruction: .neg16, parameters:[
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
        let input = TackInstructionNode(instruction: .xor16, parameters:[
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
        let input = TackInstructionNode(instruction: .or16, parameters:[
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
        let input = TackInstructionNode(instruction: .and16, parameters:[
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
        let input = TackInstructionNode(instruction: .jmp, parameters:[
            ParameterIdentifier("foo")
        ])
        let expected = InstructionNode(instruction: kJMP, parameters:[
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testRET() throws {
        let input = TackInstructionNode(instruction: .ret)
        let expected = InstructionNode(instruction: kRET)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testENTER() throws {
        let input = TackInstructionNode(instruction: .enter)
        let expected = InstructionNode(instruction: kENTER)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLEAVE() throws {
        let input = TackInstructionNode(instruction: .leave)
        let expected = InstructionNode(instruction: kLEAVE)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNOT() throws {
        let input = TackInstructionNode(instruction: .not, parameters:[
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
            TackInstructionNode(instruction: .not, parameters:[
                ParameterIdentifier("vr1"),
                ParameterIdentifier("vr0")
            ]),
            TackInstructionNode(instruction: .callptr, parameters:[
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
        let input = TackInstructionNode(instruction: .la, parameters:[
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
        let input = TackInstructionNode(instruction: .call, parameters:[
            ParameterIdentifier("foo")
        ])
        let expected = InstructionNode(instruction: kCALL, parameters:[
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCALLPTR() throws {
        let input = TackInstructionNode(instruction: .callptr, parameters:[
            ParameterIdentifier("vr0")
        ])
        let expected = InstructionNode(instruction: kCALLPTR, parameters:[
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testBZ() throws {
        let input = TackInstructionNode(instruction: .bz, parameters:[
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
        let input = TackInstructionNode(instruction: .bnz, parameters:[
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
        let input = TackInstructionNode(instruction: .load, parameters:[
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
        let input = TackInstructionNode(instruction: .load, parameters:[
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
        let input = TackInstructionNode(instruction: .load, parameters:[
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
        let input = TackInstructionNode(instruction: .load, parameters:[
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
        let input = TackInstructionNode(instruction: .store, parameters:[
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
        let input = TackInstructionNode(instruction: .store, parameters:[
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
        let input = TackInstructionNode(instruction: .store, parameters:[
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
        let input = TackInstructionNode(instruction: .store, parameters:[
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
    
    func testSTSTR() throws {
        let input = TackInstructionNode(instruction: .ststr, parameters:[
            ParameterIdentifier("vr0"),
            ParameterString("ABC")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0x1000)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.cpu.load(0x1000), 65)
        XCTAssertEqual(debugger.computer.cpu.load(0x1001), 66)
        XCTAssertEqual(debugger.computer.cpu.load(0x1002), 67)
    }
    
    func testSTSTR_empty_string() throws {
        let input = TackInstructionNode(instruction: .ststr, parameters:[
            ParameterIdentifier("vr0"),
            ParameterString("")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, Seq())
    }
    
    func testMEMCPY_zero_words() throws {
        let input = TackInstructionNode(instruction: .memcpy, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterNumber(0)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, Seq())
    }
    
    func testMEMCPY_one_word() throws {
        let input = TackInstructionNode(instruction: .memcpy, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterNumber(1)
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0x1000)
        debugger.computer.setRegister(1, 0x2000)
        debugger.computer.cpu.store(65, 0x2000)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.cpu.load(0x1000), 65)
    }
    
    func testMEMCPY_multiple_words() throws {
        let input = TackInstructionNode(instruction: .memcpy, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterNumber(3)
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0x1000)
        debugger.computer.setRegister(1, 0x2000)
        debugger.computer.cpu.store(65, 0x2000)
        debugger.computer.cpu.store(66, 0x2001)
        debugger.computer.cpu.store(67, 0x2002)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.cpu.load(0x1000), 65)
        XCTAssertEqual(debugger.computer.cpu.load(0x1001), 66)
        XCTAssertEqual(debugger.computer.cpu.load(0x1002), 67)
    }
    
    func testALLOCA() throws {
        let sp = "r6"
        let input = TackInstructionNode(instruction: .alloca, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(2)
        ])
        let expected = Seq(children: [
            InstructionNode(instruction: kSUBI, parameters:[
                ParameterIdentifier(sp),
                ParameterIdentifier(sp),
                ParameterNumber(2)
            ]),
            InstructionNode(instruction: kADDI, parameters:[
                ParameterIdentifier("r0"),
                ParameterIdentifier(sp),
                ParameterNumber(0)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testFREE() throws {
        let sp = "r6"
        let input = TackInstructionNode(instruction: .free, parameters:[
            ParameterNumber(2)
        ])
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier(sp),
            ParameterIdentifier(sp),
            ParameterNumber(2)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADDI16_small_imm_pos() throws {
        let input = TackInstructionNode(instruction: .addi16, parameters:[
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
        let input = TackInstructionNode(instruction: .addi16, parameters:[
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
        let input = TackInstructionNode(instruction: .addi16, parameters:[
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
        let input = TackInstructionNode(instruction: .addi16, parameters:[
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
        let input = TackInstructionNode(instruction: .subi16, parameters:[
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
        let input = TackInstructionNode(instruction: .andi16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .muli16, parameters:[
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
        let input = TackInstructionNode(instruction: .li16, parameters:[
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
        let input = TackInstructionNode(instruction: .li16, parameters:[
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
        let input = TackInstructionNode(instruction: .li16, parameters:[
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
        let input = TackInstructionNode(instruction: .li16, parameters:[
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
        let input = TackInstructionNode(instruction: .liu16, parameters:[
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
        let input = TackInstructionNode(instruction: .liu16, parameters:[
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
        let input = TackInstructionNode(instruction: .mul16, parameters:[
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
        let input = TackInstructionNode(instruction: .mul16, parameters:[
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
        let input = TackInstructionNode(instruction: .mul16, parameters:[
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
        let input = TackInstructionNode(instruction: .div16, parameters:[
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
        let input = TackInstructionNode(instruction: .div16, parameters:[
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
        let input = TackInstructionNode(instruction: .div16, parameters:[
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
    
    func testMOD16_0_mod_0() throws {
        let input = TackInstructionNode(instruction: .mod16, parameters:[
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
    
    func testMOD16_3_mod_2() throws {
        let input = TackInstructionNode(instruction: .mod16, parameters:[
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
    
    func testLSL16_0_shift_0() throws {
        let input = TackInstructionNode(instruction: .lsl16, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0)
        debugger.computer.setRegister(2, 0)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }
    
    func test_left_shift_algorithm() throws {
        let N = 16
        var b = 0
        let a = 2
        let n = 1
        var mask1 = 1
        var mask2 = 1 << n
        var i = 0
        while i < N-n {
            if (a & mask1) != 0 {
                b |= mask2
            }
            mask1 += mask1
            mask2 += mask2
            i += 1
        }
        XCTAssertEqual(b, 4)
    }
    
    func testLSL16_2_shift_1() throws {
        let input = TackInstructionNode(instruction: .lsl16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        let b = 0
        let a = 1
        let n = 2
        let temp = 3
        let mask1 = 4
        let mask2 = 5
        let i = 6
        debugger.computer.setRegister(b, 0)
        debugger.computer.setRegister(a, 2)
        debugger.computer.setRegister(n, 1)
        debugger.computer.setRegister(temp, 0)
        debugger.computer.setRegister(mask2, 0)
        debugger.computer.setRegister(mask1, 0)
        debugger.computer.setRegister(i, 0)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(b), 4)
        XCTAssertEqual(debugger.computer.getRegister(a), 2)
        XCTAssertEqual(debugger.computer.getRegister(n), 1)
    }
    
    func test_right_shift_algorithm() throws {
        let N = 16
        var b = 0
        let a = 2
        let n = 1
        var mask1 = 1
        var mask2 = 1 << n
        var i = 0
        while i < N-n {
            if (a & mask2) != 0 {
                b |= mask1
            }
            mask1 += mask1
            mask2 += mask2
            i += 1
        }
        XCTAssertEqual(b, 1)
    }
    
    func testLSR16_2_shift_1() throws {
        let input = TackInstructionNode(instruction: .lsr16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        let b = 0
        let a = 1
        let n = 2
        let temp = 3
        let mask1 = 4
        let mask2 = 5
        let i = 6
        debugger.computer.setRegister(b, 0)
        debugger.computer.setRegister(a, 2)
        debugger.computer.setRegister(n, 1)
        debugger.computer.setRegister(temp, 0)
        debugger.computer.setRegister(mask2, 0)
        debugger.computer.setRegister(mask1, 0)
        debugger.computer.setRegister(i, 0)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(b), 1)
        XCTAssertEqual(debugger.computer.getRegister(a), 2)
        XCTAssertEqual(debugger.computer.getRegister(n), 1)
    }
    
    func testEQ16_equal() throws {
        let input = TackInstructionNode(instruction: .eq16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testEQ16_not_equal() throws {
        let input = TackInstructionNode(instruction: .eq16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testNE16_equal() throws {
        let input = TackInstructionNode(instruction: .ne16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testNE16_not_equal() throws {
        let input = TackInstructionNode(instruction: .ne16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testLT16_less_than() throws {
        let input = TackInstructionNode(instruction: .lt16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testLT16_equal() throws {
        let input = TackInstructionNode(instruction: .lt16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testLT16_greater_than() throws {
        let input = TackInstructionNode(instruction: .lt16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testGE16_less_than() throws {
        let input = TackInstructionNode(instruction: .ge16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testGE16_equal() throws {
        let input = TackInstructionNode(instruction: .ge16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testGE16_greater_than() throws {
        let input = TackInstructionNode(instruction: .ge16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testLE16_less_than() throws {
        let input = TackInstructionNode(instruction: .le16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testLE16_equal() throws {
        let input = TackInstructionNode(instruction: .le16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testLE16_greater_than() throws {
        let input = TackInstructionNode(instruction: .le16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testGT16_less_than() throws {
        let input = TackInstructionNode(instruction: .gt16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testGT16_equal() throws {
        let input = TackInstructionNode(instruction: .gt16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testGT16_greater_than() throws {
        let input = TackInstructionNode(instruction: .gt16, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(2, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    fileprivate func doTestLI8(_ value: Int) throws {
        let input = TackInstructionNode(instruction: .li8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterNumber(value)
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0xdead)
        debugger.computer.run()
        let expected: UInt16
        if value >= 0 {
            expected = UInt16(value)
        } else {
            expected = ~UInt16(-value) + 1
        }
        XCTAssertEqual(debugger.computer.getRegister(0), expected)
    }
    
    func testLI8_zero() throws {
        try doTestLI8(0)
    }
    
    func testLI8_one() throws {
        try doTestLI8(1)
    }
    
    func testLI8_neg_one() throws {
        try doTestLI8(-1)
    }
    
    func testLI8_max() throws {
        try doTestLI8(127)
    }
    
    func testLI8_min() throws {
        try doTestLI8(-128)
    }
    
    func testAND8() throws {
        let input = TackInstructionNode(instruction: .and8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0xffff)
        debugger.computer.setRegister(1, 0xff01)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0xffff)
        XCTAssertEqual(debugger.computer.getRegister(1), 0xff01)
        XCTAssertEqual(debugger.computer.getRegister(2), 0x0001)
    }
    
    func testOR8() throws {
        let input = TackInstructionNode(instruction: .or8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0xfffe)
        debugger.computer.setRegister(1, 0xff01)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0xfffe)
        XCTAssertEqual(debugger.computer.getRegister(1), 0xff01)
        XCTAssertEqual(debugger.computer.getRegister(2), 0x00ff)
    }
    
    func testXOR8() throws {
        let input = TackInstructionNode(instruction: .xor8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0xabab)
        debugger.computer.setRegister(1, 0xcdcd)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0xabab)
        XCTAssertEqual(debugger.computer.getRegister(1), 0xcdcd)
        XCTAssertEqual(debugger.computer.getRegister(2), 0x0066)
    }
    
    func testNEG8() throws {
        let input = TackInstructionNode(instruction: .neg8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
        XCTAssertEqual(debugger.computer.getRegister(1), 0x00ff)
    }
    
    func testADD8_positive_result() throws {
        let input = TackInstructionNode(instruction: .add8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1)
        debugger.computer.setRegister(1, 2)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
        XCTAssertEqual(debugger.computer.getRegister(1), 2)
        XCTAssertEqual(debugger.computer.getRegister(2), 3)
    }
    
    func testADD8_negative_result() throws {
        let input = TackInstructionNode(instruction: .add8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, UInt16(0) &- 2)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), UInt16(0) &- 2)
        XCTAssertEqual(debugger.computer.getRegister(1), 1)
        XCTAssertEqual(debugger.computer.getRegister(2), UInt16(0) &- 1)
    }
    
    func testSUB8_positive_result() throws {
        let input = TackInstructionNode(instruction: .sub8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.setRegister(1, 2)
        debugger.computer.setRegister(0, 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
        XCTAssertEqual(debugger.computer.getRegister(1), 2)
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testSUB8_negative_result() throws {
        let input = TackInstructionNode(instruction: .sub8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(0, 2)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), UInt16(0) &- 1)
        XCTAssertEqual(debugger.computer.getRegister(1), 1)
        XCTAssertEqual(debugger.computer.getRegister(0), 2)
    }
    
    func testMUL8() throws {
        let input = TackInstructionNode(instruction: .mul8, parameters:[
            ParameterIdentifier("vr2"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr0")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 2)
        debugger.computer.setRegister(1, 2)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 2)
        XCTAssertEqual(debugger.computer.getRegister(1), 2)
        XCTAssertEqual(debugger.computer.getRegister(3), 4)
    }
    
    func testDIV8() throws {
        let input = TackInstructionNode(instruction: .div8, parameters:[
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
    
    func testMOD8() throws {
        let input = TackInstructionNode(instruction: .mod8, parameters:[
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
    
    func testLSL8_2_shift_1() throws {
        let input = TackInstructionNode(instruction: .lsl8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        let b = 0
        let a = 1
        let n = 2
        let temp = 3
        let mask1 = 4
        let mask2 = 5
        let i = 6
        debugger.computer.setRegister(b, 0)
        debugger.computer.setRegister(a, 2)
        debugger.computer.setRegister(n, 1)
        debugger.computer.setRegister(temp, 0)
        debugger.computer.setRegister(mask2, 0)
        debugger.computer.setRegister(mask1, 0)
        debugger.computer.setRegister(i, 0)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(b), 4)
        XCTAssertEqual(debugger.computer.getRegister(a), 2)
        XCTAssertEqual(debugger.computer.getRegister(n), 1)
    }
    
    func testLSR8_2_shift_1() throws {
        let input = TackInstructionNode(instruction: .lsr8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        let b = 0
        let a = 1
        let n = 2
        let temp = 3
        let mask1 = 4
        let mask2 = 5
        let i = 6
        debugger.computer.setRegister(b, 0)
        debugger.computer.setRegister(a, 2)
        debugger.computer.setRegister(n, 1)
        debugger.computer.setRegister(temp, 0)
        debugger.computer.setRegister(mask2, 0)
        debugger.computer.setRegister(mask1, 0)
        debugger.computer.setRegister(i, 0)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(b), 1)
        XCTAssertEqual(debugger.computer.getRegister(a), 2)
        XCTAssertEqual(debugger.computer.getRegister(n), 1)
    }
    
    func testEQ8_equal() throws {
        let input = TackInstructionNode(instruction: .eq8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0xab42)
        debugger.computer.setRegister(2, 0xcd42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
    
    func testEQ8_not_equal() throws {
        let input = TackInstructionNode(instruction: .eq8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0xab42)
        debugger.computer.setRegister(2, 0xcd43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testNE8_equal() throws {
        let input = TackInstructionNode(instruction: .ne8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0xab42)
        debugger.computer.setRegister(2, 0xcd42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 0)
    }
    
    func testNE8_not_equal() throws {
        let input = TackInstructionNode(instruction: .ne8, parameters:[
            ParameterIdentifier("vr0"),
            ParameterIdentifier("vr1"),
            ParameterIdentifier("vr2")
        ])
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0xab42)
        debugger.computer.setRegister(2, 0xcd43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(0), 1)
    }
}