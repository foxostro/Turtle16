//
//  Interpreter.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public protocol InterpreterDelegate: NSObject {
    func storeToRAM(value: UInt8, at: Int)
    func loadFromRAM(at: Int) -> UInt8
    
    // Fetch an instruction for the IF stage. This may fetch from instruction
    // RAM, or from some other source.
    func fetchInstruction(from: ProgramCounter) -> Instruction
    
    // Called immediately before executing a jump.
    func willJump(from: ProgramCounter, to: ProgramCounter)
    
    // The peripheral device will directly read and modify CPU state.
    // TODO: storeToPeripheral() and loadFromPeripheral() could use a better API
    func storeToPeripheral(cpuState: CPUStateSnapshot)
    func loadFromPeripheral(cpuState: CPUStateSnapshot)
    
    // The following two delegate methods are called after handling each of the
    // two CPU clocks.
    // Peripheral devices must perform specific actions on specific clock pulses
    // and these calls permit that fine granularity of emulation.
    func didTickControlClock()
    func didTickRegisterClock()
}

// Interpreter for revision one of the computer hardware.
public class Interpreter: NSObject {
    public weak var delegate: InterpreterDelegate? = nil
    public let cpuState: CPUStateSnapshot
    public var instructionDecoder: InstructionDecoder
    let alu = ALU()
    
    public override convenience init() {
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        self.init(cpuState: CPUStateSnapshot(),
                  instructionDecoder: microcodeGenerator.microcode)
    }
    
    public init(cpuState: CPUStateSnapshot,
                instructionDecoder: InstructionDecoder) {
        self.cpuState = cpuState
        self.instructionDecoder = instructionDecoder
    }

    // This method duplicates the functionality of the hardware reset button.
    // The pipeline is flushed and the program counter is reset to zero.
    public func reset() {
        cpuState.bus = Register()
        cpuState.pc = ProgramCounter()
        cpuState.pc_if = ProgramCounter()
        cpuState.if_id = Instruction()
        cpuState.controlWord = ControlWord()
    }
    
    // Emulates one hardware clock tick.
    public func step() {
        onControlClock()
        delegate?.didTickControlClock()
        onRegisterClock()
        delegate?.didTickRegisterClock()
    }
    
    fileprivate func onControlClock() {
        doID()
        doIF()
        doPCIF()
        doALU()
        
        cpuState.bus = Register(withValue: 0) // The bus pulls down to zero if nothing asserts a value.
        
        handleControlSignalCO()
        handleControlSignalYO()
        handleControlSignalXO()
        handleControlSignalPO()
        handleControlSignalMO()
        handleControlSignalVO()
        handleControlSignalUO()
        handleControlSignalEO()
        handleControlSignalFI()
        handleControlSignalAO()
        handleControlSignalBO()
        handleControlSignalLinkHiOut()
        handleControlSignalLinkLoOut()
        handleControlSignalXYInc()
        handleControlSignalUVInc()
        handleControlSignalJ()
    }
    
    func doID() {
        cpuState.registerC = Register(withValue: cpuState.if_id.immediate)
        let opcode = Int(cpuState.if_id.opcode)
        let b = instructionDecoder.load(opcode: opcode,
                                        carryFlag: cpuState.flags.carryFlag,
                                        equalFlag: cpuState.flags.equalFlag)
        cpuState.controlWord = ControlWord(withValue: UInt(b))
    }
    
    func doIF() {
        cpuState.if_id = delegate!.fetchInstruction(from: cpuState.pc_if)
    }
    
    func doPCIF() {
        cpuState.pc_if = ProgramCounter(withValue: cpuState.pc.value)
    }
    
    func doALU() {
        let a = cpuState.registerA.value
        let b = cpuState.registerB.value
        let c = cpuState.registerC.value
        alu.s = (c & 0b1111)
        alu.mode = Int(c & 0b10000) >> 4
        alu.carryIn = (cpuState.controlWord.CarryIn == .active) ? 0 : 1
        alu.a = a
        alu.b = b
        alu.update()
        
        cpuState.aluResult = Register(withValue: alu.result)
        cpuState.aluFlags = Flags(alu.carryFlag, alu.equalFlag)
    }
    
    fileprivate func handleControlSignalCO() {
        if (.active == cpuState.controlWord.CO) {
            cpuState.bus = Register(withValue: cpuState.registerC.value)
        }
    }
    
    fileprivate func handleControlSignalYO() {
        if (.active == cpuState.controlWord.YO) {
            cpuState.bus = Register(withValue: cpuState.registerY.value)
        }
    }
    
    fileprivate func handleControlSignalXO() {
        if (.active == cpuState.controlWord.XO) {
            cpuState.bus = Register(withValue: cpuState.registerX.value)
        }
    }
    
    fileprivate func handleControlSignalPO() {
        if (.active == cpuState.controlWord.PO) {
            delegate?.loadFromPeripheral(cpuState: cpuState)
        }
    }
    
    fileprivate func handleControlSignalMO() {
        if (.active == cpuState.controlWord.MO) {
            let value = delegate?.loadFromRAM(at: cpuState.valueOfUVPair()) ?? 0
            cpuState.bus = Register(withValue: value)
        }
    }
    
    fileprivate func handleControlSignalVO() {
        if (.active == cpuState.controlWord.VO) {
            cpuState.bus = Register(withValue: cpuState.registerV.value)
        }
    }
    
