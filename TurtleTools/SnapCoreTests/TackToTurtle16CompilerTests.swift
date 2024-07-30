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
import TurtleSimulatorCore

class TackToTurtle16CompilerTests: XCTestCase {
    fileprivate func makeDebugger(assembly: AbstractSyntaxTreeNode?) -> DebugConsole {
        let topLevel0 = TopLevel(children: [
            InstructionNode(instruction: kNOP),
            assembly!,
            InstructionNode(instruction: kNOP),
            InstructionNode(instruction: kHLT)
        ])
        let topLevel1 = try! SnapASTTransformerFlattenSeq().visit(topLevel0)! as! TopLevel
        let assembler = AssemblerCompiler()
        assembler.compile(topLevel1)
        if assembler.hasError {
            XCTFail()
        }
        let cpu = SchematicLevelCPUModel()
        var ram = Array<UInt16>(repeating: 0, count: 65536)
        cpu.store = {(value: UInt16, addr: MemoryAddress) in
            ram[addr.value] = value
        }
        cpu.load = {(addr: MemoryAddress) in
            return ram[addr.value]
        }
        let computer = TurtleComputer(cpu)
        computer.instructions = assembler.instructions
        computer.reset()
        let debugger = DebugConsole(computer: computer)
        return debugger
    }
    
    func compile(_ input: AbstractSyntaxTreeNode) throws -> AbstractSyntaxTreeNode? {
        let compiler = TackToTurtle16Compiler()
        let registerAllocator = RegisterAllocatorNaive()
        let stage0 = try compiler.visit(input)
        let stage1 = try registerAllocator.visit(stage0)
        return stage1
    }
    
