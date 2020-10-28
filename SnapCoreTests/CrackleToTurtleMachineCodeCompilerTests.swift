//
//  CrackleToTurtleMachineCodeCompilerTests.swift
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

class CrackleToTurtleMachineCodeCompilerTests: XCTestCase {
    let kStackPointerAddress = Int(CrackleToTurtleMachineCodeCompiler.kStackPointerAddressHi)
    let kFramePointerHi = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressHi)
    let kFramePointerLo = Int(CrackleToTurtleMachineCodeCompiler.kFramePointerAddressLo)
    
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
    
    func compile(_ instructions: [CrackleInstruction]) -> [Instruction] {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let compiler = CrackleToTurtleMachineCodeCompiler(assembler: assembler)
        try! compiler.compile(ir: instructions, base: 0)
        let instructions = InstructionFormatter.makeInstructionsWithDisassembly(instructions: assembler.instructions)
        return instructions
    }
    
    func execute(ir: [CrackleInstruction]) throws -> Computer {
        let executor = CrackleExecutor()
        let computer = try executor.execute(ir: ir)
        return computer
    }
    
    func testEmptyProgram() {
        let kFramePointerInitialValue = CrackleToTurtleMachineCodeCompiler.kFramePointerInitialValue
        let kStackPointerInitialValue = CrackleToTurtleMachineCodeCompiler.kStackPointerInitialValue
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
        let kStackPointerInitialValue = UInt16(CrackleToTurtleMachineCodeCompiler.kStackPointerInitialValue)
        let count = 300
        var ir: [CrackleInstruction] = []
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
        let kStackPointerInitialValue = UInt16(CrackleToTurtleMachineCodeCompiler.kStackPointerInitialValue)
        let count = 500
        var ir: [CrackleInstruction] = []
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
    
    func testSubi16() {
        let computer = try! execute(ir: [.subi16(kStackPointerAddress, kStackPointerAddress, 500)])
        XCTAssertEqual(computer.stackPointer, Int(UInt16(0) &- 500))
    }
    
    func testAddi16() {
        let computer = try! execute(ir: [.push16(1000), .push16(2000), .push16(3000), .push16(4000), .push16(5000), .addi16(kStackPointerAddress, kStackPointerAddress, 2)])
        XCTAssertEqual(computer.stack16(at: 0), 4000)
        XCTAssertEqual(computer.stack16(at: 2), 3000)
        XCTAssertEqual(computer.stack16(at: 4), 2000)
        XCTAssertEqual(computer.stack16(at: 6), 1000)
        XCTAssertEqual(computer.stackPointer, 0xfff8)
    }
    
    func testMuli16() {
        let c = 0x0010
        let a = 0x0012
        let b = 2
        let ir: [CrackleInstruction] = [.muli16(c, a, b)]
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0, to: c)
            computer.dataRAM.store16(value: 256, to: a)
        }
        let computer = try! executor.execute(ir: ir)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 512)
    }
    
    func testStoreImmediate() {
        let address = 0x0010
        let value = 0xff
        let computer = try! execute(ir: [.storeImmediate(address, value)])
        XCTAssertEqual(computer.dataRAM.load(from: address), UInt8(value))
    }
    
    func testStoreImmediate_TruncatesTheValue() {
        let address = 0x0010
        let value = 0xabcd
        let computer = try! execute(ir: [.storeImmediate(address, value)])
        XCTAssertEqual(computer.dataRAM.load(from: address), UInt8(value & 0xff))
    }
    
    func testStoreImmediate16() {
        let address = 0x0010
        let value = 0xabcd
        let computer = try! execute(ir: [.storeImmediate16(address, value)])
        XCTAssertEqual(computer.dataRAM.load16(from: address), UInt16(value))
    }
    
    func testStoreImmediateBytes() {
        let address = 0x0010
        let bytes: [UInt8] = [0xa, 0xb, 0xc, 0xd]
        let computer = try! execute(ir: [.storeImmediateBytes(address, bytes)])
        
        var arr: [UInt8] = []
        for i in 0..<bytes.count {
            arr.append(computer.dataRAM.load(from: address + i))
        }
        XCTAssertEqual(arr, bytes)
    }
    
    func testStoreImmediateBytesIndirect() {
        let address = 0x0010
        let bytes: [UInt8] = [0xa, 0xb, 0xc, 0xd]
        
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: UInt16(address), to: 0x1000)
        }
        let computer = try! executor.execute(ir: [.storeImmediateBytesIndirect(0x1000, bytes)])
        
        var arr: [UInt8] = []
        for i in 0..<bytes.count {
            arr.append(computer.dataRAM.load(from: address + i))
        }
        XCTAssertEqual(arr, bytes)
    }
    
    func testCompileFailsBecauseLabelRedefinesExistingLabel() {
        let instructions: [CrackleInstruction] = [
            .label("foo"),
            .label("foo")
        ]
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let compiler = CrackleToTurtleMachineCodeCompiler(assembler: assembler)
        XCTAssertThrowsError(try compiler.compile(ir: instructions, base: 0)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "label redefines existing symbol: `foo'")
        }
    }
    
    func testJmp() {
        let instructions: [CrackleInstruction] = [
            .push(1),
            .jmp("foo"),
            .push(42),
            .label("foo")
        ]
        let computer = try! execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testJalr() {
        let instructions: [CrackleInstruction] = [
            .push(1),
            .jalr("foo"),
            .push(42),
            .label("foo")
        ]
        let computer = try! execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 1)
    }
    
    func testIndirectJalr() {
        let instructions: [CrackleInstruction] = [
            .push(1),
            .indirectJalr(0x0100),
            .push(42)
        ]
        
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xffff, to: 0x0100)
        }
        let computer = try! executor.execute(ir: instructions)
        XCTAssertEqual(computer.stack(at: 0), 1)
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
    
    func testAdd() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
            computer.dataRAM.store(value: 2, to: b)
        }
        let computer = try! executor.execute(ir: [.add(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: b), 2)
        XCTAssertEqual(computer.dataRAM.load(from: c), 3)
    }
    
    func testAdd16_0x0000_and_0x0000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0000, to: a)
            computer.dataRAM.store16(value: 0x0000, to: b)
        }
        let computer = try! executor.execute(ir: [.add16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0000)
    }
    
    func testAdd16_0x0001_and_0x0001() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0001, to: a)
            computer.dataRAM.store16(value: 0x0001, to: b)
        }
        let computer = try! executor.execute(ir: [.add16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0002)
    }
    
    func testAdd16_0xfffe_and_0x0001() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xfffe, to: a)
            computer.dataRAM.store16(value: 0x0001, to: b)
        }
        let computer = try! executor.execute(ir: [.add16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0xfffe)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0xffff)
    }
    
    func testAdd16_0xffff_and_0x0001() {
        // TODO: ADD16 does not set the carry flag. Should it?
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xffff, to: a)
            computer.dataRAM.store16(value: 0x0001, to: b)
        }
        let computer = try! executor.execute(ir: [.add16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0xffff)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0000)
    }
    
    func testSub() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 3, to: a)
            computer.dataRAM.store(value: 2, to: b)
        }
        let computer = try! executor.execute(ir: [.sub(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 3)
        XCTAssertEqual(computer.dataRAM.load(from: b), 2)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testSub16_0x0001_and_0x0001() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0001, to: a)
            computer.dataRAM.store16(value: 0x0001, to: b)
        }
        let computer = try! executor.execute(ir: [.sub16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0000)
    }
    
    func testSub16_0x0000_and_0x0001() {
        // TODO: SUB16 does not set the carry flag. Should it?
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0000, to: a)
            computer.dataRAM.store16(value: 0x0001, to: b)
        }
        let computer = try! executor.execute(ir: [.sub16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0xffff)
    }
    
    func testMul_0x0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0, to: a)
            computer.dataRAM.store(value: 0, to: b)
            computer.dataRAM.store(value: 0xff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testMul_1x0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
            computer.dataRAM.store(value: 0, to: b)
            computer.dataRAM.store(value: 0xff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testMul_1x1() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
            computer.dataRAM.store(value: 1, to: b)
            computer.dataRAM.store(value: 0xff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: b), 1)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testMul_4x3() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 4, to: a)
            computer.dataRAM.store(value: 3, to: b)
            computer.dataRAM.store(value: 0xff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 4)
        XCTAssertEqual(computer.dataRAM.load(from: b), 3)
        XCTAssertEqual(computer.dataRAM.load(from: c), 12)
    }
    
    func testMul_255x2() {
        // Multiplication is basically modulo 255.
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 255, to: a)
            computer.dataRAM.store(value: 2, to: b)
            computer.dataRAM.store(value: 0xff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 255)
        XCTAssertEqual(computer.dataRAM.load(from: b), 2)
        XCTAssertEqual(computer.dataRAM.load(from: c), 254)
    }
    
    func testMul16_0x0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0000, to: a)
            computer.dataRAM.store16(value: 0x0000, to: b)
            computer.dataRAM.store16(value: 0xffff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0000)
    }
    
    func testMul16_255x2() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x00ff, to: a)
            computer.dataRAM.store16(value: 0x0002, to: b)
            computer.dataRAM.store16(value: 0xffff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x00ff)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0002)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x01fe)
    }
    
    func testMul16_2000x2000() {
        // Multiplication is basically modulo 65536.
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 2000, to: a)
            computer.dataRAM.store16(value: 2000, to: b)
            computer.dataRAM.store16(value: 0xffff, to: c)
        }
        let computer = try! executor.execute(ir: [.mul16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 2000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 2000)
        XCTAssertEqual(computer.dataRAM.load16(from: c), UInt16((2000*2000)%65536))
    }
    
    func testDiv_1div0() {
        // There's a check in the DIV command to ensure that all division by
        // zero yields a result of zero.
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.div(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testDiv_0div1() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0, to: a)
            computer.dataRAM.store(value: 1, to: b)
        }
        let computer = try! executor.execute(ir: [.div(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load(from: b), 1)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testDiv_2div1() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 2, to: a)
            computer.dataRAM.store(value: 1, to: b)
        }
        let computer = try! executor.execute(ir: [.div(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 2)
        XCTAssertEqual(computer.dataRAM.load(from: b), 1)
        XCTAssertEqual(computer.dataRAM.load(from: c), 2)
    }
    
    func testDiv_4div2() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 4, to: a)
            computer.dataRAM.store(value: 2, to: b)
        }
        let computer = try! executor.execute(ir: [.div(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 4)
        XCTAssertEqual(computer.dataRAM.load(from: b), 2)
        XCTAssertEqual(computer.dataRAM.load(from: c), 2)
    }
    
    func testDiv_3div4() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 3, to: a)
            computer.dataRAM.store(value: 4, to: b)
        }
        let computer = try! executor.execute(ir: [.div(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 3)
        XCTAssertEqual(computer.dataRAM.load(from: b), 4)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testDiv16_0x0001_div_0x0000() {
        // There's a check in the DIV command to ensure that all division by
        // zero yields a result of zero.
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0001, to: a)
            computer.dataRAM.store16(value: 0x0000, to: b)
        }
        let computer = try! executor.execute(ir: [.div16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0000)
    }
    
    func testDiv16_0x0001_div_0x0100() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0001, to: a)
            computer.dataRAM.store16(value: 0x0100, to: b)
        }
        let computer = try! executor.execute(ir: [.div16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0100)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0000)
    }
    
    func testDiv16_0x0001_div_0x0001() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0001, to: a)
            computer.dataRAM.store16(value: 0x0001, to: b)
        }
        let computer = try! executor.execute(ir: [.div16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0001)
    }
    
    func testDiv16_0x0080_div_0x0002() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0080, to: a)
            computer.dataRAM.store16(value: 0x0002, to: b)
        }
        let computer = try! executor.execute(ir: [.div16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0080)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0002)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0040)
    }
    
    func testDiv16_0x00ff_div_0x00ff() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x00ff, to: a)
            computer.dataRAM.store16(value: 0x00ff, to: b)
        }
        let computer = try! executor.execute(ir: [.div16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x00ff)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x00ff)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0001)
    }
    
    func testDiv16_0x0100_div_0x0001() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0100, to: a)
            computer.dataRAM.store16(value: 0x0001, to: b)
        }
        let computer = try! executor.execute(ir: [.div16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0100)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0001)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0100)
    }
    
    func testDiv16_0xffff_div_0xffff() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xffff, to: a)
            computer.dataRAM.store16(value: 0xffff, to: b)
        }
        let computer = try! executor.execute(ir: [.div16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0xffff)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0xffff)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0x0001)
    }
    
    func testMod_1mod0() {
        // There's a check in the MOD command to ensure that all division by
        // zero yields a result of zero.
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.mod(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testMod_1mod1() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
            computer.dataRAM.store(value: 1, to: b)
        }
        let computer = try! executor.execute(ir: [.mod(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: b), 1)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testMod_1mod2() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
            computer.dataRAM.store(value: 2, to: b)
        }
        let computer = try! executor.execute(ir: [.mod(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: b), 2)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testMod_7mod4() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 7, to: a)
            computer.dataRAM.store(value: 4, to: b)
        }
        let computer = try! executor.execute(ir: [.mod(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 7)
        XCTAssertEqual(computer.dataRAM.load(from: b), 4)
        XCTAssertEqual(computer.dataRAM.load(from: c), 3)
    }
    
    func testMod16_1_mod_0() {
        // There's a check in the MOD16 command to ensure that all division by
        // zero yields a result of zero.
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 1, to: a)
            computer.dataRAM.store16(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.mod16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0)
    }
    
    func testMod16_1_mod_1() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 1, to: a)
            computer.dataRAM.store16(value: 1, to: b)
        }
        let computer = try! executor.execute(ir: [.mod16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 1)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 1%1)
    }
    
    func testMod16_1000_mod_10() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 1000, to: a)
            computer.dataRAM.store16(value: 10, to: b)
        }
        let computer = try! executor.execute(ir: [.mod16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 10)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 1000%10)
    }
    
    func testMod16_10_mod_1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 10, to: a)
            computer.dataRAM.store16(value: 1000, to: b)
        }
        let computer = try! executor.execute(ir: [.mod16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 10)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 1000)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 10%1000)
    }
    
    func testEq_42_eq_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.eq(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testEq_42_eq_0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.eq(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testNe_42_ne_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.ne(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testNe_42_ne_0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.ne(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testLt_42_lt_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.lt(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testLt_42_lt_0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.lt(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testLt_0_lt_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.lt(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testGt_42_gt_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.gt(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testGt_42_gt_0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.gt(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testGt_0_gt_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.gt(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testLe_42_le_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.le(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testLe_42_le_0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.le(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testLe_0_le_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.le(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testGe_42_ge_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.ge(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testGe_42_ge_0() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 42, to: a)
            computer.dataRAM.store(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.ge(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 42)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testGe_0_ge_42() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0, to: a)
            computer.dataRAM.store(value: 42, to: b)
        }
        let computer = try! executor.execute(ir: [.ge(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load(from: b), 42)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testEq16_0x0000_and_0x0000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0, to: a)
            computer.dataRAM.store16(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.eq16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testEq16_0xffff_and_0x00ff() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xffff, to: a)
            computer.dataRAM.store16(value: 0x00ff, to: b)
        }
        let computer = try! executor.execute(ir: [.eq16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0xffff)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x00ff)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testNe16_0x0000_and_0x0000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0, to: a)
            computer.dataRAM.store16(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.ne16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testNe16_0xffff_and_0x00ff() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xffff, to: a)
            computer.dataRAM.store16(value: 0x00ff, to: b)
        }
        let computer = try! executor.execute(ir: [.ne16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0xffff)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x00ff)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testLt16_0x0000_lt_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.lt16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testLt16_0x1000_lt_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.lt16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testLt16_0x1000_lt_0x0000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x0000, to: b)
        }
        let computer = try! executor.execute(ir: [.lt16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testGt16_0x0000_gt_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.gt16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testGt16_0x1000_gt_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.gt16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testGt16_0x1000_gt_0x0000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x0000, to: b)
        }
        let computer = try! executor.execute(ir: [.gt16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testLe16_0x0000_le_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.le16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testLe16_0x1000_le_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.le16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testLe16_0x1000_le_0x0000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x0000, to: b)
        }
        let computer = try! executor.execute(ir: [.le16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testGe16_0x0000_ge_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x0000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.ge16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x0000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
    
    func testGe16_0x1000_ge_0x1000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x1000, to: b)
        }
        let computer = try! executor.execute(ir: [.ge16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x1000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testGe16_0x1000_ge_0x0000() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0x1000, to: a)
            computer.dataRAM.store16(value: 0x0000, to: b)
        }
        let computer = try! executor.execute(ir: [.ge16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0x1000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x0000)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testCopyWordZeroExtend() {
        let a = 0x0104
        let b = 0x0108
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcafe, to: a)
            computer.dataRAM.store16(value: 0xbeef, to: b)
        }
        let computer = try! executor.execute(ir: [.copyWordZeroExtend(b, a)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0x00ca)
    }
    
    func testCopyWords_0() {
        let dst = 0x0104
        let src = 0x0108
        let count = 0
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcafe, to: src)
            computer.dataRAM.store16(value: 0xbeef, to: dst)
        }
        let computer = try! executor.execute(ir: [.copyWords(dst, src, count)])
        XCTAssertEqual(computer.dataRAM.load16(from: src), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: dst), 0xbeef)
    }
    
    func testCopyWords_2() {
        let dst = 0x0104
        let src = 0x0108
        let count = 1
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0xaa, to: src)
            computer.dataRAM.store(value: 0x00, to: dst)
        }
        let computer = try! executor.execute(ir: [.copyWords(dst, src, count)])
        XCTAssertEqual(computer.dataRAM.load(from: src), 0xaa)
        XCTAssertEqual(computer.dataRAM.load(from: dst), 0xaa)
    }
    
    func testCopyWords_3() {
        let dst = 0x0104
        let src = 0x0108
        let count = 4
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcafe, to: src+0)
            computer.dataRAM.store16(value: 0xcafe, to: src+2)
            computer.dataRAM.store16(value: 0xbeef, to: dst+0)
            computer.dataRAM.store16(value: 0xbeef, to: dst+2)
        }
        let computer = try! executor.execute(ir: [.copyWords(dst, src, count)])
        XCTAssertEqual(computer.dataRAM.load16(from: src+0), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: src+2), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: dst+0), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: dst+2), 0xcafe)
    }
    
    func testCopyWords_4() {
        let dst = 0x1104
        let src = 0x0108
        let count = 100
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            for i in 0..<count {
                computer.dataRAM.store(value: 0xaa, to: src+i)
            }
            for i in 0..<count {
                computer.dataRAM.store(value: 0x00, to: dst+i)
            }
        }
        let computer = try! executor.execute(ir: [.copyWords(dst, src, count)])
        for i in 0..<count {
            XCTAssertEqual(computer.dataRAM.load(from: src+i), 0xaa)
        }
        for i in 0..<count {
            XCTAssertEqual(computer.dataRAM.load(from: dst+i), 0xaa)
        }
    }
    
    func testCopyWordsIndirectSource_0() {
        let dst = 0x0104
        let src = 0x0108
        let srcPtr = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcdcd, to: dst)
            computer.dataRAM.store16(value: 0xcafe, to: src)
            computer.dataRAM.store16(value: UInt16(src), to: srcPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectSource(dst, srcPtr, 0)])
        XCTAssertEqual(computer.dataRAM.load16(from: dst), 0xcdcd)
        XCTAssertEqual(computer.dataRAM.load16(from: src), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: srcPtr), UInt16(src))
    }
    
    func testCopyWordsIndirectSource_1() {
        let dst = 0x0104
        let src = 0x0108
        let srcPtr = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcdcd, to: dst)
            computer.dataRAM.store16(value: 0xcafe, to: src)
            computer.dataRAM.store16(value: UInt16(src), to: srcPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectSource(dst, srcPtr, 2)])
        XCTAssertEqual(computer.dataRAM.load16(from: dst), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: src), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: srcPtr), UInt16(src))
    }
    
    func testCopyWordsIndirectSource_2() {
        let dst = 0x2104
        let src = 0x1108
        let srcPtr = 0x010a
        let n = 100
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            for i in 0..<n {
                computer.dataRAM.store(value: 0x00, to: dst+i)
            }
            for i in 0..<n {
                computer.dataRAM.store(value: 0xcc, to: src+i)
            }
            computer.dataRAM.store16(value: UInt16(src), to: srcPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectSource(dst, srcPtr, n)])
        for i in 0..<n {
            XCTAssertEqual(computer.dataRAM.load(from: dst+i), 0xcc)
        }
        for i in 0..<n {
            XCTAssertEqual(computer.dataRAM.load(from: src+i), 0xcc)
        }
        XCTAssertEqual(computer.dataRAM.load16(from: srcPtr), UInt16(src))
    }
    
    func testCopyWordsIndirectDestination_0() {
        let dst = 0x0104
        let src = 0x0108
        let dstPtr = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcdcd, to: dst)
            computer.dataRAM.store16(value: 0xcafe, to: src)
            computer.dataRAM.store16(value: UInt16(dst), to: dstPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectDestination(dstPtr, src, 0)])
        XCTAssertEqual(computer.dataRAM.load16(from: dst), 0xcdcd)
        XCTAssertEqual(computer.dataRAM.load16(from: src), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: dstPtr), UInt16(dst))
    }
    
    func testCopyWordsIndirectDestination_1() {
        let src = 0x2104
        let dst = 0x1108
        let dstPtr = 0x010a
        let n = 100
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            for i in 0..<n {
                computer.dataRAM.store(value: 0xcc, to: src+i)
            }
            for i in 0..<n {
                computer.dataRAM.store(value: 0x00, to: dst+i)
            }
            computer.dataRAM.store16(value: UInt16(dst), to: dstPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectDestination(dstPtr, src, n)])
        for i in 0..<n {
            XCTAssertEqual(computer.dataRAM.load(from: src+i), 0xcc)
        }
        for i in 0..<n {
            XCTAssertEqual(computer.dataRAM.load(from: dst+i), 0xcc)
        }
        XCTAssertEqual(computer.dataRAM.load16(from: dstPtr), UInt16(dst))
    }
    
    func testCopyWordsIndirectDestination_2() {
        let dst = 0x0104
        let src = 0x0108
        let dstPtr = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcdcd, to: dst)
            computer.dataRAM.store16(value: 0xcafe, to: src)
            computer.dataRAM.store16(value: UInt16(dst), to: dstPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectDestination(dstPtr, src, 2)])
        XCTAssertEqual(computer.dataRAM.load16(from: dst), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: src), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: dstPtr), UInt16(dst))
    }
    
    func testCopyWordsIndirectDestinationIndirectSource_0() {
        let dst = 0x2104
        let src = 0x1108
        let dstPtr = 0x010a
        let srcPtr = 0x010c
        let n = 0
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcdcd, to: dst)
            computer.dataRAM.store16(value: 0xcafe, to: src)
            computer.dataRAM.store16(value: UInt16(dst), to: dstPtr)
            computer.dataRAM.store16(value: UInt16(src), to: srcPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectDestinationIndirectSource(dstPtr, srcPtr, n)])
        XCTAssertEqual(computer.dataRAM.load16(from: dst), 0xcdcd)
        XCTAssertEqual(computer.dataRAM.load16(from: src), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: dstPtr), UInt16(dst))
        XCTAssertEqual(computer.dataRAM.load16(from: srcPtr), UInt16(src))
    }
    
    func testCopyWordsIndirectDestinationIndirectSource_1() {
        let dst = 0x0104
        let src = 0x0108
        let dstPtr = 0x010a
        let srcPtr = 0x010c
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0xcdcd, to: dst)
            computer.dataRAM.store16(value: 0xcafe, to: src)
            computer.dataRAM.store16(value: UInt16(dst), to: dstPtr)
            computer.dataRAM.store16(value: UInt16(src), to: srcPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectDestinationIndirectSource(dstPtr, srcPtr, 2)])
        XCTAssertEqual(computer.dataRAM.load16(from: dst), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: src), 0xcafe)
        XCTAssertEqual(computer.dataRAM.load16(from: dstPtr), UInt16(dst))
        XCTAssertEqual(computer.dataRAM.load16(from: srcPtr), UInt16(src))
    }
    
    func testCopyWordsIndirectDestinationIndirectSource_2() {
        let dst = 0x2104
        let src = 0x1108
        let dstPtr = 0x010a
        let srcPtr = 0x010c
        let n = 100
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            for i in 0..<n {
                computer.dataRAM.store(value: 0xcc, to: src+i)
            }
            for i in 0..<n {
                computer.dataRAM.store(value: 0x00, to: dst+i)
            }
            computer.dataRAM.store16(value: UInt16(dst), to: dstPtr)
            computer.dataRAM.store16(value: UInt16(src), to: srcPtr)
        }
        let computer = try! executor.execute(ir: [.copyWordsIndirectDestinationIndirectSource(dstPtr, srcPtr, n)])
        for i in 0..<n {
            XCTAssertEqual(computer.dataRAM.load(from: src+i), 0xcc)
        }
        for i in 0..<n {
            XCTAssertEqual(computer.dataRAM.load(from: dst+i), 0xcc)
        }
        XCTAssertEqual(computer.dataRAM.load16(from: dstPtr), UInt16(dst))
        XCTAssertEqual(computer.dataRAM.load16(from: srcPtr), UInt16(src))
    }
    
    func testJz_TakeTheBranch() {
        let a = 0x0100
        let b = 0x0102
        let computer = try! execute(ir: [
            .storeImmediate(a, 0xaa),
            .storeImmediate(b, 0),
            .jz(".L0", b),
            .storeImmediate(a, 0xbb),
            .label(".L0")
        ])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0xaa)
    }
    
    func testJz_DoNotTakeTheBranch() {
        let a = 0x0100
        let b = 0x0102
        let computer = try! execute(ir: [
            .storeImmediate(a, 0xaa),
            .storeImmediate(b, 1),
            .jz(".L0", b),
            .storeImmediate(a, 0xbb),
            .label(".L0")
        ])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0xbb)
    }
    
    func testCopyLabel_FailsBecauseLabelIsUndefined() {
        let instructions: [CrackleInstruction] = [
            .copyLabel(0x0100, "foo")
        ]
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
        let compiler = CrackleToTurtleMachineCodeCompiler(assembler: assembler)
        XCTAssertThrowsError(try compiler.compile(ir: instructions, base: 0)) {
            let compilerError = $0 as? CompilerError
            XCTAssertNotNil(compilerError)
            XCTAssertEqual(compilerError?.message, "cannot resolve label `foo'")
        }
    }
    
    func testCopyLabel_Success() {
        let a = 0x0100
        let computer = try! execute(ir: [
            .copyLabel(a, "foo"),
            .label("foo")
        ])
        let expectedAddress: UInt16 = 14 // This is a tad fragile since the label address depends on the prologue.
        XCTAssertEqual(computer.dataRAM.load16(from: a), expectedAddress)
    }
    
    func testAnd() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0b11001100, to: a)
            computer.dataRAM.store(value: 0b10101010, to: b)
        }
        let computer = try! executor.execute(ir: [.and(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0b11001100)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0b10101010)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0b10001000)
    }
    
    func testAnd16() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0b1100110011001100, to: a)
            computer.dataRAM.store16(value: 0b1010101010101010, to: b)
        }
        let computer = try! executor.execute(ir: [.and16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0b1100110011001100)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0b1010101010101010)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0b1000100010001000)
    }
    
    func testOr() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0b11001100, to: a)
            computer.dataRAM.store(value: 0b10101010, to: b)
        }
        let computer = try! executor.execute(ir: [.or(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0b11001100)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0b10101010)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0b11101110)
    }
    
    func testOr16() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0b1100110011001100, to: a)
            computer.dataRAM.store16(value: 0b1010101010101010, to: b)
        }
        let computer = try! executor.execute(ir: [.or16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0b1100110011001100)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0b1010101010101010)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0b1110111011101110)
    }
    
    func testXor() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0b11001100, to: a)
            computer.dataRAM.store(value: 0b10101010, to: b)
        }
        let computer = try! executor.execute(ir: [.xor(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0b11001100)
        XCTAssertEqual(computer.dataRAM.load(from: b), 0b10101010)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0b01100110)
    }
    
    func testXor16() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0b1100110011001100, to: a)
            computer.dataRAM.store16(value: 0b1010101010101010, to: b)
        }
        let computer = try! executor.execute(ir: [.xor16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0b1100110011001100)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0b1010101010101010)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0b0110011001100110)
    }
    
    func testLsl() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0b00001000, to: a)
            computer.dataRAM.store(value: 2, to: b)
        }
        let computer = try! executor.execute(ir: [.lsl(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0b00001000)
        XCTAssertEqual(computer.dataRAM.load(from: b), 2)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0b00100000)
    }
    
    func testLsl16() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0b0000000010000000, to: a)
            computer.dataRAM.store16(value: 2, to: b)
        }
        let computer = try! executor.execute(ir: [.lsl16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0b0000000010000000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 2)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0b0000001000000000)
    }
    
    func testLsr() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0b00001000, to: a)
            computer.dataRAM.store(value: 1, to: b)
        }
        let computer = try! executor.execute(ir: [.lsr(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0b00001000)
        XCTAssertEqual(computer.dataRAM.load(from: b), 1)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0b00000100)
    }
    
    func testLsr16() {
        let a = 0x0104
        let b = 0x0108
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0b0000000100000000, to: a)
            computer.dataRAM.store16(value: 0, to: b)
        }
        let computer = try! executor.execute(ir: [.lsr16(c, a, b)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0b0000000100000000)
        XCTAssertEqual(computer.dataRAM.load16(from: b), 0)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0b0000000100000000)
    }
    
    func testNEG() {
        let a = 0x0104
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0b10101010, to: a)
        }
        let computer = try! executor.execute(ir: [.neg(c, a)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0b10101010)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0b01010101)
    }
    
    func testNEG16() {
        let a = 0x0104
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store16(value: 0b1010101010101010, to: a)
        }
        let computer = try! executor.execute(ir: [.neg16(c, a)])
        XCTAssertEqual(computer.dataRAM.load16(from: a), 0b1010101010101010)
        XCTAssertEqual(computer.dataRAM.load16(from: c), 0b0101010101010101)
    }
    
    func testNOT_false() {
        let a = 0x0104
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 0, to: a)
        }
        let computer = try! executor.execute(ir: [.not(c, a)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 0)
        XCTAssertEqual(computer.dataRAM.load(from: c), 1)
    }
    
    func testNOT_true() {
        let a = 0x0104
        let c = 0x010a
        let executor = CrackleExecutor()
        executor.configure = { (computer: Computer) in
            computer.dataRAM.store(value: 1, to: a)
        }
        let computer = try! executor.execute(ir: [.not(c, a)])
        XCTAssertEqual(computer.dataRAM.load(from: a), 1)
        XCTAssertEqual(computer.dataRAM.load(from: c), 0)
    }
}
