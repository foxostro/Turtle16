//
//  Computer.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Simulates the behavior of the TurtleTTL hardware.
public class Computer: NSObject {
    public var currentState: ComputerState
    public var logger:Logger? = nil
    let banks: [BankOperation]
    let lowerDecoderRomFilename = "Lower Decoder ROM.bin"
    let upperDecoderRomFilename = "Upper Decoder ROM.bin"
    let lowerInstructionROMFilename = "Lower Instruction ROM.bin"
    let upperInstructionROMFilename = "Upper Instruction ROM.bin"
    
    public override init() {
        currentState = ComputerState()
        banks = [BankOperation(),
                 BankOperation(name: "Output Display",
                               store: {(state: ComputerState) -> ComputerState in
                                return state.withOutputDisplay(state.bus.value)
                 }),
                 BankOperation(name: "Upper Instruction RAM",
                               store: {(state: ComputerState) -> ComputerState in
                                return state.withStoreToUpperInstructionRAM(value: state.bus.value, to: state.valueOfXYPair())
                 },
                               load: {(state: ComputerState) -> ComputerState in
                                return state.withBus(state.upperInstructionRAM.load(from: state.valueOfXYPair()))
                 }),
                 BankOperation(name: "Lower Instruction RAM",
                               store: {(state: ComputerState) -> ComputerState in
                                return state.withStoreToLowerInstructionRAM(value: state.bus.value, to: state.valueOfXYPair())
                 },
                               load: {(state: ComputerState) -> ComputerState in
                                return state.withBus(state.lowerInstructionRAM.load(from: state.valueOfXYPair()))
                 }),
                 BankOperation(name: "Data RAM",
                               store: {(state: ComputerState) -> ComputerState in
                                return state.withStoreToDataRAM(value: state.bus.value, to: state.valueOfXYPair())
                 },
                               load: {(state: ComputerState) -> ComputerState in
                                return state.withBus(state.dataRAM.load(from: state.valueOfXYPair()))
                 }),
                 BankOperation(),
                 BankOperation(),
                 BankOperation()]
    }
    
    public func reset() {
        currentState = currentState.reset()
    }
    
    public func step() {
        var updatedState = currentState
        updatedState = doID(withState: updatedState)
        updatedState = doIF(withState: updatedState)
        updatedState = doPCIF(withState: updatedState)
        updatedState = doALU(withState: updatedState)
        updatedState = doEX(withState: updatedState)
        currentState = updatedState
        logger?.append("-----")
    }
    
    func doPCIF(withState currentState: ComputerState) -> ComputerState {
        let pc_if = currentState.pc
        logger?.append("PC/IF -> %@", pc_if)
        return currentState.withPCIF(pc_if)
    }
    
    func doIF(withState currentState: ComputerState) -> ComputerState {
        let offset = 0x8000
        let pc_if = Int(currentState.pc_if.value)
        let if_id: Instruction
        if pc_if < offset {
            if_id = currentState.instructionROM.load(from: pc_if)
        } else {
            let opcode = Int(currentState.upperInstructionRAM.load(from: pc_if - offset))
            let immediate = Int(currentState.lowerInstructionRAM.load(from: pc_if - offset))
            if_id = Instruction(opcode: opcode, immediate: immediate)
        }
        
        logger?.append("IF/ID -> %@", if_id)
        return currentState.withIFID(if_id)
    }
    
    func doID(withState currentState: ComputerState) -> ComputerState {
        let registerC = currentState.if_id.immediate
        let opcode = Int(currentState.if_id.opcode)
        let decoder = currentState.instructionDecoder
        let b = decoder.load(opcode: opcode,
                             carryFlag: currentState.flags.carryFlag,
                             equalFlag: currentState.flags.equalFlag)
        let controlWord = ControlWord(withValue: UInt(b))
        return currentState
            .withRegisterC(registerC)
            .withControlWord(controlWord)
    }
    
    func doALU(withState currentState: ComputerState) -> ComputerState {
        let a = currentState.registerA.value
        let b = currentState.registerB.value
        let c = currentState.registerC.value
        let alu = ALU()
        alu.s = c
        alu.carryIn = Int(c & 0b10000) >> 4
        alu.mode = Int(c & 0b100000) >> 5
        alu.a = a
        alu.b = b
        alu.update()
        let aluResult = alu.result
        let aluFlags = Flags(alu.carryFlag, alu.equalFlag)
        
        if (!currentState.controlWord.EO || !currentState.controlWord.FI) {
            logger?.append("ALU operation with s = 0b%@, carryIn = %x, mode = %x, a = 0x%x, b = 0x%x. This yields result = 0x%x, carryFlag = %x, equalFlag = %x", String(alu.s, radix: 2), alu.carryIn, alu.mode, alu.a, alu.b, alu.result, alu.carryFlag, alu.equalFlag)
        }
        
        return currentState
            .withALUResult(aluResult)
            .withALUFlags(aluFlags)
    }
    
