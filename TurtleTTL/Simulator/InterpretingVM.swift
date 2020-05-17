//
//  InterpretingVM.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/25/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class InterpretingVM: VirtualMachine {
    let interpreter: Interpreter
    
    public init(cpuState: CPUStateSnapshot,
                microcodeGenerator: MicrocodeGenerator,
                peripherals: ComputerPeripherals,
                dataRAM: Memory,
                instructionMemory: InstructionMemory,
                flagBreak: AtomicBooleanFlag,
                interpreter: Interpreter) {
        self.interpreter = interpreter
        super.init(cpuState: cpuState,
                   microcodeGenerator: microcodeGenerator,
                   peripherals: peripherals,
                   dataRAM: dataRAM,
                   instructionMemory: instructionMemory,
                   flagBreak: flagBreak)
        self.interpreter.delegate = self
    }
    
    public override func singleStep() {
        logger?.append("\(String(describing: type(of: self))): singleStep")
        
        // TODO: Is it a problem to allocate a state object every tick?
        let prevState = cpuState.copy() as! CPUStateSnapshot
        
        if shouldRecordStatesOverTime && recordedStatesOverTime.isEmpty {
            recordedStatesOverTime.append(prevState.copy() as! CPUStateSnapshot)
        }
        
        interpreter.step()
        stopwatch?.retireInstructions(count: 1)
        
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
    
    public override func step() {
        singleStep()
    }
}
