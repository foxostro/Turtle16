//
//  TracingJitVMTests.swift
//  TurtleTTLTests
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import XCTest
import TurtleTTL

class TracingJitVMTests: XCTestCase {
    let isVerboseLogging = true
    
    fileprivate func makeLogger() -> Logger {
        return isVerboseLogging ? ConsoleLogger() : NullLogger()
    }
    
    fileprivate func makeVM(program: String) -> TracingJitVM {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        let vm = TracingJitVM(cpuState: CPUStateSnapshot(),
                              instructionDecoder: microcodeGenerator.microcode,
                              peripherals: ComputerPeripherals(),
                              dataRAM: RAM(),
                              instructionROM: VirtualMachineUtils.makeInstructionROM(program: program),
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
    
    func testExecuteFromInstructionRAM() {
        let vm = makeVM(program: """
LI X, 0x80
LI Y, 0x00
JMP
NOP
NOP
""")
        vm.upperInstructionRAM.store(value: 1, to: 0) // corresponds to 0x8000 in the address space
        vm.runUntilHalted()
        
        XCTAssertEqual(vm.cpuState.pc.value, 0x8003)
        XCTAssertEqual(vm.cpuState.controlWord.HLT, .active)
    }
    
    func testProfilerReportsInstructionIsNotHot() {
        let vm = makeVM(program: """
LI B, 1
ADD A
HLT
""")
        vm.runUntilHalted()
        
        XCTAssertFalse(vm.profiler.isHot(pc: 0x0001))
    }
    
    func testProfilerRecordsHotBackwardsJumps() {
        let vm = makeVM(program: """
LXY loop
LI B, 1
loop:
ADD A
NOP
JNC
NOP
NOP
HLT
""")
        vm.runUntilHalted()
        
        XCTAssertTrue(vm.profiler.isHot(pc: 0x0004))
    }
}
