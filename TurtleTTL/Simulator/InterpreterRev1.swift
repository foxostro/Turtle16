//
//  InterpreterRev1.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 3/13/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class InterpreterRev1: NSObject, Interpreter {
    public weak var delegate: InterpreterDelegate? = nil
    public let cpuState: CPUStateSnapshot
    public var instructionDecoder: InstructionDecoder
    public var peripherals: ComputerPeripherals
    public var dataRAM: Memory
    let alu = ALU()
    
    public override convenience init() {
        self.init(cpuState: CPUStateSnapshot(),
                  peripherals: ComputerPeripherals(),
                  dataRAM: Memory())
    }
    
    public init(cpuState: CPUStateSnapshot,
                peripherals: ComputerPeripherals,
                dataRAM: Memory) {
        self.cpuState = cpuState
        self.peripherals = peripherals
        self.dataRAM = dataRAM
        
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        self.instructionDecoder = microcodeGenerator.microcode
    }
    
    public init(cpuState: CPUStateSnapshot,
                peripherals: ComputerPeripherals,
                dataRAM: Memory,
                instructionDecoder: InstructionDecoder) {
        self.cpuState = cpuState
        self.dataRAM = dataRAM
        self.peripherals = peripherals
        self.instructionDecoder = instructionDecoder
    }

    // This method duplicates the functionality of the hardware reset button.
    // The pipeline is flushed and the program counter is reset to zero.
    public func reset() {
        cpuState.bus = Register()
        cpuState.pc = ProgramCounter()
        cpuState.pc_if = ProgramCounter()
        cpuState.if_id = Instruction.makeNOP()
        cpuState.controlWord = ControlWord()
        cpuState.registerC = Register(withValue: 0)
        cpuState.uptime = 0
    }
    
    // Emulates one hardware clock tick.
    public func step() {
        onControlClock()
        if doesExecutionInvolvePeripherals() {
            tickPeripheralControlClock()
        }
        onRegisterClock()
        if doesExecutionInvolvePeripherals() {
            tickPeripheralRegisterClock()
            peripherals.onPeripheralClock()
        }
        cpuState.uptime += 1
    }
    
    fileprivate func tickPeripheralControlClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onControlClock()
        cpuState.bus = peripherals.bus
    }
    
    fileprivate func tickPeripheralRegisterClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onRegisterClock()
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
    
    fileprivate func doID() {
        cpuState.registerC = Register(withValue: cpuState.if_id.immediate)
        let opcode = Int(cpuState.if_id.opcode)
        let b = instructionDecoder.load(opcode: opcode,
                                        carryFlag: cpuState.flags.carryFlag,
                                        equalFlag: cpuState.flags.equalFlag)
        cpuState.controlWord = ControlWord(withValue: UInt(b))
        
        if doesExecutionInvolvePeripherals() {
            peripherals.catchUp(uptime: cpuState.uptime)
        }
    }
    
    fileprivate func doesExecutionInvolvePeripherals() -> Bool {
        return cpuState.controlWord.PI == .active || cpuState.controlWord.PO == .active
    }
    
    fileprivate func doIF() {
        cpuState.if_id = delegate!.fetchInstruction(from: cpuState.pc_if)
    }
    
    fileprivate func doPCIF() {
        cpuState.pc_if = ProgramCounter(withValue: cpuState.pc.value)
    }
    
    fileprivate func doALU() {
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
            peripherals.activateSignalPO(cpuState.registerD.integerValue)
        }
    }
    
    fileprivate func handleControlSignalMO() {
        if (.active == cpuState.controlWord.MO) {
            let value = dataRAM.load(from: cpuState.valueOfUVPair())
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
            cpuState.pc = ProgramCounter(withValue: UInt16(cpuState.valueOfXYPair()))
        } else {
            cpuState.pc = cpuState.pc.increment()
        }
    }
    
    fileprivate func onRegisterClock() {
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
            peripherals.activateSignalPI(cpuState.registerD.integerValue)
        }
    }
    
    fileprivate func handleControlSignalMI() {
        if (.active == cpuState.controlWord.MI) {
            dataRAM.store(value: cpuState.bus.value,
                          to: cpuState.valueOfUVPair())
        }
    }
 
    func handleControlSignalLinkIn() {
        if (.active == cpuState.controlWord.LinkIn) {
            cpuState.registerG = Register(withValue: UInt8((cpuState.pc.value >> 8) & 0xff))
            cpuState.registerH = Register(withValue: UInt8(cpuState.pc.value & 0xff))
        }
    }
}
