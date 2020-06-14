//
//  Interpreter.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 2/21/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public protocol InterpreterDelegate: NSObject {
    // Fetch an instruction for the IF stage. This may fetch from instruction
    // RAM, or from some other source.
    func fetchInstruction(from: ProgramCounter) -> Instruction
}

// Interpreter for revision two of the computer hardware.
public class Interpreter: NSObject {
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
    
    private func tickPeripheralControlClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onControlClock()
        cpuState.bus = peripherals.bus
    }
    
    private func tickPeripheralRegisterClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onRegisterClock()
    }
    
    private func onControlClock() {
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
    
    private func doID() {
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
    
    private func doesExecutionInvolvePeripherals() -> Bool {
        return cpuState.controlWord.PI == .active || cpuState.controlWord.PO == .active
    }
    
    private func doIF() {
        cpuState.if_id = delegate!.fetchInstruction(from: cpuState.pc_if)
    }
    
    private func doPCIF() {
        cpuState.pc_if = ProgramCounter(withValue: cpuState.pc.value)
    }
    
    private func doALU() {
        let a = cpuState.registerA.value
        let b = cpuState.registerB.value
        let c = cpuState.registerC.value
        alu.s = (c & 0b1111)
        alu.mode = Int(c & 0b10000) >> 4
        alu.carryIn = (cpuState.controlWord.CarryIn == .active) ? 0 : 1
        alu.a = a
        alu.b = b
        alu.update()
        
        // On real hardware, the ALU takes two clock cycles to produce a result.
        // Use a buffer to introduce a delay. Though, this won't precisely
        // replicate the behavior of hardware where the result is also unstable
        // during that first clock tick.
        
        cpuState.aluResult = cpuState.aluResultBuffer
        cpuState.aluResultBuffer = Register(withValue: alu.result)
        
        cpuState.aluFlags = cpuState.aluFlagsBuffer
        cpuState.aluFlagsBuffer = Flags(alu.carryFlag, alu.equalFlag)
    }
    
    private func handleControlSignalCO() {
        if (.active == cpuState.controlWord.CO) {
            cpuState.bus = Register(withValue: cpuState.registerC.value)
        }
    }
    
    private func handleControlSignalYO() {
        if (.active == cpuState.controlWord.YO) {
            cpuState.bus = Register(withValue: cpuState.registerY.value)
        }
    }
    
    private func handleControlSignalXO() {
        if (.active == cpuState.controlWord.XO) {
            cpuState.bus = Register(withValue: cpuState.registerX.value)
        }
    }
    
    private func handleControlSignalPO() {
        if (.active == cpuState.controlWord.PO) {
            peripherals.activateSignalPO(cpuState.registerD.integerValue)
        }
    }
    
    private func handleControlSignalMO() {
        if (.active == cpuState.controlWord.MO) {
            let value = dataRAM.load(from: cpuState.valueOfUVPair())
//            print(String(format: "load 0x%02x from RAM at 0x%04x", value, cpuState.valueOfUVPair()))
            cpuState.bus = Register(withValue: value)
        }
    }
    
    private func handleControlSignalVO() {
        if (.active == cpuState.controlWord.VO) {
            cpuState.bus = Register(withValue: cpuState.registerV.value)
        }
    }
    
    private func handleControlSignalUO() {
        if (.active == cpuState.controlWord.UO) {
            cpuState.bus = Register(withValue: cpuState.registerU.value)
        }
    }
    
    private func handleControlSignalEO() {
        if (.active == cpuState.controlWord.EO) {
            cpuState.bus = Register(withValue: cpuState.aluResult.value)
        }
    }
    
    private func handleControlSignalFI() {
        if (.active == cpuState.controlWord.FI) {
            cpuState.flags = Flags(cpuState.aluFlags.carryFlag, cpuState.aluFlags.equalFlag)
        }
    }
    
    private func handleControlSignalAO() {
        if (.active == cpuState.controlWord.AO) {
            cpuState.bus = Register(withValue: cpuState.registerA.value)
        }
    }
    
    private func handleControlSignalBO() {
        if (.active == cpuState.controlWord.BO) {
            cpuState.bus = Register(withValue: cpuState.registerB.value)
        }
    }
    
    private func handleControlSignalLinkHiOut() {
        if (.active == cpuState.controlWord.LinkHiOut) {
            cpuState.bus = Register(withValue: cpuState.registerG.value)
        }
    }
    
    private func handleControlSignalLinkLoOut() {
        if (.active == cpuState.controlWord.LinkLoOut) {
            cpuState.bus = Register(withValue: cpuState.registerH.value)
        }
    }
    
    private func handleControlSignalXYInc() {
        if (.active == cpuState.controlWord.XYInc) {
            incrementXY()
        }
    }

    private func incrementXY() {
        if cpuState.registerY.value == 255 {
            cpuState.registerX = Register(withValue: cpuState.registerX.value &+ 1)
            cpuState.registerY = Register(withValue: 0)
        } else {
            cpuState.registerY = Register(withValue: cpuState.registerY.value &+ 1)
        }
    }
    
    private func handleControlSignalUVInc() {
        if (.active == cpuState.controlWord.UVInc) {
            incrementUV()
        }
    }

    private func incrementUV() {
        if cpuState.registerV.value == 255 {
            cpuState.registerU = Register(withValue: cpuState.registerU.value &+ 1)
            cpuState.registerV = Register(withValue: 0)
        } else {
            cpuState.registerV = Register(withValue: cpuState.registerV.value &+ 1)
        }
    }
    
    private func handleControlSignalJ() {
        if (.active == cpuState.controlWord.J) {
            cpuState.pc = ProgramCounter(withValue: UInt16(cpuState.valueOfXYPair()))
        } else {
            cpuState.pc = cpuState.pc.increment()
        }
    }
    
    private func onRegisterClock() {
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
    
    private func handleControlSignalYI() {
        if (.active == cpuState.controlWord.YI) {
            cpuState.registerY = Register(withValue: cpuState.bus.value)
        }
    }
    
    private func handleControlSignalXI() {
        if (.active == cpuState.controlWord.XI) {
            cpuState.registerX = Register(withValue: cpuState.bus.value)
        }
    }
    
    private func handleControlSignalVI() {
        if (.active == cpuState.controlWord.VI) {
            cpuState.registerV = Register(withValue: cpuState.bus.value)
        }
    }
    
    private func handleControlSignalUI() {
        if (.active == cpuState.controlWord.UI) {
            cpuState.registerU = Register(withValue: cpuState.bus.value)
        }
    }
    
    private func handleControlSignalAI() {
        if (.active == cpuState.controlWord.AI) {
            cpuState.registerA = Register(withValue: cpuState.bus.value)
        }
    }
    
    private func handleControlSignalBI() {
        if (.active == cpuState.controlWord.BI) {
            cpuState.registerB = Register(withValue: cpuState.bus.value)
        }
    }
    
    private func handleControlSignalDI() {
        if (.active == cpuState.controlWord.DI) {
            cpuState.registerD = Register(withValue: cpuState.bus.value)
        }
    }
        
    private func handleControlSignalPI() {
        if (.active == cpuState.controlWord.PI) {
            peripherals.activateSignalPI(cpuState.registerD.integerValue)
        }
    }
    
    private func handleControlSignalMI() {
        if (.active == cpuState.controlWord.MI) {
//            print(String(format: "store 0x%02x to RAM at 0x%04x", cpuState.bus.value, cpuState.valueOfUVPair()))
            dataRAM.store(value: cpuState.bus.value,
                          to: cpuState.valueOfUVPair())
        }
    }
 
    private func handleControlSignalLinkIn() {
        // The Rev2 hardware loads the LINK register from PC/IF. This fixes a
        // hardware bug in Rev1 which broke the JALR instruction.
        if (.active == cpuState.controlWord.LinkIn) {
            cpuState.registerG = Register(withValue: UInt8((cpuState.pc_if.value >> 8) & 0xff))
            cpuState.registerH = Register(withValue: UInt8(cpuState.pc_if.value & 0xff))
        }
    }
}
