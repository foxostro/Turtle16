//
//  ComputerState.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/12/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// Snapshot of the state of the TurtleTTL hardware between clock ticks.
public class ComputerState: NSObject {
    public let bus: Register
    public let registerA: Register
    public let registerB: Register
    public let registerC: Register
    public let registerD: Register
    public let registerX: Register
    public let registerY: Register
    public let registerU: Register
    public let registerV: Register
    public let aluResult: Register
    public let aluFlags: Flags
    public let flags: Flags
    public let pc: ProgramCounter
    public let pc_if: ProgramCounter
    public let if_id: Instruction
    public let controlWord: ControlWord
    public let dataRAM: RAM
    public let upperInstructionRAM: RAM
    public let lowerInstructionRAM: RAM
    public let instructionROM: InstructionROM
    public let instructionDecoder: InstructionDecoder
    
    // This is input provided to TurtleTTL from the serial connection.
    // The serial interface module outputs these bytes to the bus.
    public let serialInput: [UInt8]
    
    // This is output provided to the remote computer on the serial connection.
    // The serial interface module inputs these bytes from the bus.
    public let serialOutput: [UInt8]
    
    public override convenience init() {
        self.init(withBus: Register(),
                  withRegisterA: Register(),
                  withRegisterB: Register(),
                  withRegisterC: Register(),
                  withRegisterD: Register(),
                  withRegisterX: Register(),
                  withRegisterY: Register(),
                  withRegisterU: Register(),
                  withRegisterV: Register(),
                  withALUResult: Register(),
                  withALUFlags: Flags(),
                  withFlags: Flags(),
                  withPC: ProgramCounter(),
                  withPCIF: ProgramCounter(),
                  withIFID: Instruction(),
                  withControlWord: ControlWord(),
                  withDataRAM: RAM(),
                  withUpperInstructionRAM: RAM(),
                  withLowerInstructionRAM: RAM(),
                  withInstructionROM: InstructionROM(),
                  withInstructionDecoder: InstructionDecoder(),
                  withSerialInput: [],
                  withSerialOutput: [])
    }
    
    public required init(withBus bus: Register,
                         withRegisterA registerA: Register,
                         withRegisterB registerB: Register,
                         withRegisterC registerC: Register,
                         withRegisterD registerD: Register,
                         withRegisterX registerX: Register,
                         withRegisterY registerY: Register,
                         withRegisterU registerU: Register,
                         withRegisterV registerV: Register,
                         withALUResult aluResult: Register,
                         withALUFlags aluFlags: Flags,
                         withFlags flags: Flags,
                         withPC pc: ProgramCounter,
                         withPCIF pc_if: ProgramCounter,
                         withIFID if_id: Instruction,
                         withControlWord controlWord: ControlWord,
                         withDataRAM dataRAM: RAM,
                         withUpperInstructionRAM upperInstructionRAM: RAM,
                         withLowerInstructionRAM lowerInstructionRAM: RAM,
                         withInstructionROM instructionROM: InstructionROM,
                         withInstructionDecoder instructionDecoder: InstructionDecoder,
                         withSerialInput serialInput: [UInt8],
                         withSerialOutput serialOutput: [UInt8]) {
        self.bus = bus
        self.registerA = registerA
        self.registerB = registerB
        self.registerC = registerC
        self.registerD = registerD
        self.registerX = registerX
        self.registerY = registerY
        self.registerU = registerU
        self.registerV = registerV
        self.aluResult = aluResult
        self.aluFlags = aluFlags
        self.flags = flags
        self.pc = pc
        self.pc_if = pc_if
        self.if_id = if_id
        self.controlWord = controlWord
        self.dataRAM = dataRAM
        self.upperInstructionRAM = upperInstructionRAM
        self.lowerInstructionRAM = lowerInstructionRAM
        self.instructionROM = instructionROM
        self.instructionDecoder = instructionDecoder
        self.serialInput = serialInput
        self.serialOutput = serialOutput
    }
    
    public func withBus(_ bus: UInt8) -> ComputerState {
        return ComputerState(withBus: Register(withValue: bus),
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterA(_ registerA: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: Register(withValue: registerA),
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterB(_ registerB: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: Register(withValue: registerB),
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterC(_ registerC: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: Register(withValue: registerC),
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterD(_ registerD: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: Register(withValue: registerD),
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterX(_ registerX: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: Register(withValue: registerX),
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterY(_ registerY: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: Register(withValue: registerY),
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterU(_ registerU: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: Register(withValue: registerU),
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withRegisterV(_ registerV: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: Register(withValue: registerV),
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withALUResult(_ aluResult: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: Register(withValue: aluResult),
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withALUFlags(_ aluFlags: Flags) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withFlags(_ flags: Flags) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withPC(_ pc: ProgramCounter) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withPCIF(_ pc_if: ProgramCounter) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withIFID(_ if_id: Instruction) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withControlWord(_ controlWord: ControlWord) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withDataRAM(_ dataRAM: RAM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withUpperInstructionRAM(_ upperInstructionRAM: RAM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withLowerInstructionRAM(_ lowerInstructionRAM: RAM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withInstructionROM(_ instructionROM: InstructionROM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withInstructionDecoder(_ instructionDecoder: InstructionDecoder) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withSerialInput(_ serialInput: [UInt8]) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withSerialOutput(_ serialOutput: [UInt8]) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withRegisterU: registerU,
                             withRegisterV: registerV,
                             withALUResult: aluResult,
                             withALUFlags: aluFlags,
                             withFlags: flags,
                             withPC: pc,
                             withPCIF: pc_if,
                             withIFID: if_id,
                             withControlWord: controlWord,
                             withDataRAM: dataRAM,
                             withUpperInstructionRAM: upperInstructionRAM,
                             withLowerInstructionRAM: lowerInstructionRAM,
                             withInstructionROM: instructionROM,
                             withInstructionDecoder: instructionDecoder,
                             withSerialInput: serialInput,
                             withSerialOutput: serialOutput)
    }
    
    public func withStoreToDataRAM(value: UInt8, to address: Int) -> ComputerState {
        let updated = dataRAM.withStore(value: value, to: address)
        return self.withDataRAM(updated)
    }
    
    public func withStoreToUpperInstructionRAM(value: UInt8, to address: Int) -> ComputerState {
        let updated = upperInstructionRAM.withStore(value: value, to: address)
        return self.withUpperInstructionRAM(updated)
    }
    
    public func withStoreToLowerInstructionRAM(value: UInt8, to address: Int) -> ComputerState {
        let updated = lowerInstructionRAM.withStore(value: value, to: address)
        return self.withLowerInstructionRAM(updated)
    }
    
    public func withStoreToInstructionROM(instructions: [Instruction]) -> ComputerState {
        let updated = instructionROM.withStore(instructions)
        return self.withInstructionROM(updated)
    }
    
    public func reset() -> ComputerState {
        return self
            .withBus(0)
            .withPC(ProgramCounter())
            .withPCIF(ProgramCounter())
            .withIFID(Instruction())
            .withControlWord(ControlWord())
    }
    
    func valueOfXYPair() -> Int {
        return Int(registerX.value)<<8 | Int(registerY.value)
    }
}
