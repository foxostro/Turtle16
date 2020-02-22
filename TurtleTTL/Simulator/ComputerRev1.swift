//
//  ComputerRev1.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Simulates the behavior of the TurtleTTL hardware.
public class ComputerRev1: NSObject, Computer {
    public let cpuState = CPUStateSnapshot()
    public var dataRAM = RAM()
    public var upperInstructionRAM = RAM()
    public var lowerInstructionRAM = RAM()
    public var instructionROM = InstructionROM()
    public var instructionDecoder = InstructionDecoder()
    var internalLogger:Logger? = nil
    public var logger:Logger? {
        get {
            return internalLogger
        }
        set(newLogger) {
            internalLogger = newLogger
            peripherals.logger = newLogger
        }
    }
    public var didUpdateSerialOutput:(String)->Void = {_ in}
    var peripherals = ComputerPeripherals()
    let decoderRomFilenameFormat = "Decoder ROM %d.bin"
    let lowerInstructionROMFilename = "Lower Instruction ROM.bin"
    let upperInstructionROMFilename = "Upper Instruction ROM.bin"
    let profiler = TraceProfiler()
    
    public func reset() {
        let storeUpperInstructionRAM = {(_ value: UInt8, _ address: Int) -> Void in
            self.upperInstructionRAM = self.upperInstructionRAM.withStore(value: value, to: address)
        }
        let loadUpperInstructionRAM = {(_ address: Int) -> UInt8 in
             return self.upperInstructionRAM.load(from: address)
        }
        let storeLowerInstructionRAM = {(_ value: UInt8, _ address: Int) -> Void in
            self.lowerInstructionRAM = self.lowerInstructionRAM.withStore(value: value, to: address)
        }
        let loadLowerInstructionRAM = {(_ address: Int) -> UInt8 in
            return self.lowerInstructionRAM.load(from: address)
        }
        peripherals.populate(storeUpperInstructionRAM,
                             loadUpperInstructionRAM,
                             storeLowerInstructionRAM,
                             loadLowerInstructionRAM)
        peripherals.getSerialInterface().didUpdateSerialOutput = didUpdateSerialOutput
        
        cpuState.bus = Register()
        cpuState.pc = ProgramCounter()
        cpuState.pc_if = ProgramCounter()
        cpuState.if_id = Instruction()
        cpuState.controlWord = ControlWord()
    }
    
    public func runUntilHalted() {
        while .inactive == cpuState.controlWord.HLT {
            step()
        }
    }
    
    public func step() {
        onControlClock()
        onRegisterClock()
        peripherals.onPeripheralClock()
        logger?.append("-----")
    }
    
    func onControlClock() {
        doID()
        doIF()
        doPCIF()
        doALU()
        
        cpuState.bus = Register(withValue: 0) // The bus pulls down to zero if nothing asserts a value.
        peripherals.resetControlSignals()
        
        logger?.append("Executing control word %@", cpuState.controlWord)
        
        if (.active == cpuState.controlWord.CO) {
            outputRegisterC()
        }
        
        if (.active == cpuState.controlWord.YO) {
            outputRegisterY()
        }
        
        if (.active == cpuState.controlWord.XO) {
            outputRegisterX()
        }
        
        if (.active == cpuState.controlWord.PO) {
            peripherals.activateSignalPO(cpuState.registerD.integerValue)
        }
        
        if (.active == cpuState.controlWord.MO) {
            outputDataRAM()
        }
        
        if (.active == cpuState.controlWord.VO) {
            outputRegisterV()
        }
        
        if (.active == cpuState.controlWord.UO) {
            outputRegisterU()
        }
        
        if (.active == cpuState.controlWord.EO) {
            outputRegisterE()
        }
        
        if (.active == cpuState.controlWord.FI) {
            latchFlagsRegister()
        }
        
        if (.active == cpuState.controlWord.AO) {
            outputRegisterA()
        }
        
        if (.active == cpuState.controlWord.BO) {
            outputRegisterB()
        }
        
        if (.active == cpuState.controlWord.LinkHiOut) {
            outputRegisterG()
        }
        
        if (.active == cpuState.controlWord.LinkLoOut) {
            outputRegisterH()
        }
        
        if (.active == cpuState.controlWord.XYInc) {
            incrementXY()
        }
        
        if (.active == cpuState.controlWord.UVInc) {
            incrementUV()
        }
        
        if (.active == cpuState.controlWord.J) {
            doJump()
        } else {
            incrementPC()
        }
        
        if (.active == cpuState.controlWord.HLT) {
            logger?.append("HLT")
        }
        
        doPeripheralControlClock()
    }
    
