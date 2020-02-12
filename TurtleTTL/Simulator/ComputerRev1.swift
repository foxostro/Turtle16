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
    public var bus = Register()
    public var registerA = Register()
    public var registerB = Register()
    public var registerC = Register()
    public var registerD = Register()
    public var registerG = Register() // LinkHi
    public var registerH = Register() // LinkLo
    public var registerX = Register()
    public var registerY = Register()
    public var registerU = Register()
    public var registerV = Register()
    public var aluResult = Register()
    public var aluFlags = Flags()
    public var flags = Flags()
    public var pc = ProgramCounter()
    public var pc_if = ProgramCounter()
    public var if_id = Instruction()
    public var controlWord = ControlWord()
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
    public var appendSerialOutput:(String)->Void = {_ in}
    var peripherals = ComputerPeripherals()
    let decoderRomFilenameFormat = "Decoder ROM %d.bin"
    let lowerInstructionROMFilename = "Lower Instruction ROM.bin"
    let upperInstructionROMFilename = "Upper Instruction ROM.bin"
    
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
        peripherals.getSerialInterface().appendSerialOutput = appendSerialOutput
        
        bus = Register()
        pc = ProgramCounter()
        pc_if = ProgramCounter()
        if_id = Instruction()
        controlWord = ControlWord()
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
        
        bus = Register(withValue: 0) // The bus pulls down to zero if nothing asserts a value.
        peripherals.resetControlSignals()
        
        logger?.append("Executing control word %@", controlWord)
        
        if (.active == controlWord.CO) {
            outputRegisterC()
        }
        
        if (.active == controlWord.YO) {
            outputRegisterY()
        }
        
        if (.active == controlWord.XO) {
            outputRegisterX()
        }
        
        if (.active == controlWord.PO) {
            peripherals.activateSignalPO(registerD.integerValue)
        }
        
        if (.active == controlWord.MO) {
            outputDataRAM()
        }
        
        if (.active == controlWord.VO) {
            outputRegisterV()
        }
        
        if (.active == controlWord.UO) {
            outputRegisterU()
        }
        
        if (.active == controlWord.EO) {
            outputRegisterE()
        }
        
        if (.active == controlWord.FI) {
            latchFlagsRegister()
        }
        
        if (.active == controlWord.AO) {
            outputRegisterA()
        }
        
        if (.active == controlWord.BO) {
            outputRegisterB()
        }
        
        if (.active == controlWord.LinkHiOut) {
            outputRegisterG()
        }
        
        if (.active == controlWord.LinkLoOut) {
            outputRegisterH()
        }
        
        if (.active == controlWord.XYInc) {
            incrementXY()
        }
        
        if (.active == controlWord.UVInc) {
            incrementUV()
        }
        
        if (.active == controlWord.J) {
            doJump()
        } else {
            incrementPC()
        }
        
        if (.active == controlWord.HLT) {
            logger?.append("HLT")
        }
        
        doPeripheralControlClock()
    }
    
    func latchFlagsRegister() {
        let prev = flags
        flags = Flags(aluFlags.carryFlag, aluFlags.equalFlag)
        logger?.append("FI -- flags changing from %@ to %@", prev, flags)
    }
    
    func outputRegisterA() {
        bus = Register(withValue: registerA.value)
        logger?.append("AO -- output %@ onto bus", bus)
    }
    
    func outputRegisterB() {
        bus = Register(withValue: registerB.value)
        logger?.append("BO -- output %@ onto bus", bus)
    }
    
    func outputRegisterC() {
        bus = Register(withValue: registerC.value)
        logger?.append("CO -- output %@ onto bus", bus)
    }
    
    func outputRegisterE() {
        bus = Register(withValue: aluResult.value)
        logger?.append("EO -- output %@ onto bus", bus)
    }
    
    func outputRegisterG() {
        bus = Register(withValue: registerG.value)
        logger?.append("LinkHiOut -- output %@ onto bus", bus)
    }
    
    func outputRegisterH() {
        bus = Register(withValue: registerH.value)
        logger?.append("LinkLoOut -- output %@ onto bus", bus)
    }
    
    func outputRegisterX() {
        bus = Register(withValue: registerX.value)
        logger?.append("XO -- output %@ onto bus", bus)
    }
    
    func outputRegisterY() {
        bus = Register(withValue: registerY.value)
        logger?.append("YO -- output %@ onto bus", bus)
    }
    
    func outputRegisterU() {
        bus = Register(withValue: registerU.value)
        logger?.append("UO -- output %@ onto bus", bus)
    }
    
    func outputRegisterV() {
        bus = Register(withValue: registerV.value)
        logger?.append("VO -- output %@ onto bus", bus)
    }
    
    public func incrementXY() {
        if registerY.value == 255 {
            registerX = Register(withValue: registerX.value &+ 1)
            registerY = Register(withValue: 0)
        } else {
            registerY = Register(withValue: registerY.value &+ 1)
        }
        logger?.append("XYInc -- Increment XY register pair. New value is 0x%@",
                       String(valueOfXYPair(), radix: 16))
    }

    public func incrementUV() {
        if registerV.value == 255 {
            registerU = Register(withValue: registerU.value &+ 1)
            registerV = Register(withValue: 0)
        } else {
            registerV = Register(withValue: registerV.value &+ 1)
        }
        logger?.append("XYInc -- Increment UV register pair. New value is 0x%@",
                       String(valueOfUVPair(), radix: 16))
    }
    
    func doJump() {
        pc = ProgramCounter(withValue: UInt16(valueOfXYPair()))
        logger?.append("J -- jump to %@", pc)
    }
    
    func incrementPC() {
        pc = pc.increment()
        logger?.append("PC -> %@", pc)
    }
    
    func outputDataRAM() {
        bus = Register(withValue: dataRAM.load(from: valueOfUVPair()))
        logger?.append("MO -- Load %@ from Data RAM at address 0x%@",
                       bus, String(valueOfUVPair(), radix: 16))
    }
    
    func doID() {
        registerC = Register(withValue: if_id.immediate)
        let opcode = Int(if_id.opcode)
        let b = instructionDecoder.load(opcode: opcode,
                                        carryFlag: flags.carryFlag,
                                        equalFlag: flags.equalFlag)
        controlWord = ControlWord(withValue: UInt(b))
    }
    
    func doIF() {
        let offset = 0x8000
        if pc_if.value < offset {
            if_id = instructionROM.load(from: pc_if.integerValue)
        } else {
            let opcode = Int(upperInstructionRAM.load(from: pc_if.integerValue - offset))
            let immediate = Int(lowerInstructionRAM.load(from: pc_if.integerValue - offset))
            if_id = Instruction(opcode: opcode, immediate: immediate)
        }
        logger?.append("IF/ID -> %@", if_id)
    }
    
    func doPCIF() {
        pc_if = ProgramCounter(withValue: pc.value)
        logger?.append("PC/IF -> %@", pc_if)
    }
    
    func doALU() {
        let a = registerA.value
        let b = registerB.value
        let c = registerC.value
        let alu = ALU()
        alu.s = (c & 0b1111)
        alu.mode = Int(c & 0b10000) >> 4
        alu.carryIn = (controlWord.CarryIn == .active) ? 0 : 1
        alu.a = a
        alu.b = b
        alu.update()
        
        if (.active==controlWord.EO || .active==controlWord.FI) {
            logger?.append("ALU operation with s = 0b%@, carryIn = %x, mode = %x, a = 0x%x, b = 0x%x. This yields result = 0x%x, carryFlag = %x, equalFlag = %x", String(alu.s, radix: 2), alu.carryIn, alu.mode, alu.a, alu.b, alu.result, alu.carryFlag, alu.equalFlag)
        }
        
        aluResult = Register(withValue: alu.result)
        aluFlags = Flags(alu.carryFlag, alu.equalFlag)
    }
    
    func doPeripheralControlClock() {
        peripherals.bus = bus
        peripherals.registerX = registerX
        peripherals.registerY = registerY
        peripherals.onControlClock()
        bus = peripherals.bus
    }
    
    func onRegisterClock() {
        if (.active == controlWord.YI) {
            inputRegisterY()
        }
        
        if (.active == controlWord.XI) {
            inputRegisterX()
        }
        
        if (.active == controlWord.VI) {
            inputRegisterV()
        }
        
        if (.active == controlWord.UI) {
            inputRegisterU()
        }
        
        if (.active == controlWord.AI) {
            inputRegisterA()
        }
        
        if (.active == controlWord.BI) {
            inputRegisterB()
        }
        
        if (.active == controlWord.DI) {
            inputRegisterD()
        }
        
        if (.active == controlWord.PI) {
            peripherals.activateSignalPI(registerD.integerValue)
        }
        
        if (.active == controlWord.MI) {
            inputDataRAM()
        }
        
        if (.active == controlWord.LinkIn) {
            inputLinkRegister()
        }
        
        doPeripheralRegisterClock()
    }
    
    func inputRegisterA() {
        logger?.append("AI -- input %@ from bus", bus)
        registerA = Register(withValue: bus.value)
    }
    
    func inputRegisterB() {
        logger?.append("BI -- input %@ from bus", bus)
        registerB = Register(withValue: bus.value)
    }
    
    func inputRegisterD() {
        registerD = Register(withValue: bus.value)
        let name = peripherals.getName(at: Int(registerD.value & 0b111))
        logger?.append("DI -- input %@ from bus. Selected peripheral is now \"%@\"",
                       registerD, name)
    }
    
    func inputRegisterX() {
        logger?.append("XI -- input %@ from bus", bus)
        registerX = Register(withValue: bus.value)
    }
    
    func inputRegisterY() {
        logger?.append("YI -- input %@ from bus", bus)
        registerY = Register(withValue: bus.value)
    }
    
    func inputRegisterU() {
        logger?.append("UI -- input %@ from bus", bus)
        registerU = Register(withValue: bus.value)
    }
    
    func inputRegisterV() {
        logger?.append("VI -- input %@ from bus", bus)
        registerV = Register(withValue: bus.value)
    }
    
    func inputDataRAM() {
        logger?.append("MI -- Store %@ to Data RAM at address 0x%@",
                       bus, String(valueOfUVPair(), radix: 16))
        dataRAM = dataRAM.withStore(value: bus.value, to:valueOfUVPair())
    }
    
    func inputLinkRegister() {
        registerG = Register(withValue: UInt8((pc.value >> 8) & 0xff))
        registerH = Register(withValue: UInt8(pc.value & 0xff))
        logger?.append("LinkIn -- Setting the Link register with PC value of 0x%@",
                       pc.stringValue)
    }
    
    fileprivate func doPeripheralRegisterClock() {
        peripherals.bus = bus
        peripherals.registerX = registerX
        peripherals.registerY = registerY
        peripherals.onRegisterClock()
    }
    
    public func execute() {
        reset()
        while (.inactive == controlWord.HLT) {
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
    
    public var cpuState: CPUStateSnapshot {
        return CPUStateSnapshot(bus: bus,
                                registerA: registerA,
                                registerB: registerB,
                                registerC: registerC,
                                registerD: registerD,
                                registerG: registerG, // LinkHi
                                registerH: registerH, // LinkLo
                                registerX: registerX,
                                registerY: registerY,
                                registerU: registerU,
                                registerV: registerV,
                                aluResult: aluResult,
                                aluFlags: aluFlags,
                                flags: flags,
                                pc: pc,
                                pc_if: pc_if,
                                if_id: if_id,
                                controlWord:controlWord)
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        peripherals.getSerialInterface().provideSerialInput(bytes: bytes)
    }
    
    func valueOfXYPair() -> Int {
        return registerX.integerValue<<8 | registerY.integerValue
    }

    func valueOfUVPair() -> Int {
        return registerU.integerValue<<8 | registerV.integerValue
    }
}
