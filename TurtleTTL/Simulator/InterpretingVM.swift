//
//  InterpretingVM.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation

public class InterpretingVM: VirtualMachine {
    let interpreter: Interpreter
    
    public override init(cpuState: CPUStateSnapshot,
                         microcodeGenerator: MicrocodeGenerator,
                         peripherals: ComputerPeripherals,
                         dataRAM: Memory,
                         instructionMemory: InstructionMemory,
                         flagBreak: AtomicBooleanFlag = AtomicBooleanFlag()) {
        interpreter = Interpreter(cpuState: cpuState,
                                  peripherals: peripherals,
                                  dataRAM: dataRAM,
                                  instructionDecoder: microcodeGenerator.microcode)
        super.init(cpuState: cpuState,
                   microcodeGenerator: microcodeGenerator,
                   peripherals: peripherals,
                   dataRAM: dataRAM,
                   instructionMemory: instructionMemory,
                   flagBreak: flagBreak)
        interpreter.delegate = self
    }
    
    public override func step() {
        logger?.append("\(String(describing: type(of: self))): step")
        
        // TODO: Is it a problem to allocate a state object every tick?
        let prevState = cpuState.copy() as! CPUStateSnapshot
        
        if shouldRecordStatesOverTime && recordedStatesOverTime.isEmpty {
            recordedStatesOverTime.append(prevState.copy() as! CPUStateSnapshot)
        }
        
        interpreter.step()
        
        if shouldRecordStatesOverTime {
            recordedStatesOverTime.append(cpuState.copy() as! CPUStateSnapshot)
        }
        
        if let logger = logger {
            CPUStateSnapshot.logChanges(logger: logger,
                                        prevState: prevState,
                                        nextState: cpuState)
            logger.append("-----")
        }
    }
}
