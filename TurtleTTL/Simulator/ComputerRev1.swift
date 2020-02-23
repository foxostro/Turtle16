//
//  ComputerRev1.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Simulates the behavior of the "revision one" TurtleTTL hardware.
public class ComputerRev1: NSObject, Computer, InterpreterDelegate {
    public let cpuState = CPUStateSnapshot()
    public var dataRAM = RAM()
    public var upperInstructionRAM = RAM()
    public var lowerInstructionRAM = RAM()
    public var instructionROM = InstructionROM()
    public var instructionDecoder: InstructionDecoder {
        get {
            return interpreter.instructionDecoder
        }
        set(microcode) {
            interpreter.instructionDecoder = microcode
        }
    }
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
    public let interpreter: Interpreter
    
    public override init() {
        interpreter = Interpreter(cpuState: cpuState, instructionDecoder: InstructionDecoder())
        
        super.init()
        
        interpreter.delegate = self
        
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
    }
    
    public func reset() {
        interpreter.reset()
    }
    
    public func runUntilHalted() {
        while .inactive == cpuState.controlWord.HLT {
            step()
        }
    }
    
    public func step() {
        peripherals.resetControlSignals()
        interpreter.step()
        peripherals.onPeripheralClock()
        logger?.append("-----")
    }
    
    public func didTickControlClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onControlClock()
        cpuState.bus = peripherals.bus
    }
    
    public func didTickRegisterClock() {
        peripherals.bus = cpuState.bus
        peripherals.registerX = cpuState.registerX
        peripherals.registerY = cpuState.registerY
        peripherals.onRegisterClock()
    }
    
    public func willJump(from: ProgramCounter, to: ProgramCounter) {
        let oldPC = from.value
        let newPC = to.value
        if newPC < oldPC {
            let hasBecomeHot = profiler.hit(pc: newPC)
            if hasBecomeHot {
                logger?.append("Jump destination \(newPC) has become hot.")
            }
        }
    }
    
    public func fetchInstruction(from pc: ProgramCounter) -> Instruction {
        let offset = 0x8000
        let instruction: Instruction
        if pc.value < offset {
            instruction = instructionROM.load(from: cpuState.pc_if.integerValue)
        } else {
            let opcode = Int(upperInstructionRAM.load(from: pc.integerValue - offset))
            let immediate = Int(lowerInstructionRAM.load(from: pc.integerValue - offset))
            instruction = Instruction(opcode: opcode, immediate: immediate)
        }
        logger?.append("Fetched instruction from memory -> %@", instruction)
        return instruction
    }
    
    public func storeToRAM(value: UInt8, at address: Int) {
        logger?.append("Store 0x%02x to Data RAM at address 0x%04x", value, address)
        dataRAM = dataRAM.withStore(value: value, to: address)
    }
    
    public func loadFromRAM(at address: Int) -> UInt8 {
        let value = dataRAM.load(from: address)
        logger?.append("Load from Data RAM at address 0x%04x -> 0x%02x", address, value)
        return value
    }
    
    public func storeToPeripheral(cpuState state: CPUStateSnapshot) {
        peripherals.activateSignalPI(state.registerD.integerValue)
    }
    
    public func loadFromPeripheral(cpuState state: CPUStateSnapshot) {
        peripherals.activateSignalPO(state.registerD.integerValue)
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
}