    fileprivate func handleControlSignalUO() {
        if (.active == cpuState.controlWord.UO) {
            cpuState.bus = Register(withValue: cpuState.registerU.value)
        }
    }
    
    fileprivate func handleControlSignalEO() {
        if (.active == cpuState.controlWord.EO) {
            cpuState.bus = Register(withValue: cpuState.aluResult.value)
        }
    }
    
    fileprivate func handleControlSignalFI() {
        if (.active == cpuState.controlWord.FI) {
            cpuState.flags = Flags(cpuState.aluFlags.carryFlag, cpuState.aluFlags.equalFlag)
        }
    }
    
    fileprivate func handleControlSignalAO() {
        if (.active == cpuState.controlWord.AO) {
            cpuState.bus = Register(withValue: cpuState.registerA.value)
        }
    }
    
    fileprivate func handleControlSignalBO() {
        if (.active == cpuState.controlWord.BO) {
            cpuState.bus = Register(withValue: cpuState.registerB.value)
        }
    }
    
    fileprivate func handleControlSignalLinkHiOut() {
        if (.active == cpuState.controlWord.LinkHiOut) {
            cpuState.bus = Register(withValue: cpuState.registerG.value)
        }
    }
    
    fileprivate func handleControlSignalLinkLoOut() {
        if (.active == cpuState.controlWord.LinkLoOut) {
            cpuState.bus = Register(withValue: cpuState.registerH.value)
        }
    }
    
    fileprivate func handleControlSignalXYInc() {
        if (.active == cpuState.controlWord.XYInc) {
            incrementXY()
        }
    }

    fileprivate func incrementXY() {
        if cpuState.registerY.value == 255 {
            cpuState.registerX = Register(withValue: cpuState.registerX.value &+ 1)
            cpuState.registerY = Register(withValue: 0)
        } else {
            cpuState.registerY = Register(withValue: cpuState.registerY.value &+ 1)
        }
    }
    
    fileprivate func handleControlSignalUVInc() {
        if (.active == cpuState.controlWord.UVInc) {
            incrementUV()
        }
    }

    fileprivate func incrementUV() {
        if cpuState.registerV.value == 255 {
            cpuState.registerU = Register(withValue: cpuState.registerU.value &+ 1)
            cpuState.registerV = Register(withValue: 0)
        } else {
            cpuState.registerV = Register(withValue: cpuState.registerV.value &+ 1)
        }
    }
    
    fileprivate func handleControlSignalJ() {
        if (.active == cpuState.controlWord.J) {
            let dst = ProgramCounter(withValue: UInt16(cpuState.valueOfXYPair()))
            delegate?.willJump(from: cpuState.pc, to: dst)
            cpuState.pc = dst
        } else {
            cpuState.pc = cpuState.pc.increment()
        }
    }
    
    func onRegisterClock() {
        handleControlSignalYI()
        handleControlSignalXI()
        handleControlSignalVI()
        handleControlSignalUI()
        handleControlSignalAI()
        handleControlSignalBI()
        handleControlSignalDI()
        handleControlSignalPI()
        handleControlSignalMI()
        handleControlSignalLinkIn()
    }
    
    fileprivate func handleControlSignalYI() {
        if (.active == cpuState.controlWord.YI) {
            cpuState.registerY = Register(withValue: cpuState.bus.value)
        }
    }
    
    fileprivate func handleControlSignalXI() {
        if (.active == cpuState.controlWord.XI) {
            cpuState.registerX = Register(withValue: cpuState.bus.value)
        }
    }
    
    fileprivate func handleControlSignalVI() {
        if (.active == cpuState.controlWord.VI) {
            cpuState.registerV = Register(withValue: cpuState.bus.value)
        }
    }
    
    fileprivate func handleControlSignalUI() {
        if (.active == cpuState.controlWord.UI) {
            cpuState.registerU = Register(withValue: cpuState.bus.value)
        }
    }
    
    fileprivate func handleControlSignalAI() {
        if (.active == cpuState.controlWord.AI) {
            cpuState.registerA = Register(withValue: cpuState.bus.value)
        }
    }
    
    fileprivate func handleControlSignalBI() {
        if (.active == cpuState.controlWord.BI) {
            cpuState.registerB = Register(withValue: cpuState.bus.value)
        }
    }
    
    fileprivate func handleControlSignalDI() {
        if (.active == cpuState.controlWord.DI) {
            cpuState.registerD = Register(withValue: cpuState.bus.value)
        }
    }
        
    fileprivate func handleControlSignalPI() {
        if (.active == cpuState.controlWord.PI) {
            delegate?.storeToPeripheral(cpuState: cpuState)
        }
    }
    
    fileprivate func handleControlSignalMI() {
        if (.active == cpuState.controlWord.MI) {
            delegate?.storeToRAM(value: cpuState.bus.value,
                                 at: cpuState.valueOfUVPair())
        }
    }
 
    fileprivate func handleControlSignalLinkIn() {
        if (.active == cpuState.controlWord.LinkIn) {
            cpuState.registerG = Register(withValue: UInt8((cpuState.pc.value >> 8) & 0xff))
            cpuState.registerH = Register(withValue: UInt8(cpuState.pc.value & 0xff))
        }
    }
}
