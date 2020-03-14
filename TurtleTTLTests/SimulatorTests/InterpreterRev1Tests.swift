//
//  InterpreterTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InterpreterRev1Tests: XCTestCase {
    class TestInterpreterDelegate : NSObject, InterpreterDelegate {
        var storesToRAM: [(UInt8, Int)] = []
        var instructions: [Instruction]
        
        init(instructions: [Instruction]) {
            self.instructions = instructions
        }
        
        func storeToRAM(value: UInt8, at address: Int) {
            let theStore = (value, address)
            storesToRAM.append(theStore)
        }
        
        func loadFromRAM(at address: Int) -> UInt8 {
            return 42
        }
        
        func fetchInstruction(from: ProgramCounter) -> Instruction {
            if instructions.isEmpty {
                return Instruction.makeNOP()
            } else {
                return instructions.removeFirst()
            }
        }
    }
    
    fileprivate func assemble(_ text: String) -> [Instruction] {
        return try! tryAssemble(text)
    }

    fileprivate func tryAssemble(_ text: String) throws -> [Instruction] {
        let assembler = AssemblerFrontEnd()
        assembler.compile(text)
        if assembler.hasError {
            let error = assembler.makeOmnibusError(fileName: nil, errors: assembler.errors)
            throw error
        }
        return assembler.instructions
    }
    
    func testReset() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.pc = ProgramCounter(withValue: 1)
        interpreter.reset()
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
        XCTAssertEqual(interpreter.cpuState.pc_if.value, 0)
        XCTAssertEqual(interpreter.cpuState.registerC.value, 0)
        XCTAssertEqual(interpreter.cpuState.controlWord, ControlWord())
        XCTAssertEqual(interpreter.cpuState.uptime, 0)
    }
    
    func testInterpretNOP() {
        let expectedFinalState = ProcessorState()
        expectedFinalState.pc = ProgramCounter(withValue: 3)
        expectedFinalState.pc_if = ProgramCounter(withValue: 2)
        expectedFinalState.aluFlags = Flags(1, 0) // Changes every tick according to the values of A and B.
        expectedFinalState.uptime = 3
        
        let interpreter = makeInterpreter()
        let delegate = TestInterpreterDelegate(instructions: assemble("NOP"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState, expectedFinalState)
    }
    
    fileprivate func makeInterpreter(cpuState: ProcessorState = ProcessorState()) -> Interpreter {
        let interpreter = InterpreterRev1(cpuState: cpuState,
                                          peripherals: ComputerPeripherals(),
                                          dataRAM: Memory())
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        interpreter.instructionDecoder = microcodeGenerator.microcode
        
        interpreter.peripherals.peripherals = [MockComputerPeripheral(),
                                               MockComputerPeripheral(),
                                               MockComputerPeripheral(),
                                               MockComputerPeripheral(),
                                               MockComputerPeripheral(),
                                               MockComputerPeripheral()]
        
        return interpreter
    }
    
    class MockComputerPeripheral: ComputerPeripheral {
        public var storesToPeripheral: [UInt8] = []
        public var loadsFromPeripheral: [UInt8] = []
        
        public init() {
            super.init(name: "Mock")
        }
        
        public override func onRegisterClock() {
            if (PI == .active) {
                storesToPeripheral.append(bus.value)
            }
        }
        
        public override func onControlClock() {
            if (PO == .active) {
                bus = Register(withValue: loadsFromPeripheral.removeFirst())
            }
        }
    }
    
    func testInterpretHLT_EnsureThreeClockPipelineLatency() {
        // The pipeline takes three clocks to execute an instruction.
        let interpreter = makeInterpreter()
        let delegate = TestInterpreterDelegate(instructions: assemble("HLT"))
        interpreter.delegate = delegate
        
        interpreter.step()
        XCTAssertEqual(.inactive, interpreter.cpuState.controlWord.HLT)
        XCTAssertEqual(1, interpreter.cpuState.pc.value)
        
        interpreter.step()
        XCTAssertEqual(.inactive, interpreter.cpuState.controlWord.HLT)
        XCTAssertEqual(2, interpreter.cpuState.pc.value)
        
        interpreter.step()
        XCTAssertEqual(.active, interpreter.cpuState.controlWord.HLT)
        XCTAssertEqual(3, interpreter.cpuState.pc.value)
    }
    
    func testInstructionImmediateValueGoesToRegisterC() {
        // The instruction immediate value ends up in register C when the
        // instruction executes.
        let interpreter = makeInterpreter()
        let delegate = TestInterpreterDelegate(instructions: assemble("LI A, 42"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.registerC.value, 42)
    }
    
    func testJMP() {
        // Jump sets the program counter to the value of the XY register.
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerX = Register(withValue: 0xff)
        interpreter.cpuState.registerY = Register(withValue: 0xff)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("JMP"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0xffff)
    }
    
    func testJC() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 255)
        interpreter.cpuState.registerB = Register(withValue: 1)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
ADD D
NOP
JC
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testJNC() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 254)
        interpreter.cpuState.registerB = Register(withValue: 1)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
