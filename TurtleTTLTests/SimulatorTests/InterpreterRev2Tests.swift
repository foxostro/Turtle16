//
//  InterpreterRev2Tests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InterpreterRev2Tests: XCTestCase {
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
    
    fileprivate func makeInterpreter(cpuState: ProcessorState = ProcessorState()) -> Interpreter {
        let interpreter = InterpreterRev2(cpuState: cpuState,
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
    
    func testLINK() {
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerG = Register(withValue: 0xff)
        interpreter.cpuState.registerH = Register(withValue: 0xff)
        
        let delegate = TestInterpreterDelegate(instructions: TraceUtils.assemble("""
NOP
LINK
"""))
        interpreter.delegate = delegate
        
        for _ in 1...4 { interpreter.step() }
        
        XCTAssertEqual(interpreter.cpuState.registerG.value, 0)
        XCTAssertEqual(interpreter.cpuState.registerH.value, 3)
    }
    
    func testJALR() {
        // Jump sets the program counter to the value of the XY register.
        // Simultaneously sets the LINK register to the return address.
        let interpreter = makeInterpreter()
        interpreter.cpuState.registerX = Register(withValue: 0xff)
        interpreter.cpuState.registerY = Register(withValue: 0xff)
        
        let delegate = TestInterpreterDelegate(instructions: TraceUtils.assemble("JALR"))
        interpreter.delegate = delegate
        
        interpreter.step()
        interpreter.step()
        interpreter.step()
        
        XCTAssertEqual(interpreter.cpuState.pc.value, 0xffff)
        XCTAssertEqual(interpreter.cpuState.registerG.value, 0x00)
        XCTAssertEqual(interpreter.cpuState.registerH.value, 0x02)
    }
}
