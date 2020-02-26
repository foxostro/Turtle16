//
//  InterpretingVMTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class InterpretingVMTests: XCTestCase {
    let isVerboseLogging = false
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    fileprivate func makeInstructionROM(program: String) -> InstructionROM {
        return InstructionROM().withStore(TraceUtils.assemble(program))
    }
    
    fileprivate func makeVM(program: String) -> InterpretingVM {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let vm = InterpretingVM(cpuState: CPUStateSnapshot(),
                                microcodeGenerator: microcodeGenerator,
                                peripherals: ComputerPeripherals(),
                                dataRAM: RAM(),
                                instructionROM: makeInstructionROM(program: program),
                                upperInstructionRAM: RAM(),
                                lowerInstructionRAM: RAM())
        vm.logger = makeLogger()
        return vm
    }
    
    func testExecuteProgram() {
        let vm = makeVM(program: "HLT")
        
        vm.runUntilHalted()
        
        XCTAssertEqual(vm.cpuState.pc.value, 4)
        XCTAssertEqual(vm.cpuState.controlWord.HLT, .active)
    }
    
    func testReset() {
        let vm = makeVM(program: "HLT")
        vm.runUntilHalted() // Run the program to cause a change in VM state.
        
        // Emulate a hardware reset.
        vm.reset()
        
        XCTAssertEqual(vm.cpuState.pc.value, 0)
        XCTAssertEqual(vm.cpuState.pc_if.value, 0)
        XCTAssertEqual(vm.cpuState.registerC.value, 0)
        XCTAssertEqual(vm.cpuState.controlWord.unsignedIntegerValue, ControlWord().unsignedIntegerValue)
    }
    
    func testExecuteFromInstructionRAM() {
        let vm = makeVM(program: """
LI X, 0x80
LI Y, 0x00
JMP
NOP
NOP
""")
        vm.upperInstructionRAM.store(value: 1, to: 0) // corresponds to 0x8000 in the address space
        vm.runUntilHalted() // Run the program to cause a change in VM state.
        
        XCTAssertEqual(vm.cpuState.pc.value, 0x8003)
        XCTAssertEqual(vm.cpuState.controlWord.HLT, .active)
    }
}
