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
    let instructionFormatter = InstructionFormatter()
    let interpreter: Interpreter
    var peripherals = ComputerPeripherals()
    let profiler = TraceProfiler()
    let traceCache = NSCache<ProgramCounter, Trace>()
    var traceRecorder: TraceRecorder? = nil
    
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
        // TODO: Is it a problem to allocate a state object every tick?
        let prevState = cpuState.copy() as! CPUStateSnapshot
        
        enforceTraceRecorderPolicy(prevState)
        
        peripherals.resetControlSignals()
        interpreter.step()
        peripherals.onPeripheralClock()
        
        // Log changes in the state.
        if let logger = logger {
            logCPUStateChanges(logger: logger,
                               prevState: prevState,
                               nextState: cpuState)
        }
        
        // Record backwards jumps.
        let oldPC = prevState.pc.value
        let newPC = cpuState.pc.value
        if newPC < oldPC {
            let hasBecomeHot = profiler.hit(pc: newPC)
            if hasBecomeHot {
                logger?.append("Jump destination \(cpuState.pc) has become hot.")
            }
        }
        
        // Update the trace if we're recording one now.
        traceRecorder?.record(instruction: prevState.if_id,
                              stateBefore: prevState,
                              stateAfter: cpuState)
        
        logger?.append("-----")
    }
    
    fileprivate func enforceTraceRecorderPolicy(_ prevState: CPUStateSnapshot) {
        let pc = prevState.if_id.pc
        
        // If the instruction is hot then check to see if we have a
        // corresponding trace. If so then execute that. Else, begin recording.
        if let traceRecorder = traceRecorder {
            if traceRecorder.trace.pc! == pc || traceCache.doesContain(pc) {
                // The next instruction corresponds to an existing trace.
                // So, this is a good point to finish the current trace.
                let trace = traceRecorder.trace
                traceCache.setObject(trace, forKey: trace.pc!)
                self.traceRecorder = nil
                logger?.append("Finished recording trace for pc=\(trace.pc!):\n\(trace)", trace.pc!, trace)
            }
        }
        
        if let trace = traceCache.object(forKey: pc) {
            // We have a trace for the next instruction and we should
            // execute that now.
            logger?.append("TODO: we should execute the cached trace for pc=\(pc):\n\(trace)")
        } else if (traceRecorder == nil) && profiler.isHot(pc: pc.value) {
            // The instruction is hot but we don't have a trace for it.
            // Begin recording now.
            traceRecorder = TraceRecorder()
            logger?.append("Beginning trace recording for for pc=\(pc)")
        }
    }
    
    fileprivate func logCPUStateChanges(logger: Logger,
                                        prevState: CPUStateSnapshot,
                                        nextState: CPUStateSnapshot) {
        if prevState.pc != nextState.pc {
            logger.append("pc: 0x%04x --> 0x%04x", prevState.pc.value, nextState.pc.value)
        }
        if prevState.pc_if != nextState.pc_if {
            logger.append("pc_if: 0x%04x --> 0x%04x", prevState.pc_if.value, nextState.pc_if.value)
        }
        if prevState.if_id != nextState.if_id {
            logger.append("if_id: %@ --> %@", prevState.if_id, nextState.if_id)
        }
        if prevState.controlWord != nextState.controlWord {
            logger.append("controlWord: 0x%04x --> 0x%04x", prevState.controlWord.unsignedIntegerValue, nextState.controlWord.unsignedIntegerValue)
            logger.append("controlSignals: %@ --> %@", prevState.controlWord, nextState.controlWord)
        }
        if prevState.registerA != nextState.registerA {
            logger.append("registerA: 0x%02x --> 0x%02x", prevState.registerA.value, nextState.registerA.value)
        }
        if prevState.registerB != nextState.registerB {
            logger.append("registerB: 0x%02x --> 0x%02x", prevState.registerB.value, nextState.registerB.value)
        }
        if prevState.registerC != nextState.registerC {
            logger.append("registerC: 0x%02x --> 0x%02x", prevState.registerC.value, nextState.registerC.value)
        }
        if prevState.registerD != nextState.registerD {
            logger.append("registerD: 0x%02x --> 0x%02x", prevState.registerD.value, nextState.registerD.value)
        }
        if prevState.registerG != nextState.registerG {
            logger.append("registerG: 0x%02x --> 0x%02x", prevState.registerG.value, nextState.registerG.value)
        }
        if prevState.registerH != nextState.registerH {
            logger.append("registerH: 0x%02x --> 0x%02x", prevState.registerH.value, nextState.registerH.value)
        }
        if prevState.registerX != nextState.registerX {
            logger.append("registerX: 0x%02x --> 0x%02x", prevState.registerX.value, nextState.registerX.value)
        }
        if prevState.registerY != nextState.registerY {
            logger.append("registerY: 0x%02x --> 0x%02x", prevState.registerY.value, nextState.registerY.value)
        }
        if prevState.registerU != nextState.registerU {
            logger.append("registerU: 0x%02x --> 0x%02x", prevState.registerU.value, nextState.registerU.value)
        }
        if prevState.registerV != nextState.registerV {
            logger.append("registerV: 0x%02x --> 0x%02x", prevState.registerV.value, nextState.registerV.value)
        }
        if prevState.flags != nextState.flags {
            logger.append("flags: %@ --> %@", prevState.flags, nextState.flags)
        }
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
    
    public func fetchInstruction(from pc: ProgramCounter) -> Instruction {
        let offset = 0x8000
        
        let temp: Instruction
        if pc.value < offset {
            temp = instructionROM.load(from: cpuState.pc_if.integerValue)
        } else {
            let opcode = Int(upperInstructionRAM.load(from: pc.integerValue - offset))
            let immediate = Int(lowerInstructionRAM.load(from: pc.integerValue - offset))
            temp = Instruction(opcode: opcode, immediate: immediate)
        }

        let disassembly = instructionFormatter.format(instruction: temp)
        let instruction = Instruction(opcode: temp.opcode,
                                      immediate: temp.immediate,
                                      disassembly: disassembly,
                                      pc: pc)
        
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
    
    public func activateSignalPO(_ index: Int) {
        peripherals.activateSignalPO(cpuState.registerD.integerValue)
    }
    
    public func activateSignalPI(_ index: Int) {
        peripherals.activateSignalPI(cpuState.registerD.integerValue)
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
