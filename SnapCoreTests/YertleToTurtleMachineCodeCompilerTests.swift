//
//  YertleToTurtleMachineCodeCompilerTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/31/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleSimulatorCore
import TurtleCompilerToolbox
import TurtleCore

class YertleToTurtleMachineCodeCompilerTests: XCTestCase {
    let kFramePointerHi = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    let kFramePointerLo = Int(YertleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    
    func disassemble(_ instructions: [Instruction]) -> String {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        var result = ""
        let formatter = InstructionFormatter(microcodeGenerator: microcodeGenerator)
        if let instruction = instructions.first {
            result += formatter.makeInstructionWithDisassembly(instruction: instruction).disassembly ?? instruction.description
        }
        for instruction in instructions[1..<instructions.count] {
            result += "\n"
            result += formatter.makeInstructionWithDisassembly(instruction: instruction).disassembly ?? instruction.description
        }
        return result
    }
    
    func compile(_ instructions: [YertleInstruction]) -> [Instruction] {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let compiler = YertleToTurtleMachineCodeCompiler(assembler: assembler)
        try! compiler.compile(ir: instructions, base: 0)
        let instructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: assembler.instructions)
        return instructions
    }
    
    func execute(ir: [YertleInstruction]) throws -> Computer {
        let executor = YertleExecutor()
        let computer = try executor.execute(ir: ir)
        return computer
    }
    
    func testEmptyProgram() {
        let kFramePointerInitialValue = YertleToTurtleMachineCodeCompiler.kFramePointerInitialValue
        let kStackPointerInitialValue = YertleToTurtleMachineCodeCompiler.kStackPointerInitialValue
        let computer = try! execute(ir: [])
        XCTAssertEqual(computer.framePointer, kFramePointerInitialValue)
        XCTAssertEqual(computer.stackPointer, kStackPointerInitialValue)
    }
    
    func testPushOneValue() {
        let computer1 = try! execute(ir: [.push(1)])
        XCTAssertEqual(computer1.stack(at: 0), 1)
        
        let computer2 = try! execute(ir: [.push(2)])
        XCTAssertEqual(computer2.stack(at: 0), 2)
    }
    
    func testPushTwoValues() {
        let computer = try! execute(ir: [.push(1), .push(2)])
        XCTAssertEqual(computer.stack(at: 0), 2)
        XCTAssertEqual(computer.stack(at: 1), 1)
    }
    