    func doEX(withState oldState: ComputerState) -> ComputerState {
        var state = oldState
        
        logger?.append("Executing control word %@", state.controlWord)
        if (false == state.controlWord.CO) {
            let bus = state.registerC.value
            state = state.withBus(bus)
            logger?.append("CO -- output %@ onto bus", state.bus)
        }
        if (false == state.controlWord.YO) {
            let bus = state.registerY.value
            state = state.withBus(bus)
            logger?.append("YO -- output %@ onto bus", state.bus)
        }
        if (false == state.controlWord.XO) {
            let bus = state.registerX.value
            state = state.withBus(bus)
            logger?.append("XO -- output %@ onto bus", state.bus)
        }
        if (false == state.controlWord.MO) {
            let currentBank = banks[Int(state.registerD.value)]
            var updatedState = state.withBus(0) // ensure bus is invalidated
            updatedState = currentBank.load(updatedState)
            logger?.append("MO -- Load %@ from current bank, \"%@\", at address 0x%@",
                           updatedState.bus,
                           currentBank.name,
                           String(state.valueOfXYPair(), radix: 16))
            state = updatedState
        }
        if (false == state.controlWord.EO) {
            let bus = state.aluResult.value
            state = state.withBus(bus)
            logger?.append("EO -- output %@ onto bus", state.bus)
        }
        if (false == state.controlWord.FI) {
            let updatedState = state.withFlags(state.aluFlags)
            logger?.append("FI -- flags changing from %@ to %@",
                           state.flags, updatedState.flags)
            state = updatedState
        }
        if (false == state.controlWord.AO) {
            let bus = state.registerA.value
            state = state.withBus(bus)
            logger?.append("AO -- output %@ onto bus", state.bus)
        }
        if (false == state.controlWord.BO) {
            let bus = state.registerB.value
            state = state.withBus(bus)
            logger?.append("BO -- output %@ onto bus", state.bus)
        }
        
        if (false == state.controlWord.YI) {
            logger?.append("YI -- input %@ from bus", state.bus)
            state = state.withRegisterY(state.bus.value)
        }
        if (false == state.controlWord.XI) {
            logger?.append("XI -- input %@ from bus", state.bus)
            state = state.withRegisterX(state.bus.value)
        }
        if (false == state.controlWord.AI) {
            logger?.append("AI -- input %@ from bus", state.bus)
            state = state.withRegisterA(state.bus.value)
        }
        if (false == state.controlWord.BI) {
            logger?.append("BI -- input %@ from bus", state.bus)
            state = state.withRegisterB(state.bus.value)
        }
        if (false == state.controlWord.DI) {
            state = state.withRegisterD(state.bus.value)
            let currentBank = banks[Int(state.registerD.value & 0b111)]
            logger?.append("DI -- input %@ from bus. Selected bank is now \"%@\"",
                           state.registerD, currentBank.name)
        }
        if (false == state.controlWord.MI) {
            let currentBank = banks[Int(state.registerD.value)]
            logger?.append("MI -- Store %@ to current bank, \"%@\", at address 0x%@",
                           state.bus,
                           currentBank.name,
                           String(state.valueOfXYPair(), radix: 16))
            state = currentBank.store(state)
        }
        if (false == state.controlWord.J) {
            let pc = ProgramCounter(withValue: UInt16(state.valueOfXYPair()))
            state = state.withPC(pc)
            logger?.append("J -- jump to %@", state.pc)
        } else {
            let pc = state.pc.increment()
            state = state.withPC(pc)
            logger?.append("PC -> %@", state.pc)
        }
        if (false == state.controlWord.HLT) {
            logger?.append("HLT")
        }
        
        return state
    }
    
    public func execute() {
        reset()
        while (true == currentState.controlWord.HLT) {
            step()
        }
    }
    
    public func provideInstructions(_ instructions: [Instruction]) {
        currentState = currentState.withStoreToInstructionROM(instructions: instructions)
    }
    
    public func saveMicrocode(to: URL) throws {
        // Use minipro on the command-line to flash the binary file to EEPROM:
        //   % minipro -p SST29EE010 -y -w ./file.bin
        let lowerDecoderROM = currentState.instructionDecoder.lowerROM.data
        let upperDecoderROM = currentState.instructionDecoder.upperROM.data
        
        try FileManager.default.createDirectory(at: to,
                                                withIntermediateDirectories: false,
                                                attributes: [:])
        try lowerDecoderROM.write(to: to.appendingPathComponent(lowerDecoderRomFilename))
        try upperDecoderROM.write(to: to.appendingPathComponent(upperDecoderRomFilename))
    }
    