    func testCompileEmptyProgram() throws {
        let compiler = TackToTurtle16Compiler()
        let input = Seq(children: [])
        let expected = Seq(children: [])
        let actual = try compiler.visit(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testCompileUnknownInstruction() throws {
        let compiler = TackToTurtle16Compiler()
        let input = InstructionNode(instruction: "")
        let expected = InstructionNode(instruction: "")
        let actual = try compiler.visit(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testNOP() throws {
        let input = TackInstructionNode(.nop)
        let expected = InstructionNode(instruction: kNOP)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testADD16() throws {
        let input = TackInstructionNode(.addw(.w(2), .w(1), .w(0)))
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testSUB16() throws {
        let input = TackInstructionNode(.subw(.w(2), .w(1), .w(0)))
        let expected = InstructionNode(instruction: kSUB, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testNEG16() throws {
        let input = TackInstructionNode(.negw(.w(1), .w(0)))
        let expected = InstructionNode(instruction: kNOT, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testXOR16() throws {
        let input = TackInstructionNode(.xorw(.w(2), .w(1), .w(0)))
        let expected = InstructionNode(instruction: kXOR, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testOR16() throws {
        let input = TackInstructionNode(.orw(.w(2), .w(1), .w(0)))
        let expected = InstructionNode(instruction: kOR, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testAND16() throws {
        let input = TackInstructionNode(.andw(.w(2), .w(1), .w(0)))
        let expected = InstructionNode(instruction: kAND, parameters:[
            ParameterIdentifier("r2"),
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testJMP() throws {
        let input = TackInstructionNode(.jmp("foo"))
        let expected = InstructionNode(instruction: kJMP, parameters:[
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testRET() throws {
        let input = TackInstructionNode(.ret)
        let expected = InstructionNode(instruction: kRET)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testENTER() throws {
        let input = TackInstructionNode(.enter(0))
        let expected = InstructionNode(instruction: kENTER, parameter: ParameterNumber(0))
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLEAVE() throws {
        let input = TackInstructionNode(.leave)
        let expected = InstructionNode(instruction: kLEAVE)
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testNOT() throws {
        let input = TackInstructionNode(.not(.o(1), .o(0)))
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
        let actual = try compiler.visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testLA() throws {
        let input = TackInstructionNode(.la(.p(1), "foo"))
        let expected = InstructionNode(instruction: kLA, parameters:[
            ParameterIdentifier("r0"),
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testCALL() throws {
        let input = TackInstructionNode(.call("foo"))
        let expected = InstructionNode(instruction: kCALL, parameters:[
            ParameterIdentifier("foo")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testCALLPTR() throws {
        let input = TackInstructionNode(.callptr(.p(0)))
        let expected = InstructionNode(instruction: kCALLPTR, parameters:[
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testBZ() throws {
        let input = TackInstructionNode(.bz(.o(0), "foo"))
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
        let input = TackInstructionNode(.bnz(.o(0), "foo"))
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
    
    func testLOAD16_small_offset_pos() throws {
        let input = TackInstructionNode(.lw(.w(1), .p(0), 15))
        let expected = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD16_small_offset_neg() throws {
        let input = TackInstructionNode(.lw(.w(1), .p(0), -16))
        let expected = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD16_large_offset_pos() throws {
        let input = TackInstructionNode(.lw(.w(1), .p(0), 16))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD16_large_offset_neg() throws {
        let input = TackInstructionNode(.lw(.w(1), .p(0), -17))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE16_small_offset_pos() throws {
        let input = TackInstructionNode(.sw(.w(1), .p(0), 15))
        let expected = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE16_small_offset_neg() throws {
        let input = TackInstructionNode(.sw(.w(1), .p(0), -16))
        let expected = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE16_large_offset_pos() throws {
        let input = TackInstructionNode(.sw(.w(1), .p(0), 16))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE16_large_offset_neg() throws {
        let input = TackInstructionNode(.sw(.w(1), .p(0), -17))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD8_small_offset_pos() throws {
        let input = TackInstructionNode(.lb(.b(1), .p(0), 15))
        let expected = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD8_small_offset_neg() throws {
        let input = TackInstructionNode(.lb(.b(1), .p(0), -16))
        let expected = InstructionNode(instruction: kLOAD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD8_large_offset_pos() throws {
        let input = TackInstructionNode(.lb(.b(1), .p(0), 16))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testLOAD8_large_offset_neg() throws {
        let input = TackInstructionNode(.lb(.b(1), .p(0), -17))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE8_small_offset_pos() throws {
        let input = TackInstructionNode(.sb(.b(1), .p(0), 15))
        let expected = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE8_small_offset_neg() throws {
        let input = TackInstructionNode(.sb(.b(1), .p(0), -16))
        let expected = InstructionNode(instruction: kSTORE, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE8_large_offset_pos() throws {
        let input = TackInstructionNode(.sb(.b(1), .p(0), 16))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTORE8_large_offset_neg() throws {
        let input = TackInstructionNode(.sb(.b(1), .p(0), -17))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let actual = try TackToTurtle16Compiler().visit(input)
        XCTAssertEqual(actual, expected)
    }

    func testSTSTR() throws {
        let input = TackInstructionNode(.ststr(.p(0), "ABC"))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0x1000)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.cpu.load(MemoryAddress(0x1000)), 65)
        XCTAssertEqual(debugger.computer.cpu.load(MemoryAddress(0x1001)), 66)
        XCTAssertEqual(debugger.computer.cpu.load(MemoryAddress(0x1002)), 67)
    }

    func testSTSTR_empty_string() throws {
        let input = TackInstructionNode(.ststr(.p(0), ""))
        let actual = try compile(input)
        XCTAssertEqual(actual, Seq())
    }

    func testMEMCPY_zero_words() throws {
        let input = TackInstructionNode(.memcpy(.p(1), .p(0), 0))
        let actual = try compile(input)
        XCTAssertEqual(actual, Seq())
    }

    func testMEMCPY_one_word() throws {
        let input = TackInstructionNode(.memcpy(.p(1), .p(0), 1))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0x1000)
        debugger.computer.setRegister(1, 0x2000)
        debugger.computer.cpu.store(65, MemoryAddress(0x2000))
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.cpu.load(MemoryAddress(0x1000)), 65)
    }

    func testMEMCPY_multiple_words() throws {
        let input = TackInstructionNode(.memcpy(.p(1), .p(0), 3))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0x1000)
        debugger.computer.setRegister(1, 0x2000)
        debugger.computer.cpu.store(65, MemoryAddress(0x2000))
        debugger.computer.cpu.store(66, MemoryAddress(0x2001))
        debugger.computer.cpu.store(67, MemoryAddress(0x2002))
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.cpu.load(MemoryAddress(0x1000)), 65)
        XCTAssertEqual(debugger.computer.cpu.load(MemoryAddress(0x1001)), 66)
        XCTAssertEqual(debugger.computer.cpu.load(MemoryAddress(0x1002)), 67)
    }

    func testALLOCA() throws {
        let input = TackInstructionNode(.alloca(.p(0), 2))
        let sp = "r6"
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

    func testALLOCA_large() throws {
        let input = TackInstructionNode(.alloca(.p(0), 0xabcd))
        let sp = "r6"
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0xcd)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0xab)
            ]),
            InstructionNode(instruction: kSUB, parameters:[
                ParameterIdentifier(sp),
                ParameterIdentifier(sp),
                ParameterIdentifier("r0")
            ]),
            InstructionNode(instruction: kADDI, parameters:[
                ParameterIdentifier("r1"),
                ParameterIdentifier(sp),
                ParameterNumber(0)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testFREE() throws {
        let input = TackInstructionNode(.free(2))
        let sp = "r6"
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier(sp),
            ParameterIdentifier(sp),
            ParameterNumber(2)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testFREE_large() throws {
        let sp = "r6"
        let input = TackInstructionNode(.free(0xabcd))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0xcd)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0xab)
            ]),
            InstructionNode(instruction: kADD, parameters:[
                ParameterIdentifier(sp),
                ParameterIdentifier(sp),
                ParameterIdentifier("r0")
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testADDI16_small_imm_pos() throws {
        let input = TackInstructionNode(.addiw(.w(1), .w(0), 15))
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testADDI16_small_imm_neg() throws {
        let input = TackInstructionNode(.addiw(.w(1), .w(0), -16))
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(-16)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testADDI16_large_imm_pos() throws {
        let input = TackInstructionNode(.addiw(.w(1), .w(0), 16))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let input = TackInstructionNode(.addiw(.w(1), .w(0), -17))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let input = TackInstructionNode(.subiw(.w(1), .w(0), 15))
        let expected = InstructionNode(instruction: kSUBI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testANDI16() throws {
        let input = TackInstructionNode(.andiw(.w(1), .w(0), 15))
        let expected = InstructionNode(instruction: kANDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(15)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testMULI16_zero() throws {
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 0))
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r1"),
            ParameterNumber(0)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testMULI16_pos_one() throws {
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 1))
        let expected = InstructionNode(instruction: kADDI, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterNumber(0)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testMULI16_pos_two() throws {
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 2))
        let expected = InstructionNode(instruction: kADD, parameters:[
            ParameterIdentifier("r1"),
            ParameterIdentifier("r0"),
            ParameterIdentifier("r0")
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testMULI16_pos_three() throws {
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 3))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 4))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 5))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 6))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 7))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 8))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), -1))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), -2))
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
        let input = TackInstructionNode(.muliw(.w(1), .w(0), 14))
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
        let input = TackInstructionNode(.liw(.w(0), 127))
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(127)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLI16_small_neg() throws {
        let input = TackInstructionNode(.liw(.w(0), -128))
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(-128)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLI16_med_pos() throws {
        let input = TackInstructionNode(.liw(.w(0), 127))
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(127)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLI16_large_pos_1() throws {
        let input = TackInstructionNode(.liw(.w(0), 255))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(255)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLI16_large_pos_2() throws {
        let input = TackInstructionNode(.liw(.w(0), 0x7fff))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let input = TackInstructionNode(.liuw(.w(0), 255))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0xff)
            ]),
            InstructionNode(instruction: kLUI, parameters:[
                ParameterIdentifier("r0"),
                ParameterNumber(0x00)
            ])
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }

    func testLIU16_large_pos() throws {
        let input = TackInstructionNode(.liuw(.w(0), 0x8000))
        let expected = Seq(children: [
            InstructionNode(instruction: kLI, parameters:[
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
        let input = TackInstructionNode(.mulw(.w(2), .w(1), .w(0)))
        let computer = makeDebugger(assembly: try compile(input)).computer
        computer.setRegister(0, 0)
        computer.setRegister(1, 0)
        computer.setRegister(3, 42)
        computer.run()
        XCTAssertEqual(computer.getRegister(3), 0)
    }

    func testMUL16_1_x_1() throws {
        let input = TackInstructionNode(.mulw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(3, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 1)
    }

    func testMUL16_2_x_2() throws {
        let input = TackInstructionNode(.mulw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 2)
        debugger.computer.setRegister(1, 2)
        debugger.computer.setRegister(3, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 4)
    }

    func testDIVW_0_div_0() throws {
        let input = TackInstructionNode(.divw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0)
        debugger.computer.setRegister(2, 0xabcd)
        debugger.computer.run()
//        while !debugger.computer.isHalted {
//            print("---")
//            debugger.computer.step()
//            debugger.interpreter.runOne(instruction: .disassemble(.baseCount(debugger.computer.cpu.getPipelineStageInfo(2).pc ?? 0, 1)))
//            debugger.interpreter.runOne(instruction: .reg)
//        }
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testDIVW_1_div_1() throws {
        let input = TackInstructionNode(.divw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(2, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }
    
    fileprivate let minusOne = UInt16(0) &- UInt16(1)
    
    func testDIVW_minus1_div_1() throws {
        let input = TackInstructionNode(.divw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1)
        debugger.computer.setRegister(1, minusOne)
        debugger.computer.setRegister(2, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), minusOne)
    }
    
    func testDIVW_1_div_minus1() throws {
        let input = TackInstructionNode(.divw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, minusOne)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(2, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), minusOne)
    }
    
    func testDIVW_minus1_div_minus1() throws {
        let input = TackInstructionNode(.divw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, minusOne)
        debugger.computer.setRegister(1, minusOne)
        debugger.computer.setRegister(2, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testDIVW_12_div_4() throws {
        let input = TackInstructionNode(.divw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 4)
        debugger.computer.setRegister(1, 12)
        debugger.computer.setRegister(2, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 3)
    }
    
    func testDIVUW_0_div_0() throws {
        let input = TackInstructionNode(.divuw(.w(2), .w(1), .w(0)))
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

    func testDIVUW_1_div_1() throws {
        let input = TackInstructionNode(.divuw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 1)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(2, 100)
        debugger.computer.setRegister(3, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 1)
    }

    func testDIVUW_12_div_4() throws {
        let input = TackInstructionNode(.divuw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 4)
        debugger.computer.setRegister(1, 12)
        debugger.computer.setRegister(2, 100)
        debugger.computer.setRegister(3, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 3)
    }

    func testDIVUW_0xabcd_div_16() throws {
        let input = TackInstructionNode(.divuw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 16)
        debugger.computer.setRegister(1, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(3), 0xabc)
    }

    func testMOD16_0_mod_0() throws {
        let input = TackInstructionNode(.modw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0)
        debugger.computer.setRegister(1, 0)
        debugger.computer.setRegister(2, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testMOD16_3_mod_2() throws {
        let input = TackInstructionNode(.modw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 2)
        debugger.computer.setRegister(1, 3)
        debugger.computer.setRegister(2, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testMOD16_0xabcd_mod_16() throws {
        let input = TackInstructionNode(.modw(.w(2), .w(1), .w(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 16)
        debugger.computer.setRegister(1, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 13)
    }

    func testLSL16_0_shift_0() throws {
        let input = TackInstructionNode(.lslw(.w(2), .w(1), .w(0)))
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
        let input = TackInstructionNode(.lslw(.w(2), .w(1), .w(0)))
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
        let input = TackInstructionNode(.lsrw(.w(2), .w(1), .w(0)))
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
        let input = TackInstructionNode(.eqw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testEQ16_not_equal() throws {
        let input = TackInstructionNode(.eqw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testNE16_equal() throws {
        let input = TackInstructionNode(.new(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testNE16_not_equal() throws {
        let input = TackInstructionNode(.new(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLT16_less_than() throws {
        let input = TackInstructionNode(.ltw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, UInt16(0) &- 1)
        debugger.computer.setRegister(0, 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLT16_equal() throws {
        let input = TackInstructionNode(.ltw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, UInt16(0) &- 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testLT16_greater_than() throws {
        let input = TackInstructionNode(.ltw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGE16_less_than() throws {
        let input = TackInstructionNode(.gew(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, UInt16(0) &- 1)
        debugger.computer.setRegister(0, 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGE16_equal() throws {
        let input = TackInstructionNode(.gew(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, UInt16(0) &- 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testGE16_greater_than() throws {
        let input = TackInstructionNode(.gew(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLE16_less_than() throws {
        let input = TackInstructionNode(.lew(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, UInt16(0) &- 1)
        debugger.computer.setRegister(0, 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLE16_equal() throws {
        let input = TackInstructionNode(.lew(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, UInt16(0) &- 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLE16_greater_than() throws {
        let input = TackInstructionNode(.lew(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGT16_less_than() throws {
        let input = TackInstructionNode(.gtw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testGT16_equal() throws {
        let input = TackInstructionNode(.gtw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, UInt16(0) &- 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGT16_greater_than() throws {
        let input = TackInstructionNode(.gtw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 1)
        debugger.computer.setRegister(0, UInt16(0) &- 1)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLTU16_less_than() throws {
        let input = TackInstructionNode(.ltuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLTU16_equal() throws {
        let input = TackInstructionNode(.ltuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testLTU16_greater_than() throws {
        let input = TackInstructionNode(.ltuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGEU16_less_than() throws {
        let input = TackInstructionNode(.geuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGEU16_equal() throws {
        let input = TackInstructionNode(.geuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testGEU16_greater_than() throws {
        let input = TackInstructionNode(.geuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLEU16_less_than() throws {
        let input = TackInstructionNode(.leuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLEU16_equal() throws {
        let input = TackInstructionNode(.leuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLEU16_greater_than() throws {
        let input = TackInstructionNode(.leuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGTU16_less_than() throws {
        let input = TackInstructionNode(.gtuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGTU16_equal() throws {
        let input = TackInstructionNode(.gtuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 42)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGTU16_greater_than() throws {
        let input = TackInstructionNode(.gtuw(.o(2), .w(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 43)
        debugger.computer.setRegister(0, 42)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    fileprivate func doTestLI8(_ value: Int) throws {
        let input = TackInstructionNode(.liw(.w(0), value))
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

    func testLI8_max_signed() throws {
        try doTestLI8(127)
    }

    func testLI8_min_signed() throws {
        try doTestLI8(-128)
    }

    fileprivate func doTestLIU8(_ value: Int) throws {
        let input = TackInstructionNode(.liub(.b(0), value))
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

    func testLIU8_max_unsigned() throws {
        try doTestLIU8(255)
    }

    func testAND8() throws {
        let input = TackInstructionNode(.andb(.b(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0xffff)
        debugger.computer.setRegister(1, 0xff01)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0x0001)
    }

    func testOR8() throws {
        let input = TackInstructionNode(.orb(.b(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0xfffe)
        debugger.computer.setRegister(1, 0xff01)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0x00ff)
    }

    func testXOR8() throws {
        let input = TackInstructionNode(.xorb(.b(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 0xabab)
        debugger.computer.setRegister(1, 0xcdcd)
        debugger.computer.setRegister(2, 0xdead)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0x0066)
    }

    func testNEG8() throws {
        let input = TackInstructionNode(.negb(.b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(1, 0xdead)
        debugger.computer.setRegister(0, 0x00)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(1), 0xff)
        XCTAssertEqual(debugger.computer.getRegister(0), 0x00)
    }

    func testADD8_positive_result() throws {
        let input = TackInstructionNode(.addb(.b(2), .b(1), .b(0)))
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
        let input = TackInstructionNode(.addb(.b(2), .b(1), .b(0)))
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
        let input = TackInstructionNode(.subb(.b(2), .b(1), .b(0)))
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
        let input = TackInstructionNode(.subb(.b(2), .b(1), .b(0)))
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
        let input = TackInstructionNode(.mulb(.b(2), .b(1), .b(0)))
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

    func testDIVB() throws {
        let input = TackInstructionNode(.divb(.b(2), .b(1), .b(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, UInt16(0) &- UInt16(4))
        debugger.computer.setRegister(1, 12)
        debugger.computer.setRegister(2, 0xabcd)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), UInt16(0) &- UInt16(3))
    }
    
    func testDIVUB() throws {
        let input = TackInstructionNode(.divub(.b(2), .b(1), .b(0)))
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
        let input = TackInstructionNode(.modb(.b(2), .b(1), .b(0)))
        let debugger = makeDebugger(assembly: try compile(input))
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(0, 2)
        debugger.computer.setRegister(1, 3)
        debugger.computer.setRegister(2, 100)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLSL8_2_shift_1() throws {
        let input = TackInstructionNode(.lslb(.b(2), .b(1), .b(0)))
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
        let input = TackInstructionNode(.lsrb(.b(2), .b(1), .b(0)))
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
        let input = TackInstructionNode(.eqb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xff42)
        debugger.computer.setRegister(0, 0x0042)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testEQ8_not_equal() throws {
        let input = TackInstructionNode(.eqb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xab42)
        debugger.computer.setRegister(0, 0xcd43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testNE8_equal() throws {
        let input = TackInstructionNode(.neb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xff42)
        debugger.computer.setRegister(0, 0x0042)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testNE8_not_equal() throws {
        let input = TackInstructionNode(.neb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xab42)
        debugger.computer.setRegister(0, 0xcd43)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLT8() throws {
        let input = TackInstructionNode(.ltb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0x00fe)
        debugger.computer.setRegister(0, 0xffff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLE8() throws {
        let input = TackInstructionNode(.leb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0x00fe)
        debugger.computer.setRegister(0, 0xffff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testGT8() throws {
        let input = TackInstructionNode(.gtb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xffff)
        debugger.computer.setRegister(0, 0x0000)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testGE8() throws {
        let input = TackInstructionNode(.geb(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xffff)
        debugger.computer.setRegister(0, 0x0000)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 0)
    }

    func testLTU8() throws {
        let input = TackInstructionNode(.ltub(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xff00)
        debugger.computer.setRegister(0, 0x00ff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testLEU8() throws {
        let input = TackInstructionNode(.leub(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0xff00)
        debugger.computer.setRegister(0, 0x00ff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }

    func testGTU8() throws {
        let input = TackInstructionNode(.gtub(.o(2), .b(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(2, 0)
        debugger.computer.setRegister(1, 0x00ff)
        debugger.computer.setRegister(0, 0xff00)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(2), 1)
    }
    
    func testMOVSBW() throws {
        let input = TackInstructionNode(.movsbw(.b(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(1, 0x0000)
        debugger.computer.setRegister(0, 0xaaff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(1), 0xffff)
    }
    
    func testMOVSWB() throws {
        let input = TackInstructionNode(.movswb(.w(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(1, 0x0000)
        debugger.computer.setRegister(0, 0xaaff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(1), 0xffff)
    }
    
    func testMOVZWB() throws {
        let input = TackInstructionNode(.movzwb(.w(1), .b(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(1, 0x0000)
        debugger.computer.setRegister(0, 0xffff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(1), 0x00ff)
    }
    
    func testMOVZBW() throws {
        let input = TackInstructionNode(.movzbw(.b(1), .w(0)))
        let assembly = try compile(input)
        let debugger = makeDebugger(assembly: assembly)
        debugger.logger = PrintLogger()
        debugger.computer.setRegister(1, 0x0000)
        debugger.computer.setRegister(0, 0xffff)
        debugger.computer.run()
        XCTAssertEqual(debugger.computer.getRegister(1), 0x00ff)
    }
    
    func testLIO_true() throws {
        let input = TackInstructionNode(.lio(.o(0), true))
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(1)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
    
    func testLIO_false() throws {
        let input = TackInstructionNode(.lio(.o(0), false))
        let expected = InstructionNode(instruction: kLI, parameters:[
            ParameterIdentifier("r0"),
            ParameterNumber(0)
        ])
        let actual = try compile(input)
        XCTAssertEqual(actual, expected)
    }
}
