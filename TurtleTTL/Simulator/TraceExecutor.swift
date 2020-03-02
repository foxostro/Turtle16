//
//  TraceExecutor.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/24/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class TraceExecutor: NSObject, InterpreterDelegate {
    public let cpuState: CPUStateSnapshot
    public let trace: Trace
    public var logger: Logger? = nil
    public var delegate: InterpreterDelegate? = nil
    public var shouldRecordStatesOverTime = false
    public var recordedStatesOverTime: [CPUStateSnapshot] = []
    public let flagBreak: AtomicBooleanFlag
    let interpreter: Interpreter
    var instructions: [Instruction] = []
    
    public convenience init(trace: Trace, cpuState: CPUStateSnapshot) {
        self.init(trace: trace,
                  cpuState: cpuState,
                  peripherals: ComputerPeripherals(),
                  dataRAM: Memory())
    }
    
    public convenience init(trace: Trace,
                            cpuState: CPUStateSnapshot,
                            peripherals: ComputerPeripherals,
                            dataRAM: Memory) {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        self.init(trace: trace,
                  cpuState: cpuState,
                  peripherals: peripherals,
                  dataRAM: dataRAM,
                  instructionDecoder: microcodeGenerator.microcode)
    }
    
    public init(trace: Trace,
                cpuState: CPUStateSnapshot,
                peripherals: ComputerPeripherals,
                dataRAM: Memory,
                instructionDecoder: InstructionDecoder,
                flagBreak: AtomicBooleanFlag = AtomicBooleanFlag()) {
        self.cpuState = cpuState
        self.trace = trace
        self.flagBreak = flagBreak
        
        interpreter = Interpreter(cpuState: cpuState,
                                  peripherals: peripherals,
                                  dataRAM: dataRAM,
                                  instructionDecoder: instructionDecoder)
        
        super.init()
        
        interpreter.delegate = self
    }
    
    public func run() {
        try! run(maxSteps: Int.max)
    }
    
    public func run(maxSteps: Int) throws {
        if self.trace.instructions.isEmpty {
            return
        }
        
        // Flush the pipeline so we begin executing the trace immediately.
        cpuState.if_id = fetchInstruction(from: trace.pc!)
        cpuState.pc = trace.pc!.increment().increment()
        cpuState.pc_if = trace.pc!.increment()
        cpuState.registerC = Register(withValue: cpuState.if_id.immediate)
        
        var stepCount = 0
        
        while cpuState.controlWord.HLT == .inactive {
            if stepCount >= maxSteps {
                throw VirtualMachineError("Exceeded maximum number of step: stepCount=\(stepCount) ; maxSteps=\(maxSteps)")
            }
            
            let prevState = cpuState.copy() as! CPUStateSnapshot
            let upcomingInstruction = prevState.if_id
            
            logger?.append("upcomingInstruction: \(upcomingInstruction.pc): \(upcomingInstruction)")
            
            if shouldBail(upcomingInstruction) {
                cpuState.pc = upcomingInstruction.pc
                if let logger = logger {
                    CPUStateSnapshot.logChanges(logger: logger,
                                                prevState: prevState,
                                                nextState: cpuState)
                }
                logger?.append("-----")
                break
            }
            
            interpreter.step()
            
            if shouldRecordStatesOverTime {
                recordedStatesOverTime.append(cpuState.copy() as! CPUStateSnapshot)
            }
            
            if let logger = logger {
                CPUStateSnapshot.logChanges(logger: logger,
                                            prevState: prevState,
                                            nextState: cpuState)
            }
            logger?.append("-----")
            
            stepCount += 1
        }
    }
    
    fileprivate func shouldBail(_ upcomingInstruction: Instruction) -> Bool {
        if upcomingInstruction.isBreakpoint && flagBreak.value {
            logger?.append("shouldBail: isBreakpoint && flagBreak.value")
            return true
        }
        if upcomingInstruction.guardFail == true {
            logger?.append("shouldBail: guardFail=true")
            return true
        }
        if let guardAddress = upcomingInstruction.guardAddress {
            if guardAddress != cpuState.valueOfXYPair() {
                logger?.append("shouldBail: address=0x%04x ; guardAddress=0x%04x", cpuState.valueOfXYPair(), guardAddress)
                return true
            }
        }
        if let guardFlags = upcomingInstruction.guardFlags {
            if guardFlags != cpuState.flags {
                logger?.append("shouldBail: flags=\(cpuState.flags) ; guardFlags=\(guardFlags)")
                return true
            }
        }
        return false
    }
    
    public func fetchInstruction(from pc: ProgramCounter) -> Instruction {
        if pc == trace.pc! {
            instructions = trace.instructions
        }
        if instructions.isEmpty {
            return Instruction.makeNOP(pc: pc).withGuard(fail: true)
        }
        return instructions.removeFirst()
    }
}