ADD D
NOP
JNC
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testJE() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 42)
        interpreter.cpuState.registerB = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
CMP
NOP
JE
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testJNE() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 42)
        interpreter.cpuState.registerB = Register(withValue: 0)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
CMP
NOP
JNE
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testJG() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 42)
        interpreter.cpuState.registerB = Register(withValue: 0)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
CMP
NOP
JG
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testJLE() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 42)
        interpreter.cpuState.registerB = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
CMP
NOP
JLE
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testJL() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 41)
        interpreter.cpuState.registerB = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
CMP
NOP
JL
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testJGE() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 42)
        interpreter.cpuState.registerB = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
CMP
NOP
JGE
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0)
    }
    
    func testINUV() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerU = Register(withValue: 0)
        interpreter.cpuState.registerV = Register(withValue: 0)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("INUV"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.registerU.value, 0)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 1)
    }
    
    func testINUV_WithOverflow() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerU = Register(withValue: 0xfe)
        interpreter.cpuState.registerV = Register(withValue: 0xff)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("INUV"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.registerU.value, 0xff)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 0x00)
    }
    
    func testINXY() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerX = Register(withValue: 0)
        interpreter.cpuState.registerY = Register(withValue: 0)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("INXY"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.registerX.value, 0)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 1)
    }
    
    func testINXY_WithOverflow() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerX = Register(withValue: 0xfe)
        interpreter.cpuState.registerY = Register(withValue: 0xff)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("INXY"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.registerX.value, 0xff)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 0x00)
    }
    
    func testLinkLoOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerH = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV A, H
MOV B, H
MOV D, H
MOV X, H
MOV Y, H
MOV U, H
MOV V, H
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testLinkHiOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerG = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV A, G
MOV B, G
MOV D, G
MOV X, G
MOV Y, G
MOV U, G
MOV V, G
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testBOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerB = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV A, B
MOV D, B
MOV X, B
MOV Y, B
MOV U, B
MOV V, B
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testAOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV B, A
MOV D, A
MOV X, A
MOV Y, A
MOV U, A
MOV V, A
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testUOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerU = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV A, U
MOV B, U
MOV D, U
MOV X, U
MOV Y, U
MOV V, U
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testVOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerV = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV A, V
MOV B, V
MOV D, V
MOV X, V
MOV Y, V
MOV U, V
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
    }
    
    func testXOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerX = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV A, X