    func latchFlagsRegister() {
        let prev = cpuState.flags
        cpuState.flags = Flags(cpuState.aluFlags.carryFlag, cpuState.aluFlags.equalFlag)
        logger?.append("FI -- flags changing from %@ to %@", prev, cpuState.flags)
    }
    
    func outputRegisterA() {
        cpuState.bus = Register(withValue: cpuState.registerA.value)
        logger?.append("AO -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterB() {
        cpuState.bus = Register(withValue: cpuState.registerB.value)
        logger?.append("BO -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterC() {
        cpuState.bus = Register(withValue: cpuState.registerC.value)
        logger?.append("CO -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterE() {
        cpuState.bus = Register(withValue: cpuState.aluResult.value)
        logger?.append("EO -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterG() {
        cpuState.bus = Register(withValue: cpuState.registerG.value)
        logger?.append("LinkHiOut -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterH() {
        cpuState.bus = Register(withValue: cpuState.registerH.value)
        logger?.append("LinkLoOut -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterX() {
        cpuState.bus = Register(withValue: cpuState.registerX.value)
        logger?.append("XO -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterY() {
        cpuState.bus = Register(withValue: cpuState.registerY.value)
        logger?.append("YO -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterU() {
        cpuState.bus = Register(withValue: cpuState.registerU.value)
        logger?.append("UO -- output %@ onto bus", cpuState.bus)
    }
    
    func outputRegisterV() {
        cpuState.bus = Register(withValue: cpuState.registerV.value)
        logger?.append("VO -- output %@ onto bus", cpuState.bus)
    }
    
    public func incrementXY() {
        if cpuState.registerY.value == 255 {
            cpuState.registerX = Register(withValue: cpuState.registerX.value &+ 1)
            cpuState.registerY = Register(withValue: 0)
        } else {
            cpuState.registerY = Register(withValue: cpuState.registerY.value &+ 1)
        }
        logger?.append("XYInc -- Increment XY register pair. New value is 0x%@",
                       String(valueOfXYPair(), radix: 16))
    }

    public func incrementUV() {
        if cpuState.registerV.value == 255 {
            cpuState.registerU = Register(withValue: cpuState.registerU.value &+ 1)
            cpuState.registerV = Register(withValue: 0)
        } else {
            cpuState.registerV = Register(withValue: cpuState.registerV.value &+ 1)
        }
        logger?.append("XYInc -- Increment UV register pair. New value is 0x%@",
                       String(valueOfUVPair(), radix: 16))
    }
    
    func doJump() {
        let oldPC = cpuState.pc.value
        let newPC = UInt16(valueOfXYPair())
        recordBackwardJumps(newPC, oldPC)
        cpuState.pc = ProgramCounter(withValue: newPC)
        logger?.append("J -- jump to %@", cpuState.pc)
    }
    
    func recordBackwardJumps(_ newPC: UInt16, _ oldPC: UInt16) {
        if newPC < oldPC {
            let hasBecomeHot = profiler.hit(pc: newPC)
            if hasBecomeHot {
                logger?.append("Jump destination \(newPC) has become hot.")
            }
        }
    }
    
    func incrementPC() {
        cpuState.pc = cpuState.pc.increment()
        logger?.append("PC -> %@", cpuState.pc)
    }
    
    func outputDataRAM() {
        cpuState.bus = Register(withValue: dataRAM.load(from: valueOfUVPair()))
        logger?.append("MO -- Load %@ from Data RAM at address 0x%@",
                       cpuState.bus, String(valueOfUVPair(), radix: 16))
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
        let offset = 0x8000
        if cpuState.pc_if.value < offset {
            cpuState.if_id = instructionROM.load(from: cpuState.pc_if.integerValue)
        } else {
            let opcode = Int(upperInstructionRAM.load(from: cpuState.pc_if.integerValue - offset))
            let immediate = Int(lowerInstructionRAM.load(from: cpuState.pc_if.integerValue - offset))
            cpuState.if_id = Instruction(opcode: opcode, immediate: immediate)
        }
        logger?.append("IF/ID -> %@", cpuState.if_id)
    }
    
    func doPCIF() {
        cpuState.pc_if = ProgramCounter(withValue: cpuState.pc.value)
        logger?.append("PC/IF -> %@", cpuState.pc_if)
    }
    
    func doALU() {
        let a = cpuState.registerA.value
        let b = cpuState.registerB.value
        let c = cpuState.registerC.value
        let alu = ALU()
        alu.s = (c & 0b1111)
        alu.mode = Int(c & 0b10000) >> 4
        alu.carryIn = (cpuState.controlWord.CarryIn == .active) ? 0 : 1
        alu.a = a
        alu.b = b
        alu.update()
        
        if (.active==cpuState.controlWord.EO || .active==cpuState.controlWord.FI) {
            logger?.append("ALU operation with s = 0b%@, carryIn = %x, mode = %x, a = 0x%x, b = 0x%x. This yields result = 0x%x, carryFlag = %x, equalFlag = %x", String(alu.s, radix: 2), alu.carryIn, alu.mode, alu.a, alu.b, alu.result, alu.carryFlag, alu.equalFlag)
        }
        
        cpuState.aluResult = Register(withValue: alu.result)
        cpuState.aluFlags = Flags(alu.carryFlag, alu.equalFlag)
    }
    
    func doPeripheralControlClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onControlClock()
        cpuState.bus = peripherals.bus
    }
    
    func onRegisterClock() {
        if (.active == cpuState.controlWord.YI) {
            inputRegisterY()
        }
        
        if (.active == cpuState.controlWord.XI) {
            inputRegisterX()
        }
        
        if (.active == cpuState.controlWord.VI) {
            inputRegisterV()
        }
        
        if (.active == cpuState.controlWord.UI) {
            inputRegisterU()
        }
        
        if (.active == cpuState.controlWord.AI) {
            inputRegisterA()
        }
        
        if (.active == cpuState.controlWord.BI) {
            inputRegisterB()
        }
        
        if (.active == cpuState.controlWord.DI) {
            inputRegisterD()
        }
        
        if (.active == cpuState.controlWord.PI) {
            peripherals.activateSignalPI(cpuState.registerD.integerValue)
        }
        
        if (.active == cpuState.controlWord.MI) {
            inputDataRAM()
        }
        
        if (.active == cpuState.controlWord.LinkIn) {
            inputLinkRegister()
        }
        
        doPeripheralRegisterClock()
    }
    
    func inputRegisterA() {
        logger?.append("AI -- input %@ from bus", cpuState.bus)
        cpuState.registerA = Register(withValue: cpuState.bus.value)
    }
    
    func inputRegisterB() {
        logger?.append("BI -- input %@ from bus", cpuState.bus)
        cpuState.registerB = Register(withValue: cpuState.bus.value)
    }
    
    func inputRegisterD() {
        cpuState.registerD = Register(withValue: cpuState.bus.value)
        let name = peripherals.getName(at: Int(cpuState.registerD.value & 0b111))
        logger?.append("DI -- input %@ from bus. Selected peripheral is now \"%@\"",
                       cpuState.registerD, name)
    }
    
    func inputRegisterX() {
        logger?.append("XI -- input %@ from bus", cpuState.bus)
        cpuState.registerX = Register(withValue: cpuState.bus.value)
    }
    
    func inputRegisterY() {
        logger?.append("YI -- input %@ from bus", cpuState.bus)
        cpuState.registerY = Register(withValue: cpuState.bus.value)
    }
    
    func inputRegisterU() {
        logger?.append("UI -- input %@ from bus", cpuState.bus)
        cpuState.registerU = Register(withValue: cpuState.bus.value)
    }
    
    func inputRegisterV() {
        logger?.append("VI -- input %@ from bus", cpuState.bus)
        cpuState.registerV = Register(withValue: cpuState.bus.value)
    }
    
    func inputDataRAM() {
        logger?.append("MI -- Store %@ to Data RAM at address 0x%@",
                       cpuState.bus, String(valueOfUVPair(), radix: 16))
        dataRAM = dataRAM.withStore(value: cpuState.bus.value, to:valueOfUVPair())
    }
    
    func inputLinkRegister() {
        cpuState.registerG = Register(withValue: UInt8((cpuState.pc.value >> 8) & 0xff))
        cpuState.registerH = Register(withValue: UInt8(cpuState.pc.value & 0xff))
        logger?.append("LinkIn -- Setting the Link register with PC value of 0x%@",
                       cpuState.pc.stringValue)
    }
    
    fileprivate func doPeripheralRegisterClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onRegisterClock()
    }
    
    public func execute() {
        reset()
        while (.inactive == cpuState.controlWord.HLT) {
            step()
        }
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        instructionROM = instructionROM.withStore(instructions)
    }
    
    public func saveMicrocode(to: URL) throws {
        // Use minipro on the command-line to flash the binary file to EEPROM:
        //   % minipro -p SST29EE010 -y -w ./file.bin
        try FileManager.default.createDirectory(at: to,
                                                withIntermediateDirectories: false,
                                                attributes: [:])
        let roms = instructionDecoder.rom
        for i in 0..<roms.count {
            let fileName = String(format: decoderRomFilenameFormat, i)
            let rom = roms[i].data
            try rom.write(to: to.appendingPathComponent(fileName))
        }
    }
    
    public func loadMicrocode(from: URL) throws {
        var roms = [Memory]()
        for i in 0..<instructionDecoder.rom.count {
            let fileName = String(format: decoderRomFilenameFormat, i)
            let data = try Data(contentsOf: from.appendingPathComponent(fileName) as URL)
            let rom = Memory(withData: data)
            roms.append(rom)
        }
        let decoder = InstructionDecoder(withROM: roms)
        provideMicrocode(microcode: decoder)
    }
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        instructionDecoder = microcode
    }
    
    public func saveProgram(to: URL) throws {
        // Use minipro on the command-line to flash the binary file to EEPROM:
        //   % minipro -p SST29EE010 -y -w ./file.bin
        let lowerROM = instructionROM.lowerROM.data
        let upperROM = instructionROM.upperROM.data
        
        try FileManager.default.createDirectory(at: to,
                                                withIntermediateDirectories: true,
                                                attributes: [:])
        try lowerROM.write(to: to.appendingPathComponent(lowerInstructionROMFilename))
        try upperROM.write(to: to.appendingPathComponent(upperInstructionROMFilename))
    }
    
    public func loadProgram(from: URL) throws {
        let lowerData = try Data(contentsOf: from.appendingPathComponent(lowerInstructionROMFilename) as URL)
        let upperData = try Data(contentsOf: from.appendingPathComponent(upperInstructionROMFilename) as URL)
        
        let rom = InstructionROM(withUpperROM: Memory(withData: upperData),
                                 withLowerROM: Memory(withData: lowerData))
        
        instructionROM = rom
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        peripherals.getSerialInterface().provideSerialInput(bytes: bytes)
    }
    
    func valueOfXYPair() -> Int {
        return cpuState.registerX.integerValue<<8 | cpuState.registerY.integerValue
    }

    func valueOfUVPair() -> Int {
        return cpuState.registerU.integerValue<<8 | cpuState.registerV.integerValue
    }
}
