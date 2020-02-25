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
    let interpreter: Interpreter
    var instructions: [Instruction] = []
    var countInstructionsPastTheEnd = 0
    
    public convenience init(trace: Trace, cpuState: CPUStateSnapshot) {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        
        self.init(trace: trace,
                  cpuState: cpuState,
                  peripherals: ComputerPeripherals(),
                  instructionDecoder: microcodeGenerator.microcode)
    }
    
    public init(trace: Trace,
                cpuState: CPUStateSnapshot,
                peripherals: ComputerPeripherals,
                instructionDecoder: InstructionDecoder) {
        self.cpuState = cpuState
        self.trace = trace.copy() as! Trace
        
        interpreter = Interpreter(cpuState: cpuState,
                                  peripherals: peripherals,
                                  instructionDecoder: instructionDecoder)
        
        super.init()
        
        if let finalPC = trace.finalPC {
            let pc = finalPC.increment()
            self.trace.appendGuard(pc: pc, fail: true)
            self.trace.append(instruction: makeGuideRailHLT(pc: pc))
            self.trace.append(instruction: makeGuideRailHLT(pc: pc))
        }
        instructions = self.trace.instructions
        
        interpreter.delegate = self
    }
    
    fileprivate func makeGuideRailHLT(pc: ProgramCounter) -> Instruction {
        return Instruction(opcode: 1,
                           immediate: 0,
                           disassembly: "HLT",
                           pc: pc,
                           guardFail: true)
    }
    
    public func run() {
        if self.trace.instructions.isEmpty {
            return
        }
        
        // Flush the pipeline so we begin executing the trace immediately.
        cpuState.if_id = fetchInstruction(from: trace.pc!)
        cpuState.pc = trace.pc!.increment().increment()
        cpuState.pc_if = trace.pc!.increment()
        
        while cpuState.controlWord.HLT == .inactive {
            let prevState = cpuState.copy() as! CPUStateSnapshot
            let upcomingInstruction = prevState.if_id
            
            if upcomingInstruction.guardFail == true {
                jumpAndFlushPipeline(pc: upcomingInstruction.pc)
                break
            }
            if let guardAddress = upcomingInstruction.guardAddress {
                if guardAddress != cpuState.valueOfXYPair() {
                    jumpAndFlushPipeline(pc: upcomingInstruction.pc)
                    break
                }
            }
            if let guardFlags = upcomingInstruction.guardFlags {
                if guardFlags != cpuState.flags {
                    jumpAndFlushPipeline(pc: upcomingInstruction.pc)
                    break
                }
            }
            
            interpreter.step()
            
            if let logger = logger {
                CPUStateSnapshot.logChanges(logger: logger,
                                            prevState: prevState,
                                            nextState: cpuState)
            }
            logger?.append("-----")
        }
    }
    
    fileprivate func jumpAndFlushPipeline(pc: ProgramCounter) {
        cpuState.pc = pc
        cpuState.pc_if = ProgramCounter()
        cpuState.if_id = Instruction.makeNOP()
    }
    
    public func storeToRAM(value: UInt8, at address: Int) {
        delegate!.storeToRAM(value: value, at: address)
    }
    
    public func loadFromRAM(at address: Int) -> UInt8 {
        return delegate!.loadFromRAM(at: address)
    }
    
    public func fetchInstruction(from: ProgramCounter) -> Instruction {
        return instructions.removeFirst()
    }
}