    func testPushThreeValues() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3)])
        XCTAssertEqual(computer.stack(at: 0), 3)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
        XCTAssertEqual(computer.stackPointer, 0xfffd)
    }
    
    func testPushFourValues() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4)])
        XCTAssertEqual(computer.stack(at: 0), 4)
        XCTAssertEqual(computer.stack(at: 1), 3)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
        XCTAssertEqual(computer.stackPointer, 0xfffc)
    }
    
    func testPushManyValues() {
        let kStackPointerInitialValue = UInt16(YertleToTurtleMachineCodeCompiler.kStackPointerInitialValue)
        let count = 300
        var ir: [YertleInstruction] = []
        for i in 0..<count {
            let value = UInt8(i % 256)
            ir.append(.push(Int(value)))
        }
        let computer = try! execute(ir: ir)
        
        let expectedStackPointer = kStackPointerInitialValue &- UInt16(count)
        XCTAssertEqual(computer.stackPointer, Int(expectedStackPointer))
        
        for i in 0..<count {
            XCTAssertEqual(computer.stack(at: i), UInt8((count-i-1) % 256))
        }
    }
    
    func testPushOneDoubleWordValue() {
        let computer = try! execute(ir: [.push16(1024)])
        XCTAssertEqual(computer.stack16(at: 0), 1024)
    }
    
    func testPushTwoDoubleWordValues() {
        let computer = try! execute(ir: [.push16(0x5678), .push16(0x1234)])
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffc), 0x12)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffd), 0x34)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffe), 0x56)
        XCTAssertEqual(computer.dataRAM.load(from: 0xffff), 0x78)
        
        XCTAssertEqual(computer.dataRAM.load16(from: 0xfffe), 0x5678)
        XCTAssertEqual(computer.dataRAM.load16(from: 0xfffc), 0x1234)
        
        XCTAssertEqual(computer.stackPointer, 0xfffc)
    
        XCTAssertEqual(computer.stack(at: 0), 0x12)
        XCTAssertEqual(computer.stack(at: 1), 0x34)
        XCTAssertEqual(computer.stack(at: 2), 0x56)
        XCTAssertEqual(computer.stack(at: 3), 0x78)
        
        XCTAssertEqual(computer.stack16(at: 0), 0x1234)
        XCTAssertEqual(computer.stack16(at: 2), 0x5678)
    }
    
    func testPushManyDoubleWordValues() {
        let kStackPointerInitialValue = UInt16(YertleToTurtleMachineCodeCompiler.kStackPointerInitialValue)
        let count = 1000
        var ir: [YertleInstruction] = []
        for i in 0..<count {
            ir.append(.push16(i))
        }
        let computer = try! execute(ir: ir)
        
        let expectedStackPointer = kStackPointerInitialValue &- UInt16(count*2)
        XCTAssertEqual(computer.stackPointer, Int(expectedStackPointer))
        
        for i in 0..<count {
            XCTAssertEqual(computer.stack16(at: i*2), UInt16(count-i-1))
        }
    }
    
    func testPushStackPointer() {
        let computer = try! execute(ir: [.push16(0xabcd), .pushsp])
        XCTAssertEqual(computer.stack16(at: 0), 0xfffe)
    }
    
    func testPopWithStackDepthFive() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .push(5), .pop])
        XCTAssertEqual(computer.stack(at: 0), 4)
        XCTAssertEqual(computer.stack(at: 1), 3)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
        XCTAssertEqual(computer.stackPointer, 0xfffc)
    }
    
    func testPop16WithStackDepthFive() {
        let computer = try! execute(ir: [.push16(1000), .push16(2000), .push16(3000), .push16(4000), .push16(5000), .pop16])
        XCTAssertEqual(computer.stack16(at: 0), 4000)
        XCTAssertEqual(computer.stack16(at: 2), 3000)
        XCTAssertEqual(computer.stack16(at: 4), 2000)
        XCTAssertEqual(computer.stack16(at: 6), 1000)
        XCTAssertEqual(computer.stackPointer, 0xfff8)
    }
    
    func testPopnWithStackDepthFive() {
        let computer = try! execute(ir: [.push16(1000), .push16(2000), .push16(3000), .push16(4000), .push16(5000), .popn(2)])
        XCTAssertEqual(computer.stack16(at: 0), 4000)
        XCTAssertEqual(computer.stack16(at: 2), 3000)
        XCTAssertEqual(computer.stack16(at: 4), 2000)
        XCTAssertEqual(computer.stack16(at: 6), 1000)
        XCTAssertEqual(computer.stackPointer, 0xfff8)
    }
    
    func testEq16_0x0000_and_0x0000() {
        let computer = try! execute(ir: [.push16(0), .push16(0), .eq16])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testEq16_0xffff_and_0x00ff() {
        let computer = try! execute(ir: [.push(3), .push(2), .push16(0xffff), .push16(0x00ff), .eq16])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 3)
    }
    
    func testEqWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .eq])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testNeWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .ne])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testNe16_0xffff_and_0x00ff() {
        let computer = try! execute(ir: [.push(3), .push(2), .push16(0xffff), .push16(0x00ff), .ne16])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 3)
    }
    
    func testLtWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .lt])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLt16_0_lt_0_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(0), .lt16])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLt16_1_lt_1_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(1), .push16(1), .lt16])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLt16_0_lt_1_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(1), .push16(0), .lt16])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLt16_1_lt_0_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(1), .lt16])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLt16_1000_lt_2000_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(2000), .push16(1000), .lt16])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGtWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .gt])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGt16_0_gt_0_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(0), .gt16])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGt16_300_gt_300_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(300), .push16(300), .gt16])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGt16_0_gt_1_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(1), .push16(0), .gt16])
        
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGt16_1_gt_0_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(1), .gt16])
        
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGt16_1000_gt_2000_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(2000), .push16(1000), .gt16])
        
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLeWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .le])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLe16_0_le_0_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(0), .le16])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLe16_300_le_300_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(300), .push16(300), .le16])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLe16_0_le_1_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(1), .push16(0), .le16])
        
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLe16_1_le_0_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(1), .le16])
        
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLe16_1000_le_2000_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(2000), .push16(1000), .le16])
        
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGeWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .ge])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGe16_0_ge_0_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(0), .ge16])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGe16_1000_ge_0_is_true() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(1000), .push16(0), .ge16])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testGe16_0_ge_1000_is_false() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0), .push16(1000), .ge16])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testAddWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .add])
        XCTAssertEqual(computer.stack(at: 0), 7)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testAdd16_0x0000_and_0x0000() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0000), .push16(0x0000), .add16])
        XCTAssertEqual(computer.stack16(at: 0), 0x0000)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testAdd16_0x0001_and_0x0001() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0001), .push16(0x0001), .add16])
        XCTAssertEqual(computer.stack16(at: 0), 0x0002)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testAdd16_0xfffe_and_0x0001() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0xfffe), .push16(0x0001), .add16])
        XCTAssertEqual(computer.stack16(at: 0), 0xffff)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testAdd16_0xffff_and_0x0001() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0xffff), .push16(0x0001), .add16])
        // TODO: ADD16 does not set the carry flag. Should it?
        XCTAssertEqual(computer.stack16(at: 0), 0x0000)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testSubWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .sub])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testSubTwice() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .sub, .sub])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testSub16_0x0001_and_0x0001() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0001), .push16(0x0001), .sub16])
        XCTAssertEqual(computer.stack16(at: 0), 0x0000)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testSub16_0x0000_and_0x0001() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0001), .push16(0x0000), .sub16])
        // TODO: SUB16 does not set the carry flag. Should it?
        XCTAssertEqual(computer.stack16(at: 0), 0xffff)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testMul_0x0() {
        let computer = try! execute(ir: [.push(0), .push(0), .mul])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testMul_1x0() {
        let computer = try! execute(ir: [.push(1), .push(0), .mul])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testMul_1x1() {
        let computer = try! execute(ir: [.push(1), .push(1), .mul])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testMul_4x3() {
        let computer = try! execute(ir: [.push(4), .push(3), .mul])
        XCTAssertEqual(computer.stack(at: 0), 12)
    }
    
    func testMul_255x2() {
        // Multiplication is basically modulo 255.
        let computer = try! execute(ir: [.push(255), .push(2), .mul])
        XCTAssertEqual(computer.stack(at: 0), 254)
    }
    
    func testMul16_0x0() {
        let computer = try! execute(ir: [.push16(0x0000), .push16(0x0000), .mul16])
        XCTAssertEqual(computer.stack(at: 0), 0x0000)
    }
    
    func testMul16_255x2() {
        let computer = try! execute(ir: [.push16(0x00ff), .push16(0x0002), .mul16])
        XCTAssertEqual(computer.stack16(at: 0), 0x01fe)
    }
    
    func testMul16_2000x2000() {
        // Multiplication is basically modulo 65536.
        let a = 2000
        let b = 2000
        let computer = try! execute(ir: [.push(1), .push(2), .push16(a), .push16(b), .mul16])
        XCTAssertEqual(computer.stack16(at: 0), UInt16((a*b)%65536))
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testMul_PopsTheStackToo() {
        let computer = try! execute(ir: [.push(255), .push(254), .push(2), .push(2), .mul])
        XCTAssertEqual(computer.stack(at: 0), 4)
        XCTAssertEqual(computer.stack(at: 1), 254)
        XCTAssertEqual(computer.stack(at: 2), 255)
    }
    
    func testDiv_1div0() {
        // There's a check in the DIV command to ensure that all division by
        // zero yields a result of zero.
        let computer = try! execute(ir: [.push(1), .push(0), .div])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testDiv_0div1() {
        let computer = try! execute(ir: [.push(1), .push(0), .div])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testDiv_2div1() {
        let computer = try! execute(ir: [.push(1), .push(2), .div])
        XCTAssertEqual(computer.stack(at: 0), 2)
    }
    
    func testDiv_4div2() {
        let computer = try! execute(ir: [.push(2), .push(4), .div])
        XCTAssertEqual(computer.stack(at: 0), 2)
    }
    
    func testDiv_3div4() {
        let computer = try! execute(ir: [.push(4), .push(3), .div])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testDiv_PopsTheStackToo() {
        let computer = try! execute(ir: [.push(255), .push(254), .push(2), .push(2), .div])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 254)
        XCTAssertEqual(computer.stack(at: 2), 255)
    }
    
    func testDiv16_0x0001_div_0x0000() {
        // There's a check in the DIV command to ensure that all division by
        // zero yields a result of zero.
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0001), .push16(0x0000), .div16])
        //                                                   ^^^dividend      ^^^divisor
        
        XCTAssertEqual(computer.stack16(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testDiv16_0x0001_div_0x0100() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0001), .push16(0x0100), .div16])
        //                                                   ^^^dividend      ^^^divisor
        
        XCTAssertEqual(computer.stack16(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testDiv16_0x0001_div_0x0001() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0001), .push16(0x0001), .div16])
        //                                                   ^^^dividend      ^^^divisor
        
        XCTAssertEqual(computer.stack16(at: 0), 0x0001)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testDiv16_0x0080_div_0x0002() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0080), .push16(0x0002), .div16])
        //                                                   ^^^dividend      ^^^divisor
        
        XCTAssertEqual(computer.stack16(at: 0), 0x0040)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testDiv16_0x00ff_div_0x00ff() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x00ff), .push16(0x00ff), .div16])
        //                                                   ^^^dividend      ^^^divisor
        
        XCTAssertEqual(computer.stack16(at: 0), 0x0001)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testDiv16_0x0100_div_0x0001() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0x0100), .push16(0x0001), .div16])
        //                                                   ^^^dividend      ^^^divisor
        
        XCTAssertEqual(computer.stack16(at: 0), 0x0100)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testDiv16_0xffff_div_0xffff() {
        let computer = try! execute(ir: [.push(1), .push(2), .push16(0xffff), .push16(0xffff), .div16])
        //                                                   ^^^dividend      ^^^divisor
        
        XCTAssertEqual(computer.stack16(at: 0), 0x0001)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
    }
    
    func testMod_1mod0() {
        // There's a check in the MOD command to ensure that all division by
        // zero yields a result of zero.
        let computer = try! execute(ir: [.push(1), .push(0), .mod])
        XCTAssertEqual(computer.stack(at: 0), 0)
    }
    
    func testMod_1mod1() {
        let computer = try! execute(ir: [.push(255), .push(1), .push(1), .mod])
        XCTAssertEqual(computer.stack(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 1), 255)
    }
    
    func testMod_1mod2() {
        let computer = try! execute(ir: [.push(2), .push(1), .mod])
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testMod_7mod4() {
        let computer = try! execute(ir: [.push(4), .push(7), .mod])
        XCTAssertEqual(computer.stack(at: 0), 3)
    }
    
    func testMod_PopsTheStackToo() {
        let computer = try! execute(ir: [.push(255), .push(254), .push(2), .push(3), .mod])
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 254)
        XCTAssertEqual(computer.stack(at: 2), 255)
    }
    
    func testMod16_1_mod_0() {
        // There's a check in the MOD16 command to ensure that all division by
        // zero yields a result of zero.
        let a = 1
        let b = 0
        let computer = try! execute(ir: [.push(255), .push(254), .push16(a), .push16(b), .mod16])
        XCTAssertEqual(computer.stack16(at: 0), 0)
        XCTAssertEqual(computer.stack(at: 2), 254)
        XCTAssertEqual(computer.stack(at: 3), 255)
    }
    
    func testMod16_1_mod_1() {
        let a = 1
        let b = 1
        let computer = try! execute(ir: [.push(255), .push(254), .push16(a), .push16(b), .mod16])
        XCTAssertEqual(computer.stack16(at: 0), UInt16(a%b))
        XCTAssertEqual(computer.stack(at: 2), 254)
        XCTAssertEqual(computer.stack(at: 3), 255)
    }
    
    func testMod16_1000_mod_10() {
        let a = 1000
        let b = 10
        let computer = try! execute(ir: [.push(255), .push(254), .push16(a), .push16(b), .mod16])
        XCTAssertEqual(computer.stack16(at: 0), UInt16(a%b))
        XCTAssertEqual(computer.stack(at: 2), 254)
        XCTAssertEqual(computer.stack(at: 3), 255)
    }
    
    func testMod16_10_mod_1000() {
        let a = 10
        let b = 1000
        let computer = try! execute(ir: [.push(255), .push(254), .push16(a), .push16(b), .mod16])
        XCTAssertEqual(computer.stack16(at: 0), UInt16(a%b))
        XCTAssertEqual(computer.stack(at: 2), 254)
        XCTAssertEqual(computer.stack(at: 3), 255)
    }
    
    func testLoadWithEmptyStack() {
        let value: UInt8 = 0xab
        let address = 0x0010
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: value, to: address)
        }
        let computer = try! executor.execute(ir: [.load(address)])
        XCTAssertEqual(computer.stack(at: 0), value)
    }
    
    func testLoadWithStackDepthOne() {
        let value: UInt8 = 0xab
        let address = 0x0010
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: value, to: address)
        }
        let computer = try! executor.execute(ir: [.push(1), .load(address)])
        XCTAssertEqual(computer.stack(at: 0), value)
        XCTAssertEqual(computer.stack(at: 1), 1)
    }
    
    func testLoadWithStackDepthTwo() {
        let value: UInt8 = 0xab
        let address = 0x0010
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: value, to: address)
        }
        let computer = try! executor.execute(ir: [.push(1), .push(2), .load(address)])
        XCTAssertEqual(computer.stack(at: 0), value)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
        XCTAssertEqual(computer.stackPointer, 0xfffd)
    }
    
    func testLoad16() {
        let value: UInt16 = 0xabcd
        let address = 0x0010
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: UInt8((value>>8)&0xff), to: address+0)
            computer.dataRAM.store(value: UInt8(value&0xff), to: address+1)
        }
        let computer = try! executor.execute(ir: [.push(1), .push(2), .load16(address)])
        XCTAssertEqual(computer.stack16(at: 0), value)
        XCTAssertEqual(computer.stack(at: 2), 2)
        XCTAssertEqual(computer.stack(at: 3), 1)
        XCTAssertEqual(computer.stackPointer, 0xfffc)
    }
    
    func testStoreWithStackDepthOne() {
        let address = 0x0010
        let computer = try! execute(ir: [.push(1), .store(address)])
        XCTAssertEqual(computer.dataRAM.load(from: address), 1)
    }
    
    func testStoreWithStackDepthTwo() {
        let address = 0x0010
        let computer = try! execute(ir: [.push(2), .push(1), .store(address)])
        XCTAssertEqual(computer.dataRAM.load(from: address), 1)
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
    }
    
    func testStoreWithStackDepthThree() {
        let address = 0x0010
        let computer = try! execute(ir: [.push(3), .push(2), .push(1), .store(address)])
        XCTAssertEqual(computer.dataRAM.load(from: address), 1)
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 3)
        XCTAssertEqual(computer.stackPointer, 0xfffd)
    }
    
    func testStoreWithStackDepthFour() {
        let address = 0x0010
        let computer = try! execute(ir: [.push(4), .push(3), .push(2), .push(1), .store(address)])
        XCTAssertEqual(computer.dataRAM.load(from: address), 1)
        XCTAssertEqual(computer.stack(at: 0), 1)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 3)
        XCTAssertEqual(computer.stackPointer, 0xfffc)
    }
    
    func testStore16() {
        let address = 0x0010
        let computer = try! execute(ir: [.push(2), .push(1), .push16(0x1234), .store16(address)])
        XCTAssertEqual(computer.dataRAM.load(from: address+0), 0x12)
        XCTAssertEqual(computer.dataRAM.load(from: address+1), 0x34)
        XCTAssertEqual(computer.stack16(at: 0), 0x1234)
        XCTAssertEqual(computer.stack(at: 2), 1)
        XCTAssertEqual(computer.stack(at: 3), 2)
        XCTAssertEqual(computer.stackPointer, 0xfffc)
    }
    
    func testCompileFailsBecauseLabelRedefinesExistingLabel() {
        let instructions: [YertleInstruction] = [
            .label("foo"),
            .label("foo")
        ]
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let compiler = YertleToTurtleMachineCodeCompiler(assembler: assembler)
        XCTAssertThrowsError(try compiler.compile(ir: instructions, base: 0)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "label redefines existing symbol: `foo'")
        }
    }
    
    func testJmp() {
        let instructions: [YertleInstruction] = [
            .push(1),
            .jmp("foo"),
            .push(42),
            .label("foo")
        ]
        let computer = try! execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testJalr() {
        let instructions: [YertleInstruction] = [
            .push(1),
            .jalr("foo"),
            .push(42),
            .label("foo")
        ]
        let computer = try! execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testJe_TakeTheBranch() {
        let instructions: [YertleInstruction] = [
            .push(1),
            .push(1),
            .je("foo"),
            .push(42),
            .label("foo"),
            .push(100)
        ]
        let computer = try! execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 100)
    }
    
    func testJe_DoNotTakeTheBranch() {
        let instructions: [YertleInstruction] = [
            .push(1),
            .push(0),
            .je("foo"),
            .push(42),
            .label("foo"),
            .push(100)
        ]
        let computer = try! execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 100)
        XCTAssertEqual(computer.stack(at: 1), 42)
    }
    
    func testJe_StackDepthThree() {
        let instructions: [YertleInstruction] = [
            .push(5), // will end up in 0xfffd
            .push(4), // will end up in B
            .push(3), // will end up in A
            .push(2), // will be popped
            .push(1), // will be popped
            .je("foo"),
            .label("foo")
        ]
        let computer = try! execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 3)
        XCTAssertEqual(computer.stack(at: 1), 4)
        XCTAssertEqual(computer.stack(at: 2), 5)
        XCTAssertEqual(computer.stackPointer, 0xfffd)
    }
    
    func testEnter() {
        let computer = try! execute(ir: [.enter])
        XCTAssertEqual(computer.stack16(at: 0), 0x0000)
        XCTAssertEqual(computer.stackPointer, 0xfffe)
        XCTAssertEqual(computer.framePointer, 0xfffe)
    }
    
    func testEnterThenLeave() {
        let computer = try! execute(ir: [.enter, .leave])
        XCTAssertEqual(computer.stackPointer, 0x0000)
        XCTAssertEqual(computer.framePointer, 0x0000)
    }
    
    func testEnterEnter() {
        let computer = try! execute(ir: [.enter, .enter])
        XCTAssertEqual(computer.stack16(at: 2), 0x0000)
        XCTAssertEqual(computer.stack16(at: 0), 0xfffe)
        XCTAssertEqual(computer.stackPointer, 0xfffc)
        XCTAssertEqual(computer.framePointer, 0xfffc)
    }
    
    func testEnterEnterLeave() {
        let computer = try! execute(ir: [.enter, .enter, .leave])
        XCTAssertEqual(computer.stack16(at: 0), 0x0000)
        XCTAssertEqual(computer.stackPointer, 0xfffe)
        XCTAssertEqual(computer.framePointer, 0xfffe)
    }
    
    func testEnterEnterLeaveLeave() {
        let computer = try! execute(ir: [.enter, .enter, .leave, .leave])
        XCTAssertEqual(computer.stackPointer, 0x0000)
        XCTAssertEqual(computer.framePointer, 0x0000)
    }
    
    func testLoadIndirectWithStackDepthTwo() {
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: 0xaa, to: 0x0010)
        }
        let computer = try! executor.execute(ir: [.push16(0x0010), .loadIndirect])
        XCTAssertEqual(computer.stack(at: 0), 0xaa)
    }
    
    func testLoadIndirectWithStackDepthThree() {
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: 0xaa, to: 0x0010)
        }
        let computer = try! executor.execute(ir: [.push(1), .push16(0x0010), .loadIndirect])
        XCTAssertEqual(computer.stack(at: 0), 0xaa)
        XCTAssertEqual(computer.stack(at: 1), 1)
    }
    
    func testLoadIndirectWithStackDepthFour() {
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: 0xaa, to: 0x0010)
        }
        let computer = try! executor.execute(ir: [.push(1), .push(2), .push16(0x0010), .loadIndirect])
        XCTAssertEqual(computer.stack(at: 0), 0xaa)
        XCTAssertEqual(computer.stack(at: 1), 2)
        XCTAssertEqual(computer.stack(at: 2), 1)
    }
    
    func testLoadIndirect16() {
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store16(value: 0x1234, to: 0x0010)
        }
        let computer = try! executor.execute(ir: [.push(0xbb), .push(0xaa), .push16(0x0010), .loadIndirect16])
        
        XCTAssertEqual(computer.stack16(at: 0), 0x1234)
        XCTAssertEqual(computer.stack(at: 2), 0xaa)
        XCTAssertEqual(computer.stack(at: 3), 0xbb)
    }
    
    func testStoreIndirectWithStackDepthThree() {
        let computer = try! execute(ir: [
            .push(0xaa),
            .push16(0x0010),
            .storeIndirect
        ])
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
        XCTAssertEqual(computer.stack(at: 0), 0xaa)
    }
    
    func testStoreIndirectWithStackDepthFour() {
        let computer = try! execute(ir: [
            .push(0xbb),
            .push(0xaa),
            .push16(0x0010),
            .storeIndirect
        ])
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0xaa)
        XCTAssertEqual(computer.stack(at: 0), 0xaa)
        XCTAssertEqual(computer.stack(at: 1), 0xbb)
    }
    
    func testStoreIndirectWithStackDepthFive() {
        let computer = try! execute(ir: [
            .push(0xcc),
            .push(0xbb),
            .push(0xaa),
            .push16(0xfefe),
            .storeIndirect
        ])
        XCTAssertEqual(computer.dataRAM.load(from: 0xfefe), 0xaa)
        XCTAssertEqual(computer.stack(at: 0), 0xaa)
        XCTAssertEqual(computer.stack(at: 1), 0xbb)
        XCTAssertEqual(computer.stack(at: 2), 0xcc)
    }
    
    func testStoreIndirect16() {
        let computer = try! execute(ir: [
            .push(0xcc),
            .push(0xbb),
            .push16(0xabcd),
            .push16(0xfefe),
            .storeIndirect16
        ])
        XCTAssertEqual(computer.dataRAM.load16(from: 0xfefe), 0xabcd)
        XCTAssertEqual(computer.stack16(at: 0), 0xabcd)
        XCTAssertEqual(computer.stack(at: 2), 0xbb)
        XCTAssertEqual(computer.stack(at: 3), 0xcc)
    }
    
    func testStoreIndirectN_1() {
        let computer = try! execute(ir: [
            .push(0x01),
            .push16(0x0010),
            .storeIndirectN(1)
        ])
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0x01)
    }
    
    func testStoreIndirectN_2() {
        let computer = try! execute(ir: [
            .push(0x02),
            .push(0x01),
            .push16(0x0010),
            .storeIndirectN(2)
        ])
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0x01)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 0x02)
    }
    
    func testStoreIndirectN_3() {
        let computer = try! execute(ir: [
            .push(0x03),
            .push(0x02),
            .push(0x01),
            .push16(0x0010),
            .storeIndirectN(3)
        ])
        XCTAssertEqual(computer.dataRAM.load(from: 0x0010), 0x01)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0011), 0x02)
        XCTAssertEqual(computer.dataRAM.load(from: 0x0012), 0x03)
    }
    
    func testLoadIndirectN_1() {
        let ir: [YertleInstruction] = [
            .push16(0x0010),
            .loadIndirectN(1)
        ]
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: 0x01, to: 0x0010)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack(at: 0), 0x01)
    }
    
    func testLoadIndirectN_2() {
        let ir: [YertleInstruction] = [
            .push16(0x0010),
            .loadIndirectN(2)
        ]
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store16(value: 0xabcd, to: 0x0010)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.stack16(at: 0), 0xabcd)
    }
    
    func testLoadIndirectN_3() {
        let ir: [YertleInstruction] = [
            .push16(0x0010),
            .loadIndirectN(3)
        ]
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: 0x01, to: 0x0010)
            computer.dataRAM.store(value: 0x02, to: 0x0011)
            computer.dataRAM.store(value: 0x03, to: 0x0012)
        }
        let computer = try! executor.execute(ir: ir)
        let address = computer.stackPointer
        XCTAssertEqual(computer.dataRAM.load(from: address + 0), 0x01)
        XCTAssertEqual(computer.dataRAM.load(from: address + 1), 0x02)
        XCTAssertEqual(computer.dataRAM.load(from: address + 2), 0x03)
    }
}
