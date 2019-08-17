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
    public let outputDisplay: Register
    public let aluResult: Register
    public let aluFlags: Flags
    public let flags: Flags
    public let pc: ProgramCounter
    public let pc_if: ProgramCounter
    public let if_id: Instruction
    public let controlWord: ControlWord
    public var dataRAM: RAM
    public var upperInstructionRAM: RAM
    public var lowerInstructionRAM: RAM
    public var instructionROM: InstructionROM
    public var instructionDecoder: InstructionDecoder
    
    public override convenience init() {
        self.init(withBus: Register(),
                  withRegisterA: Register(),
                  withRegisterB: Register(),
                  withRegisterC: Register(),
                  withRegisterD: Register(),
                  withRegisterX: Register(),
                  withRegisterY: Register(),
                  withOutputDisplay: Register(),
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
                  withInstructionDecoder: InstructionDecoder())
    }
    
    public required init(withBus bus: Register,
                         withRegisterA registerA: Register,
                         withRegisterB registerB: Register,
                         withRegisterC registerC: Register,
                         withRegisterD registerD: Register,
                         withRegisterX registerX: Register,
                         withRegisterY registerY: Register,
                         withOutputDisplay outputDisplay: Register,
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
                         withInstructionDecoder instructionDecoder: InstructionDecoder) {
        self.bus = bus
        self.registerA = registerA
        self.registerB = registerB
        self.registerC = registerC
        self.registerD = registerD
        self.registerX = registerX
        self.registerY = registerY
        self.outputDisplay = outputDisplay
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
    }
    
    public func withBus(_ bus: UInt8) -> ComputerState {
        return ComputerState(withBus: Register(withValue: bus),
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withRegisterA(_ registerA: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: Register(withValue: registerA),
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withRegisterB(_ registerB: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: Register(withValue: registerB),
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withRegisterC(_ registerC: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: Register(withValue: registerC),
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withRegisterD(_ registerD: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: Register(withValue: registerD),
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withRegisterX(_ registerX: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: Register(withValue: registerX),
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withRegisterY(_ registerY: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: Register(withValue: registerY),
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withOutputDisplay(_ outputDisplay: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: Register(withValue: outputDisplay),
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withALUResult(_ aluResult: UInt8) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withALUFlags(_ aluFlags: Flags) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withFlags(_ flags: Flags) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withPC(_ pc: ProgramCounter) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withPCIF(_ pc_if: ProgramCounter) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withIFID(_ if_id: Instruction) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withControlWord(_ controlWord: ControlWord) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withDataRAM(_ dataRAM: RAM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withUpperInstructionRAM(_ upperInstructionRAM: RAM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withLowerInstructionRAM(_ lowerInstructionRAM: RAM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withInstructionROM(_ instructionROM: InstructionROM) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
    }
    
    public func withInstructionDecoder(_ instructionDecoder: InstructionDecoder) -> ComputerState {
        return ComputerState(withBus: bus,
                             withRegisterA: registerA,
                             withRegisterB: registerB,
                             withRegisterC: registerC,
                             withRegisterD: registerD,
                             withRegisterX: registerX,
                             withRegisterY: registerY,
                             withOutputDisplay: outputDisplay,
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
                             withInstructionDecoder: instructionDecoder)
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