MOV B, X
MOV D, X
MOV Y, X
MOV U, X
MOV V, X
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testYOut() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerY = Register(withValue: 42)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
MOV A, Y
MOV B, Y
MOV D, Y
MOV X, Y
MOV U, Y
MOV V, Y
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testLI() {
        let interpreter = makeInterpreter()
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
LI A, 42
LI B, 42
LI D, 42
LI X, 42
LI Y, 42
LI U, 42
LI V, 42
"""))
        interpreter.delegate = delegate
        
        for _ in 1...9 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerX.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerY.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerU.value, 42)
        XCTAssertEqual(interpreter.cpuState.registerV.value, 42)
    }
    
    func testLINK() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerG = Register(withValue: 0xff)
        interpreter.cpuState.registerH = Register(withValue: 0xff)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
NOP
LINK
"""))
        interpreter.delegate = delegate
        
        for _ in 1...4 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerG.value, 0)
        XCTAssertEqual(interpreter.cpuState.registerH.value, 4)
    }
    
    func testJALR() {
        // Jump sets the program counter to the value of the XY register.
        // Simultaneously sets the LINK register.
        // Unfortunately, due to a hardware bug, the link register always picks
        // up the new value of PC and not the intended return address.
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerX = Register(withValue: 0xff)
        interpreter.cpuState.registerY = Register(withValue: 0xff)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("JALR"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0xffff)
        XCTAssertEqual(interpreter.cpuState.registerG.value, 0xff)
        XCTAssertEqual(interpreter.cpuState.registerH.value, 0xff)
    }
    
    func testStoreToRAM() {
        let interpreter = makeInterpreter()
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
LI U, 0xff
LI V, 0xff
LI M, 42
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.dataRAM.load(from: 0xffff), 42)
    }
    
    func testLoadFromRAM() {
        let interpreter = makeInterpreter()
        interpreter.dataRAM.store(value: 42, to: 0x0000)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
LI U, 0
LI V, 0
MOV A, M
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
    }
    
    func testStoreToPeripheral() {
        let interpreter = makeInterpreter()
        let peripheral = interpreter.peripherals.peripherals[0] as! MockComputerPeripheral
        let delegate = TestInterpreterDelegate(instructions: assemble("""
LI X, 0xff
LI Y, 0xff
LI P, 13
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(peripheral.storesToPeripheral, [13])
        XCTAssertEqual(interpreter.peripherals.uptime, interpreter.cpuState.uptime)
    }
    
    func testLoadFromPeripheral() {
        let interpreter = makeInterpreter()
        let peripheral = interpreter.peripherals.peripherals[0] as! MockComputerPeripheral
        peripheral.loadsFromPeripheral = [42]
        let delegate = TestInterpreterDelegate(instructions: assemble("""
LI X, 0xff
LI Y, 0xff
MOV A, P
"""))
        interpreter.delegate = delegate
        
        for _ in 1...5 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 42)
        XCTAssertEqual(interpreter.peripherals.uptime, interpreter.cpuState.uptime)
    }
    
    func testADD() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 0xff)
        interpreter.cpuState.registerB = Register(withValue: 1)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("ADD D"))
        interpreter.delegate = delegate
        
        for _ in 1...3 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerD.value, 0)
        XCTAssertEqual(interpreter.cpuState.flags.carryFlag, 0)
        XCTAssertEqual(interpreter.cpuState.flags.equalFlag, 0)
    }
    
    func testCMP() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerA = Register(withValue: 1)
        interpreter.cpuState.registerB = Register(withValue: 0)
        
        let delegate = TestInterpreterDelegate(instructions: assemble("CMP"))
        interpreter.delegate = delegate
        
        for _ in 1...3 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerD.value, 0)
        XCTAssertEqual(interpreter.cpuState.flags.carryFlag, 0)
        XCTAssertEqual(interpreter.cpuState.flags.equalFlag, 0)
    }
    
    func testBasicAddition() {
        let interpreter = makeInterpreter()
        
        let delegate = TestInterpreterDelegate(instructions: assemble("""
LI A, 1
LI B, 2
ADD D
HLT
"""))
        interpreter.delegate = delegate
        
        for _ in 1...6 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerA.value, 1)
        XCTAssertEqual(interpreter.cpuState.registerB.value, 2)
        XCTAssertEqual(interpreter.cpuState.registerD.value, 3)
        XCTAssertEqual(interpreter.cpuState.controlWord.HLT, .active)
    }
}
