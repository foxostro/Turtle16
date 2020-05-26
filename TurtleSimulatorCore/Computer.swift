//
//  Computer.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 1/22/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

// Simulates the behavior of the revision two of TurtleTTL hardware.
public class Computer: NSObject {
    public let cpuState = CPUStateSnapshot()
    public var dataRAM = Memory()
    public var upperInstructionRAM = Memory()
    public var lowerInstructionRAM = Memory()
    public var instructionMemory: InstructionMemory
    public var instructionDecoder: InstructionDecoder
    public let microcodeGenerator = MicrocodeGenerator()
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
    
    public var stopwatch: ComputerStopwatch? {
        didSet {
            if vm != nil {
                vm.stopwatch = stopwatch
            }
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
    public private(set) var serialInput: SerialInput!
    
    public var allowsRunningTraces = true
    public var shouldRecordStatesOverTime = false
    public var recordedStatesOverTime: [CPUStateSnapshot] {
        return vm.recordedStatesOverTime
    }
    var vm: VirtualMachine!
    
    // Raise this boolean flag to request execution stop on the next breakpoint.
    public let flagBreak = AtomicBooleanFlag()
    
    public init(toneGenerator: ToneGenerator? = nil) {
        microcodeGenerator.generate()
        instructionDecoder = microcodeGenerator.microcode
        
        instructionMemory = InstructionMemoryRev1(instructionROM: InstructionROM(),
                                                  upperInstructionRAM: upperInstructionRAM,
                                                  lowerInstructionRAM: lowerInstructionRAM,
                                                  instructionFormatter: instructionFormatter)
        
        super.init()
        
        let storeUpperInstructionRAM = {[weak self] (_ value: UInt8, _ address: Int) -> Void in
            guard let this = self else { return }
            this.upperInstructionRAM.store(value: value, to: address)
            this.vm?.didModifyInstructionMemory()
        }
        let loadUpperInstructionRAM = {[weak self] (_ address: Int) -> UInt8 in
             guard let this = self else { return 0 }
             return this.upperInstructionRAM.load(from: address)
        }
        let storeLowerInstructionRAM = {[weak self] (_ value: UInt8, _ address: Int) -> Void in
            guard let this = self else { return }
            this.lowerInstructionRAM.store(value: value, to: address)
            this.vm?.didModifyInstructionMemory()
        }
        let loadLowerInstructionRAM = {[weak self] (_ address: Int) -> UInt8 in
            guard let this = self else { return 0 }
            return this.lowerInstructionRAM.load(from: address)
        }
        peripherals.populate(storeUpperInstructionRAM,
                             loadUpperInstructionRAM,
                             storeLowerInstructionRAM,
                             loadLowerInstructionRAM,
                             toneGenerator: toneGenerator)
        let serialInterface = peripherals.getSerialInterface()
        serialInterface.didUpdateSerialOutput = didUpdateSerialOutput
        serialInput = serialInterface.serialInput
        
        rebuildVirtualMachine()
    }
    
    private func rebuildVirtualMachine() {
        let factory = ComputerVirtualMachineFactory()
        factory.cpuState = cpuState
        factory.microcodeGenerator = microcodeGenerator
        factory.peripherals = peripherals
        factory.dataRAM = dataRAM
        factory.instructionMemory = instructionMemory
        factory.flagBreak = flagBreak
        factory.allowsRunningTraces = allowsRunningTraces
        factory.shouldRecordStatesOverTime = shouldRecordStatesOverTime
        factory.stopwatch = stopwatch
        factory.logger = logger
        factory.interpreter = makeInterpreter()
        let vm = factory.makeVirtualMachine()
        self.vm = vm
    }
    
    func makeInterpreter() -> Interpreter {
        return Interpreter(cpuState: cpuState,
                           peripherals: peripherals,
                           dataRAM: dataRAM,
                           instructionDecoder: microcodeGenerator.microcode)
    }
    
    public func reset() {
        vm.reset()
    }
    
    public func runUntilHalted(maxSteps: Int = Int.max) throws {
        try vm.runUntilHalted(maxSteps: maxSteps)
    }
    
    public func singleStep() {
        vm.singleStep()
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
            let rom = Memory(data)
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
        let rom = InstructionROM(upperROM: Memory(upperData),
                                 lowerROM: Memory(lowerData))
        instructionMemory = InstructionMemoryRev1(instructionROM: rom,
                                                  upperInstructionRAM: upperInstructionRAM,
                                                  lowerInstructionRAM: lowerInstructionRAM,
                                                  instructionFormatter: instructionFormatter)
        rebuildVirtualMachine()
    }
}
