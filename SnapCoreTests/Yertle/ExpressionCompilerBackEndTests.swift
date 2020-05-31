//
//  ExpressionCompilerBackEndTests.swift
//  SnapCoreTests
//
//  Created by Andrew Fox on 5/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import SnapCore
import TurtleSimulatorCore
import TurtleCompilerToolbox
import TurtleCore

// Simulates execution of a program written in the Yertle intermediate language.
class YertleExecutor: NSObject {
    let isVerboseLogging = false
    let microcodeGenerator: MicrocodeGenerator
    let assembler: AssemblerBackEnd
    var configure: (Computer)->Void = {_ in}
    
    override init() {
        microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        assembler = AssemblerBackEnd(microcodeGenerator: microcodeGenerator)
    }
    
    func execute(ir: [YertleInstruction]) throws -> Computer {
        assembler.begin()
        try assembler.li(.U, Int((SnapCodeGenerator.kStackPointerAddressHi & 0xff00) >> 8))
        try assembler.li(.V, Int((SnapCodeGenerator.kStackPointerAddressHi & 0x00ff)))
        try assembler.li(.M, Int((SnapCodeGenerator.kStackPointerInitialValue & 0xff00) >> 8))
        try assembler.li(.U, Int((SnapCodeGenerator.kStackPointerAddressLo & 0xff00) >> 8))
        try assembler.li(.V, Int((SnapCodeGenerator.kStackPointerAddressLo & 0x00ff)))
        try assembler.li(.M, Int((SnapCodeGenerator.kStackPointerInitialValue & 0x00ff)))
        let compiler = ExpressionCompilerBackEnd(assembler: assembler)
        try compiler.compile(ir: ir)
        assembler.hlt()
        assembler.end()
        let computer = execute(instructions: assembler.instructions)
        return computer
    }
    
    func execute(instructions: [Instruction]) -> Computer {
        let computer = makeComputer(microcodeGenerator: microcodeGenerator)
        computer.provideInstructions(instructions)
        configure(computer)
        XCTAssertNoThrow(try computer.runUntilHalted())
        return computer
    }
    
    func makeComputer(microcodeGenerator: MicrocodeGenerator) -> Computer {
        let computer = Computer()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.logger = makeLogger()
        return computer
    }
    
    func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
}

extension Computer {
    public var stackPointer: Int {
        let stackPointerHi = Int(dataRAM.load(from: Int(SnapCodeGenerator.kStackPointerAddressHi)))
        let stackPointerLo = Int(dataRAM.load(from: Int(SnapCodeGenerator.kStackPointerAddressLo)))
        let stackPointer = (stackPointerHi << 8) + stackPointerLo
        return stackPointer
    }
    
    public var stackTop: UInt8 {
        return dataRAM.load(from: stackPointer)
    }
}

class ExpressionCompilerBackEndTests: XCTestCase {
    func execute(ir: [YertleInstruction]) throws -> Computer {
        let executor = YertleExecutor()
        let computer = try executor.execute(ir: ir)
        return computer
    }
    
    func testEmptyProgram() {
        let computer = try! execute(ir: [])
        XCTAssertEqual(computer.stackPointer, SnapCodeGenerator.kStackPointerInitialValue)
        XCTAssertEqual(computer.cpuState.registerA.value, 0) // initial value
    }
    
    func testPushOneValue() {
        let computer1 = try! execute(ir: [.push(1)])
        XCTAssertEqual(computer1.cpuState.registerA.value, 1)
        
        let computer2 = try! execute(ir: [.push(2)])
        XCTAssertEqual(computer2.cpuState.registerA.value, 2)
    }
    
    func testPushTwoValues() {
        let computer = try! execute(ir: [.push(1), .push(2)])
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
        XCTAssertEqual(computer.cpuState.registerB.value, 1)
    }
    
