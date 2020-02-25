//
//  TraceInterpreter.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/23/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class TraceInterpreter: NSObject, InterpreterDelegate {
    public weak var delegate: InterpreterDelegate? = nil
    public var traceExitingPC: ProgramCounter! = nil
    public var logger: Logger? = nil
    let cpuState: CPUStateSnapshot
    let interpreter: Interpreter
    let trace: Trace
    var instructions: [Instruction]
    var mostRecentInstructionPC = ProgramCounter()
    var countPastEnd = 0
    
    public init(cpuState: CPUStateSnapshot,
                peripherals: ComputerPeripherals,
                instructionDecoder: InstructionDecoder,
                trace: Trace) {
        self.cpuState = cpuState
        self.trace = trace
        interpreter = Interpreter(cpuState: cpuState, peripherals: peripherals)
        interpreter.instructionDecoder = instructionDecoder
        instructions = trace.instructions
        super.init()
        interpreter.delegate = self
    }
    
    public func storeToRAM(value: UInt8, at address: Int) {
        delegate!.storeToRAM(value: value, at: address)
    }
    
    public func loadFromRAM(at address: Int) -> UInt8 {
        return delegate!.loadFromRAM(at: address)
    }
    
    public func fetchInstruction(from: ProgramCounter) -> Instruction {
        if instructions.isEmpty {
            return Instruction.makeNOP(pc: from)
        } else {
            return instructions.removeFirst()
        }
    }
    
    public func run() {
        while !isFinished() && cpuState.controlWord.HLT == .inactive {
            let prevState = cpuState.copy() as! CPUStateSnapshot
            interpreter.step()
            if let logger = logger {
                CPUStateSnapshot.logChanges(logger: logger,
                                            prevState: prevState,
                                            nextState: cpuState)
            }
            logger?.append("-----")
        }
        jumpToTraceExitPoint()
    }
    
    func isFinished() -> Bool {
        let nextInstruction = cpuState.if_id
        
        if let guardFail = nextInstruction.guardFail {
            if guardFail {
                traceExitingPC = nextInstruction.pc
                return true
            }
        }
        
        if let guardAddress = nextInstruction.guardAddress {
            if guardAddress != cpuState.valueOfXYPair() {
                traceExitingPC = nextInstruction.pc
                return true
            }
        }
        
        if let guardFlags = nextInstruction.guardFlags {
            if guardFlags != cpuState.flags {
                traceExitingPC = nextInstruction.pc
                return true
            }
        }
        
        return false
    }
    
    // Jump to the trace exiting PC and flush the pipeline.
    func jumpToTraceExitPoint() {
        if traceExitingPC == nil {
            traceExitingPC = mostRecentInstructionPC.increment()
        }
        cpuState.bus = Register()
        cpuState.pc = traceExitingPC
        cpuState.pc_if = ProgramCounter()
        cpuState.if_id = Instruction.makeNOP()
        logger?.append("Finished running trace and set program counter to \(traceExitingPC!).")
    }
}
