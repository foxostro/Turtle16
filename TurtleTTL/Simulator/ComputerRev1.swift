//
//  ComputerRev1.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Simulates the behavior of the "revision one" TurtleTTL hardware.
public class ComputerRev1: NSObject, Computer {
    public let cpuState = CPUStateSnapshot()
    public var dataRAM = Memory()
    public var upperInstructionRAM = Memory()
    public var lowerInstructionRAM = Memory()
    public var instructionMemory: InstructionMemory
    public var instructionDecoder = InstructionDecoder()
    public let instructionFormatter = InstructionFormatter()
    
    var internalLogger:Logger? = nil
    public var logger:Logger? {
        get {
            return internalLogger
        }
        set(newLogger) {
            internalLogger = newLogger
            peripherals.logger = newLogger
            vm.logger = logger
        }
    }
    
    var internaDidUpdateSerialOutput:(String)->Void = {_ in}
    public var didUpdateSerialOutput:(String)->Void {
        get {
            return internaDidUpdateSerialOutput
        }
        set(value) {
            peripherals.getSerialInterface().didUpdateSerialOutput = value
        }
    }
    
    let decoderRomFilenameFormat = "Decoder ROM %d.bin"
    let lowerInstructionROMFilename = "Lower Instruction ROM.bin"
    let upperInstructionROMFilename = "Upper Instruction ROM.bin"
    let peripherals = ComputerPeripherals()
    
    public var allowsRunningTraces = true
    public var shouldRecordStatesOverTime = false
    public var recordedStatesOverTime: [CPUStateSnapshot] {
        return vm.recordedStatesOverTime
    }
    var vm: VirtualMachine! = nil
    
    public override init() {
        instructionMemory = InstructionMemoryRev1(instructionROM: InstructionROM(),
                                                  upperInstructionRAM: upperInstructionRAM,
                                                  lowerInstructionRAM: lowerInstructionRAM,
                                                  instructionFormatter: instructionFormatter)
        
        super.init()
        
        let storeUpperInstructionRAM = {(_ value: UInt8, _ address: Int) -> Void in
            self.upperInstructionRAM.store(value: value, to: address)
        }
        let loadUpperInstructionRAM = {(_ address: Int) -> UInt8 in
             return self.upperInstructionRAM.load(from: address)
        }
        let storeLowerInstructionRAM = {(_ value: UInt8, _ address: Int) -> Void in
            self.lowerInstructionRAM.store(value: value, to: address)
        }
        let loadLowerInstructionRAM = {(_ address: Int) -> UInt8 in
            return self.lowerInstructionRAM.load(from: address)
        }
        peripherals.populate(storeUpperInstructionRAM,
                             loadUpperInstructionRAM,
                             storeLowerInstructionRAM,
                             loadLowerInstructionRAM)
        peripherals.getSerialInterface().didUpdateSerialOutput = didUpdateSerialOutput
        
        rebuildVirtualMachine()
    }
    
    fileprivate func rebuildVirtualMachine() {
        let vm = TracingInterpretingVM(cpuState: cpuState,
                                       instructionDecoder: instructionDecoder,
                                       peripherals: peripherals,
                                       dataRAM: dataRAM,
                                       instructionMemory: instructionMemory)
        vm.allowsRunningTraces = allowsRunningTraces
        vm.shouldRecordStatesOverTime = shouldRecordStatesOverTime
        vm.logger = logger
        self.vm = vm
    }
    
    public func reset() {
        vm.reset()
    }
    
    public func runUntilHalted(maxSteps: Int = Int.max) throws {
        try vm.runUntilHalted(maxSteps: maxSteps)
    }
    
    public func step() {
        vm.step()
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        instructionMemory.store(instructions: instructions)
        rebuildVirtualMachine()
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
            let rom = Memory(data: data)
            roms.append(rom)
        }
        let decoder = InstructionDecoder(withROM: roms)
        provideMicrocode(microcode: decoder)
    }
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        instructionDecoder = microcode
        rebuildVirtualMachine()
    }
    
    public func saveProgram(to: URL) throws {
        // Use minipro on the command-line to flash the binary file to EEPROM:
        //   % minipro -p SST29EE010 -y -w ./file.bin
        let lowerROM = instructionMemory.lowerROMData
        let upperROM = instructionMemory.upperROMData
        
        try FileManager.default.createDirectory(at: to,
                                                withIntermediateDirectories: true,
                                                attributes: [:])
        try lowerROM.write(to: to.appendingPathComponent(lowerInstructionROMFilename))
        try upperROM.write(to: to.appendingPathComponent(upperInstructionROMFilename))
    }
    
    public func loadProgram(from: URL) throws {
        let lowerData = try Data(contentsOf: from.appendingPathComponent(lowerInstructionROMFilename) as URL)
        let upperData = try Data(contentsOf: from.appendingPathComponent(upperInstructionROMFilename) as URL)
        let rom = InstructionROM(upperROM: Memory(data: upperData),
                                 lowerROM: Memory(data: lowerData))
        instructionMemory = InstructionMemoryRev1(instructionROM: rom,
                                               upperInstructionRAM: upperInstructionRAM,
                                               lowerInstructionRAM: lowerInstructionRAM,
                                               instructionFormatter: instructionFormatter)
        rebuildVirtualMachine()
    }
    
    public func provideSerialInput(bytes: [UInt8]) {
        peripherals.getSerialInterface().provideSerialInput(bytes: bytes)
    }
}
