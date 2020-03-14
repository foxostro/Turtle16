//
//  ComputerVirtualMachineFactory.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 3/13/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

final class ComputerVirtualMachineFactory: NSObject {
    var cpuState: CPUStateSnapshot! = nil
    var microcodeGenerator: MicrocodeGenerator! = nil
    var peripherals: ComputerPeripherals! = nil
    var dataRAM: Memory! = nil
    var instructionMemory: InstructionMemory! = nil
    var flagBreak: AtomicBooleanFlag! = nil
    var allowsRunningTraces: Bool! = nil
    var shouldRecordStatesOverTime: Bool! = nil
    var stopwatch: ComputerStopwatch? = nil
    var logger: Logger? = nil
    var interpreter: Interpreter! = nil
    
    let kVirtualMachineTypeString = "VirtualMachineType"
    let kDefaultString = "Default"
    let kInterpreterString = "Interpreter"
    let kTracingString = "Tracing"
    
    enum VirtualMachineType {
        case Interpreter, Tracing
    }
    
    let defaultVirtualMachineType: VirtualMachineType = .Interpreter
    
    fileprivate func determineDesiredVirtualMachineTypeString() -> String {
        return UserDefaults.standard.string(forKey: kVirtualMachineTypeString) ?? kDefaultString
    }
    
    fileprivate func convertToVirtualMachineType(string: String) -> VirtualMachineType {
        if string == kInterpreterString {
            return .Interpreter
        } else if string == kTracingString {
            return .Tracing
        } else if string == kDefaultString {
            return defaultVirtualMachineType
        } else {
            return defaultVirtualMachineType
        }
    }
    
    func makeVirtualMachine() -> VirtualMachine {
        let type = convertToVirtualMachineType(string: determineDesiredVirtualMachineTypeString())
        switch type {
        case .Tracing:
            return makeTracingVirtualMachine()
        case .Interpreter:
            return makeBasicInterpretingVirtualMachine()
        }
    }
    
    func makeBasicInterpretingVirtualMachine() -> VirtualMachine {
        let vm = InterpretingVM(cpuState: cpuState,
                                microcodeGenerator: microcodeGenerator,
                                peripherals: peripherals,
                                dataRAM: dataRAM,
                                instructionMemory: instructionMemory,
                                flagBreak: flagBreak,
                                interpreter: interpreter)
        vm.shouldRecordStatesOverTime = shouldRecordStatesOverTime
        vm.logger = logger
        vm.stopwatch = stopwatch
        return vm
    }
    
    func makeTracingVirtualMachine() -> VirtualMachine {
        let vm = TracingInterpretingVM(cpuState: cpuState,
                                       microcodeGenerator: microcodeGenerator,
                                       peripherals: peripherals,
                                       dataRAM: dataRAM,
                                       instructionMemory: instructionMemory,
                                       flagBreak: flagBreak,
                                       interpreter: interpreter)
        vm.allowsRunningTraces = allowsRunningTraces
        vm.shouldRecordStatesOverTime = shouldRecordStatesOverTime
        vm.logger = logger
        vm.stopwatch = stopwatch
        return vm
    }
}
