//
//  ProcessorState.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/11/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class ProcessorState: NSObject {
    public var uptime: Int
    public var bus: Register
    public var registerA: Register
    public var registerB: Register
    public var registerC: Register
    public var registerD: Register
    public var registerG: Register // LinkHi
    public var registerH: Register // LinkLo
    public var registerX: Register
    public var registerY: Register
    public var registerU: Register
    public var registerV: Register
    public var aluResult: Register
    public var aluFlags: Flags
    public var flags: Flags
    public var pc: ProgramCounter
    public var pc_if: ProgramCounter
    public var if_id: Instruction
    public var controlWord: ControlWord
    
    public override init() {
        uptime = 0
        bus = Register()
        registerA = Register()
        registerB = Register()
        registerC = Register()
        registerD = Register()
        registerG = Register()
        registerH = Register()
        registerX = Register()
        registerY = Register()
        registerU = Register()
        registerV = Register()
        aluResult = Register()
        aluFlags = Flags()
        flags = Flags()
        pc = ProgramCounter()
        pc_if = ProgramCounter()
        if_id = Instruction.makeNOP()
        controlWord = ControlWord()
    }
    
    public init(uptime: Int,
                bus: Register,
                registerA: Register,
                registerB: Register,
                registerC: Register,
                registerD: Register,
                registerG: Register,
                registerH: Register,
                registerX: Register,
                registerY: Register,
                registerU: Register,
                registerV: Register,
                aluResult: Register,
                aluFlags: Flags,
                flags: Flags,
                pc: ProgramCounter,
                pc_if: ProgramCounter,
                if_id: Instruction,
                controlWord: ControlWord) {
        self.uptime = uptime
        self.bus = bus
        self.registerA = registerA
        self.registerB = registerB
        self.registerC = registerC
        self.registerD = registerD
        self.registerG = registerG
        self.registerH = registerH
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
    }
    
    public override func copy() -> Any {
        return ProcessorState(uptime: uptime,
                                bus: bus,
                                registerA: registerA,
                                registerB: registerB,
                                registerC: registerC,
                                registerD: registerD,
                                registerG: registerG,
                                registerH: registerH,
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
                                controlWord: controlWord)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? ProcessorState {
            return self == rhs
        } else {
            return false
        }
    }
    
    public func valueOfXYPair() -> Int {
        return registerX.integerValue<<8 | registerY.integerValue
    }

    public func valueOfUVPair() -> Int {
        return registerU.integerValue<<8 | registerV.integerValue
    }
    
    public static func logChanges(logger: Logger,
                                  prevState: ProcessorState,
                                  nextState: ProcessorState) {
        if prevState.uptime != nextState.uptime {
            logger.append("uptime: \(prevState.uptime) --> \(nextState.uptime)")
        }
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
}

public func ==(lhs: ProcessorState, rhs: ProcessorState) -> Bool {
    guard lhs.uptime == rhs.uptime else {
        return false
    }
    guard lhs.bus == rhs.bus else {
        return false
    }
    guard lhs.registerA == rhs.registerA else {
        return false
    }
    guard lhs.registerB == rhs.registerB else {
        return false
    }
    guard lhs.registerC == rhs.registerC else {
        return false
    }
    guard lhs.registerD == rhs.registerD else {
        return false
    }
    guard lhs.registerG == rhs.registerG else {
        return false
    }
    guard lhs.registerH == rhs.registerH else {
        return false
    }
    guard lhs.registerX == rhs.registerX else {
        return false
    }
    guard lhs.registerY == rhs.registerY else {
        return false
    }
    guard lhs.registerU == rhs.registerU else {
        return false
    }
    guard lhs.registerV == rhs.registerV else {
        return false
    }
    guard lhs.aluResult == rhs.aluResult else {
        return false
    }
    guard lhs.aluFlags == rhs.aluFlags else {
        return false
    }
    guard lhs.flags == rhs.flags else {
        return false
    }
    guard lhs.pc == rhs.pc else {
        return false
    }
    guard lhs.pc_if == rhs.pc_if else {
        return false
    }
    guard lhs.if_id == rhs.if_id else {
        return false
    }
    guard lhs.controlWord == rhs.controlWord else {
        return false
    }
    return true
}