    func testPushThreeValues() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3)])
        XCTAssertEqual(computer.cpuState.registerA.value, 3)
        XCTAssertEqual(computer.cpuState.registerB.value, 2)
        XCTAssertEqual(computer.stackPointer, 0xffff)
        let topOfMemoryStack = computer.dataRAM.load(from: 0xffff)
        XCTAssertEqual(topOfMemoryStack, 1)
    }
    
    func testPushFourValues() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4)])
        XCTAssertEqual(computer.cpuState.registerA.value, 4)
        XCTAssertEqual(computer.cpuState.registerB.value, 3)
        XCTAssertEqual(computer.stackPointer, 0xfffe)
        let memoryStack0 = computer.dataRAM.load(from: 0xfffe)
        let memoryStack1 = computer.dataRAM.load(from: 0xffff)
        XCTAssertEqual(memoryStack0, 2)
        XCTAssertEqual(memoryStack1, 1)
    }
    
    // Push values until just before the point where the stack pointer
    func testPushUntilJustBeforeStackPointerLowerByteOverflows() {
        pushMany(count: 257)
    }
    
    // Push enough values onto the stack to change the stack pointer high byte.
    func testPushUntilStackPointerHighByteChanges() {
        pushMany(count: 1024)
    }
    
    func pushMany(count: Int) {
        var ir: [YertleInstruction] = []
        for _ in 0...count {
            ir.append(.push(255))
        }
        let computer = try! execute(ir: ir)
        XCTAssertEqual(Int(computer.cpuState.registerA.value), 255)
        XCTAssertEqual(Int(computer.cpuState.registerB.value), 255)
        for i in 2...count {
            XCTAssertEqual(Int(computer.dataRAM.load(from: Int(UInt16(SnapCodeGenerator.kStackPointerInitialValue) &- UInt16(count - i + 1)))), 255)
        }
        XCTAssertEqual(computer.stackPointer, Int(UInt16(SnapCodeGenerator.kStackPointerInitialValue) &- UInt16(count - 1)))
    }
    
    func testPopWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.pop])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: cannot pop when stack is empty")
        }
    }
    
    func testPopWithStackDepthOneAndStackPointerDoesNotChange() {
        // The top two stack slots are in registers A and B.
        let computer = try! execute(ir: [.push(1), .pop])
        XCTAssertEqual(computer.stackPointer, SnapCodeGenerator.kStackPointerInitialValue)
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
        XCTAssertEqual(computer.cpuState.registerB.value, 0)
    }
    
    func testPopWithStackDepthTwoAndStackPointerDoesNotChange() {
        // The top two stack slots are in registers A and B.
        let computer = try! execute(ir: [.push(1), .push(2), .pop])
        XCTAssertEqual(computer.stackPointer, SnapCodeGenerator.kStackPointerInitialValue)
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
        XCTAssertEqual(computer.cpuState.registerB.value, 0)
    }
    
    func testPopWithStackDepthThreeAndStackPointerDoesNotChange() {
        // The third stack slot is in memory at 0xffff. When we pop that, the
        // stack pointer returns to the initial value.
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .pop])
        XCTAssertEqual(computer.stackPointer, SnapCodeGenerator.kStackPointerInitialValue)
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
        XCTAssertEqual(computer.cpuState.registerB.value, 1)
    }
    
    func testPopWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .pop])
        XCTAssertEqual(computer.cpuState.registerA.value, 3)
        XCTAssertEqual(computer.cpuState.registerB.value, 2)
        XCTAssertEqual(computer.stackTop, 1)
        XCTAssertEqual(UInt16(computer.stackPointer), UInt16(SnapCodeGenerator.kStackPointerInitialValue) &- 1)
    }
    
    func testPopWithStackDepthFive() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .push(5), .pop])
        XCTAssertEqual(computer.cpuState.registerA.value, 4)
        XCTAssertEqual(computer.cpuState.registerB.value, 3)
        XCTAssertEqual(computer.dataRAM.load(from: 0xfffe), 2)
        XCTAssertEqual(computer.dataRAM.load(from: 0xffff), 1)
        XCTAssertEqual(computer.stackTop, 2)
        XCTAssertEqual(computer.stackPointer, 0xfffe)
    }
    
    func testEqWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.eq])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during EQ")
        }
    }
    
    func testEqWithStackDepthOne() {
        XCTAssertThrowsError(try execute(ir: [.push(1), .eq])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during EQ")
        }
    }
    
    func testEqWithStackDepthTwo() {
        let computer = try! execute(ir: [.push(1), .push(2), .eq])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testEqWithStackDepthThree() {
        let computer = try! execute(ir: [.push(1), .push(42), .push(42), .eq])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
        XCTAssertEqual(computer.cpuState.registerB.value, 1)
    }
    
    func testEqWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .eq])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
        XCTAssertEqual(computer.cpuState.registerB.value, 2)
        XCTAssertEqual(computer.stackTop, 1)
    }
    
    func testLtWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.lt])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during LT")
        }
    }
    
    func testLtWithStackDepthOne() {
        XCTAssertThrowsError(try execute(ir: [.push(1), .lt])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during LT")
        }
    }
    
    func testLtWithStackDepthTwo() {
        let computer = try! execute(ir: [.push(1), .push(2), .lt])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testLtWithStackDepthThree() {
        let computer = try! execute(ir: [.push(1), .push(42), .push(2), .lt])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
        XCTAssertEqual(computer.cpuState.registerB.value, 1)
    }
    
    func testLtWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .lt])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
        XCTAssertEqual(computer.cpuState.registerB.value, 2)
        XCTAssertEqual(computer.stackTop, 1)
    }
    
    func testAddWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.add])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during ADD")
        }
    }
    
    func testAddWithStackDepthOne() {
        XCTAssertThrowsError(try execute(ir: [.push(1), .add])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during ADD")
        }
    }
    
    func testAddWithStackDepthTwo() {
        let computer = try! execute(ir: [.push(1), .push(2), .add])
        XCTAssertEqual(computer.cpuState.registerA.value, 3)
    }
    
    func testAddWithStackDepthThree() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .add])
        XCTAssertEqual(computer.cpuState.registerA.value, 5)
        XCTAssertEqual(computer.cpuState.registerB.value, 1)
    }
    
    func testAddWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .add])
        XCTAssertEqual(computer.cpuState.registerA.value, 7)
        XCTAssertEqual(computer.cpuState.registerB.value, 2)
        XCTAssertEqual(computer.stackTop, 1)
    }
    
    func testSubWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.sub])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during SUB")
        }
    }
    
    func testSubWithStackDepthOne() {
        XCTAssertThrowsError(try execute(ir: [.push(1), .sub])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during SUB")
        }
    }
    
    func testSubWithStackDepthTwo() {
        let computer = try! execute(ir: [.push(1), .push(2), .sub])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
    }
    
    func testSubWithStackDepthThree() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .sub])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
        XCTAssertEqual(computer.cpuState.registerB.value, 1)
    }
    
    func testSubWithStackDepthFour() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .push(4), .sub])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
        XCTAssertEqual(computer.cpuState.registerB.value, 2)
        XCTAssertEqual(computer.stackTop, 1)
    }
    
    func testSubTwice() {
        let computer = try! execute(ir: [.push(1), .push(2), .push(3), .sub, .sub])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testMulWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.mul])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during MUL")
        }
    }
    
    func testMulWithStackDepthOne() {
        XCTAssertThrowsError(try execute(ir: [.mul])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during MUL")
        }
    }
    
    func testMul_0x0() {
        let computer = try! execute(ir: [.push(0), .push(0), .mul])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testMul_1x0() {
        let computer = try! execute(ir: [.push(1), .push(0), .mul])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testMul_1x1() {
        let computer = try! execute(ir: [.push(1), .push(1), .mul])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
    }
    
    func testMul_4x3() {
        let computer = try! execute(ir: [.push(4), .push(3), .mul])
        XCTAssertEqual(computer.cpuState.registerA.value, 12)
    }
    
    func testMul_255x2() {
        // Multiplication is basically modulo 255.
        let computer = try! execute(ir: [.push(255), .push(2), .mul])
        XCTAssertEqual(computer.cpuState.registerA.value, 254)
    }
    
    func testMul_PopsTheStackToo() {
        let computer = try! execute(ir: [.push(255), .push(254), .push(2), .push(2), .mul])
        XCTAssertEqual(computer.cpuState.registerA.value, 4)
        XCTAssertEqual(computer.cpuState.registerB.value, 254)
        XCTAssertEqual(computer.stackTop, 255)
    }
    
    func testDivWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.div])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during DIV")
        }
    }
    
    func testDivWithStackDepthOne() {
        XCTAssertThrowsError(try execute(ir: [.div])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during DIV")
        }
    }
    
    func testDiv_1div0() {
        // There's a check in the DIV command to ensure that all division by
        // zero yields a result of zero.
        let computer = try! execute(ir: [.push(1), .push(0), .div])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testDiv_0div1() {
        let computer = try! execute(ir: [.push(1), .push(0), .div])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testDiv_2div1() {
        let computer = try! execute(ir: [.push(1), .push(2), .div])
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
    }
    
    func testDiv_4div2() {
        let computer = try! execute(ir: [.push(2), .push(4), .div])
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
    }
    
    func testDiv_3div4() {
        let computer = try! execute(ir: [.push(4), .push(3), .div])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testDiv_PopsTheStackToo() {
        let computer = try! execute(ir: [.push(255), .push(254), .push(2), .push(2), .div])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
        XCTAssertEqual(computer.cpuState.registerB.value, 254)
        XCTAssertEqual(computer.stackTop, 255)
    }
    
    func testModWithStackDepthOne() {
        XCTAssertThrowsError(try execute(ir: [.mod])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during MOD")
        }
    }
    
    func testMod_1mod0() {
        // There's a check in the MOD command to ensure that all division by
        // zero yields a result of zero.
        let computer = try! execute(ir: [.push(1), .push(0), .mod])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
    }
    
    func testMod_1mod1() {
        let computer = try! execute(ir: [.push(255), .push(1), .push(1), .mod])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
        XCTAssertEqual(computer.cpuState.registerB.value, 255)
        XCTAssertEqual(computer.stackPointer, 0x0000)
    }
    
    func testMod_modulus_pops_the_stack() {
        let computer = try! execute(ir: [.push(255), .push(1), .push(1), .mod])
        XCTAssertEqual(computer.cpuState.registerA.value, 0)
        XCTAssertEqual(computer.cpuState.registerB.value, 255)
        XCTAssertEqual(computer.stackPointer, 0x0000)
    }
    
    func testMod_1mod2() {
        let computer = try! execute(ir: [.push(2), .push(1), .mod])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
    }
    
    func testMod_7mod4() {
        let computer = try! execute(ir: [.push(4), .push(7), .mod])
        XCTAssertEqual(computer.cpuState.registerA.value, 3)
    }
    
    func testMod_PopsTheStackToo() {
        let computer = try! execute(ir: [.push(255), .push(254), .push(2), .push(3), .mod])
        XCTAssertEqual(computer.cpuState.registerA.value, 1)
        XCTAssertEqual(computer.cpuState.registerB.value, 254)
        XCTAssertEqual(computer.stackTop, 255)
    }
    
    func testLoadWithEmptyStack() {
        let value: UInt8 = 0xab
        let address = 0x0010
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: value, to: address)
        }
        let computer = try! executor.execute(ir: [.load(address)])
        XCTAssertEqual(computer.cpuState.registerA.value, value)
    }
    
    func testLoadWithStackDepthOne() {
        let value: UInt8 = 0xab
        let address = 0x0010
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: value, to: address)
        }
        let computer = try! executor.execute(ir: [.push(1), .load(address)])
        XCTAssertEqual(computer.cpuState.registerA.value, value)
        XCTAssertEqual(computer.cpuState.registerB.value, 1)
    }
    
    func testLoadWithStackDepthTwo() {
        let value: UInt8 = 0xab
        let address = 0x0010
        let executor = YertleExecutor()
        executor.configure = {computer in
            computer.dataRAM.store(value: value, to: address)
        }
        let computer = try! executor.execute(ir: [.push(1), .push(2), .load(address)])
        XCTAssertEqual(computer.cpuState.registerA.value, value)
        XCTAssertEqual(computer.cpuState.registerB.value, 2)
        XCTAssertEqual(computer.stackPointer, 0xffff)
        XCTAssertEqual(computer.stackTop, 1)
    }
    
    func testStoreWithEmptyStack() {
        XCTAssertThrowsError(try execute(ir: [.store(0)])) {
            XCTAssertEqual(($0 as? CompilerError)?.message,
                           "ExpressionCompilerBackEnd: stack underflow during STORE")
        }
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
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
    }
    
    func testStoreWithStackDepthThree() {
        let address = 0x0010
        let computer = try! execute(ir: [.push(3), .push(2), .push(1), .store(address)])
        XCTAssertEqual(computer.dataRAM.load(from: address), 1)
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
        XCTAssertEqual(computer.cpuState.registerB.value, 3)
    }
    
    func testStoreWithStackDepthFour() {
        let address = 0x0010
        let computer = try! execute(ir: [.push(4), .push(3), .push(2), .push(1), .store(address)])
        XCTAssertEqual(computer.dataRAM.load(from: address), 1)
        XCTAssertEqual(computer.cpuState.registerA.value, 2)
        XCTAssertEqual(computer.cpuState.registerB.value, 3)
        XCTAssertEqual(computer.stackPointer, 0xffff)
        XCTAssertEqual(computer.stackTop, 4)
    }
}
