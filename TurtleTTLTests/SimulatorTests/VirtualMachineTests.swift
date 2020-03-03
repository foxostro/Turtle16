//
//  VirtualMachineTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class VirtualMachineTests: XCTestCase {
    let isVerboseLogging = false
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    fileprivate func makeVM(program: String = "") -> VirtualMachine {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let vm = VirtualMachine(cpuState: CPUStateSnapshot(),
                                microcodeGenerator: microcodeGenerator,
                                peripherals: ComputerPeripherals(),
                                dataRAM: Memory(),
                                instructionMemory: VirtualMachineUtils.makeInstructionROM(program: program))
        vm.logger = makeLogger()
        return vm
    }
    
    func testReset() {
        let vm = makeVM()
        vm.cpuState.pc = ProgramCounter(withValue: 0xffff)
        vm.cpuState.pc_if = ProgramCounter(withValue: 0xffff)
        vm.cpuState.registerC = Register(withValue: 0xff)
        vm.cpuState.controlWord = ControlWord().withHLT(.active)
        
        // Emulate a hardware reset.
        vm.reset()
        
        XCTAssertEqual(vm.cpuState.pc.value, 0)
        XCTAssertEqual(vm.cpuState.pc_if.value, 0)
        XCTAssertEqual(vm.cpuState.registerC.value, 0)
        XCTAssertEqual(vm.cpuState.controlWord.unsignedIntegerValue, ControlWord().unsignedIntegerValue)
        XCTAssertEqual(vm.cpuState.uptime, 0)
    }
    
    func testFetchFromInstructionROM() {
        let vm = makeVM(program: "HLT")
        
        let instruction = vm.fetchInstruction(from: ProgramCounter(withValue: 1))
        
        XCTAssertEqual(instruction.disassembly, "HLT")
        XCTAssertEqual(instruction.opcode, 1)
        XCTAssertEqual(instruction.immediate, 0)
        XCTAssertEqual(instruction.pc, ProgramCounter(withValue: 0x0001))
    }
    
    func testFetchFromInstructionRAM() {
        let vm = makeVM()
        vm.instructionMemory.store(value: 0x0100, to: 0x8000) // HLT
        
        let instruction = vm.fetchInstruction(from: ProgramCounter(withValue: 0x8000))
        
        XCTAssertEqual(instruction.disassembly, "HLT")
        XCTAssertEqual(instruction.opcode, 1)
        XCTAssertEqual(instruction.immediate, 0)
        XCTAssertEqual(instruction.pc, ProgramCounter(withValue: 0x8000))
    }
}