    public func loadMicrocode(from: URL) throws {
        let lowerData = try Data(contentsOf: from.appendingPathComponent(lowerDecoderRomFilename) as URL)
        let upperData = try Data(contentsOf: from.appendingPathComponent(upperDecoderRomFilename) as URL)
        
        let decoder = InstructionDecoder(withUpperROM: Memory(withData: upperData),
                                         withLowerROM: Memory(withData: lowerData))
        
        provideMicrocode(microcode: decoder)
    }
    
    public func provideMicrocode(microcode: InstructionDecoder) {
        currentState = currentState.withInstructionDecoder(microcode)
    }
    
    public func saveProgram(to: URL) throws {
        // Use minipro on the command-line to flash the binary file to EEPROM:
        //   % minipro -p SST29EE010 -y -w ./file.bin
        let lowerROM = currentState.instructionROM.lowerROM.data
        let upperROM = currentState.instructionROM.upperROM.data
        
        try FileManager.default.createDirectory(at: to,
                                                withIntermediateDirectories: false,
                                                attributes: [:])
        try lowerROM.write(to: to.appendingPathComponent(lowerInstructionROMFilename))
        try upperROM.write(to: to.appendingPathComponent(upperInstructionROMFilename))
    }
    
    public func loadProgram(from: URL) throws {
        let lowerData = try Data(contentsOf: from.appendingPathComponent(lowerInstructionROMFilename) as URL)
        let upperData = try Data(contentsOf: from.appendingPathComponent(upperInstructionROMFilename) as URL)
        
        let rom = InstructionROM(withUpperROM: Memory(withData: upperData),
                                 withLowerROM: Memory(withData: lowerData))
        
        currentState = currentState.withInstructionROM(rom)
    }
    
    public func modifyRegisterA(withString s: String) {
        if let value = UInt8(s, radix: 16) {
            currentState = currentState.withRegisterA(value)
        }
    }
    
    public func modifyRegisterB(withString s: String) {
        if let value = UInt8(s, radix: 16) {
            currentState = currentState.withRegisterB(value)
        }
    }
    
    public func modifyRegisterC(withString s: String) {
        if let value = UInt8(s, radix: 16) {
            currentState = currentState.withRegisterC(value)
        }
    }
    
    public func modifyRegisterD(withString s: String) {
        if let value = UInt8(s, radix: 16) {
            currentState = currentState.withRegisterD(value)
        }
    }
    
    public func modifyRegisterX(withString s: String) {
        if let value = UInt8(s, radix: 16) {
            currentState = currentState.withRegisterX(value)
        }
    }
    
    public func modifyRegisterY(withString s: String) {
        if let value = UInt8(s, radix: 16) {
            currentState = currentState.withRegisterY(value)
        }
    }
    
    public func modifyPC(withString s: String) {
        if let value = ProgramCounter(withStringValue: s) {
            currentState = currentState.withPC(value)
        }
    }
    
    public func modifyPCIF(withString s: String) {
        if let value = ProgramCounter(withStringValue: s) {
            currentState = currentState.withPCIF(value)
        }
    }
    
    public func modifyIFID(withString s: String) {
        if let value = Instruction(s) {
            currentState = currentState.withIFID(value)
        }
    }
    
    public func describeRegisterA() -> String {
        return currentState.registerA.description
    }
    
    public func describeRegisterB() -> String {
        return currentState.registerB.description
    }
    
    public func describeRegisterC() -> String {
        return currentState.registerC.description
    }
    
    public func describeRegisterD() -> String {
        return currentState.registerD.description
    }
    
    public func describeRegisterX() -> String {
        return currentState.registerX.description
    }
    
    public func describeRegisterY() -> String {
        return currentState.registerY.description
    }
    
    public func describeALUResult() -> String {
        return currentState.aluResult.description
    }
    
    public func describeControlWord() -> String {
        return currentState.controlWord.stringValue
    }
    
    public func describeControlSignals() -> String {
        return currentState.controlWord.description
    }
    
    public func describePC() -> String {
        return currentState.pc.description
    }
    
    public func describeIFID() -> String {
        return currentState.if_id.description
    }
    
    public func describeBus() -> String {
        return currentState.bus.description
    }
    
    public func describeOutputDisplay() -> String {
        return String(currentState.outputDisplay.value, radix: 10)
    }
}
