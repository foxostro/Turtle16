//
//  CPUStateSnapshot.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 2/11/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class CPUStateSnapshot: NSObject {
    public var uptime: UInt64
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
    public var aluResultBuffer: Register
    public var aluResult: Register
    public var aluFlagsBuffer: Flags
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
        aluResultBuffer = Register()
        aluResult = Register()
        aluFlagsBuffer = Flags()
        aluFlags = Flags()
        flags = Flags()
        pc = ProgramCounter()
        pc_if = ProgramCounter()
        if_id = Instruction.makeNOP()
        controlWord = ControlWord()
    }
    
    public init(uptime: UInt64,
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
                aluResultBuffer: Register,
                aluResult: Register,
                aluFlagsBuffer: Flags,
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
        self.aluResultBuffer = aluResultBuffer
        self.aluResult = aluResult
        self.aluFlagsBuffer = aluFlagsBuffer
        self.aluFlags = aluFlags
        self.flags = flags
        self.pc = pc
        self.pc_if = pc_if
        self.if_id = if_id
        self.controlWord = controlWord
    }
    
    public override func copy() -> Any {
        return CPUStateSnapshot(uptime: uptime,
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
                                aluResultBuffer: aluResultBuffer,
                                aluResult: aluResult,
                                aluFlagsBuffer: aluFlagsBuffer,
                                aluFlags: aluFlags,
                                flags: flags,
                                pc: pc,
                                pc_if: pc_if,
                                if_id: if_id,
                                controlWord: controlWord)
    }
    
    public static func ==(lhs: CPUStateSnapshot, rhs: CPUStateSnapshot) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? CPUStateSnapshot else { return false }
        guard uptime == rhs.uptime else { return false }
        guard bus == rhs.bus else { return false }
        guard registerA == rhs.registerA else { return false }
        guard registerB == rhs.registerB else { return false }
        guard registerC == rhs.registerC else { return false }
        guard registerD == rhs.registerD else { return false }
        guard registerG == rhs.registerG else { return false }
        guard registerH == rhs.registerH else { return false }
        guard registerX == rhs.registerX else { return false }
        guard registerY == rhs.registerY else { return false }
        guard registerU == rhs.registerU else { return false }
        guard registerV == rhs.registerV else { return false }
        guard aluResultBuffer == rhs.aluResultBuffer else { return false }
        guard aluResult == rhs.aluResult else { return false }
        guard aluFlagsBuffer == rhs.aluFlagsBuffer else { return false }
        guard aluFlags == rhs.aluFlags else { return false }
        guard flags == rhs.flags else { return false }
        guard pc == rhs.pc else { return false }
        guard pc_if == rhs.pc_if else { return false }
        guard if_id == rhs.if_id else { return false }
        guard controlWord == rhs.controlWord else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(uptime)
        hasher.combine(bus)
        hasher.combine(registerA)
        hasher.combine(registerB)
        hasher.combine(registerC)
        hasher.combine(registerD)
        hasher.combine(registerG)
        hasher.combine(registerH)
        hasher.combine(registerX)
        hasher.combine(registerY)
        hasher.combine(registerU)
        hasher.combine(registerV)
        hasher.combine(aluResultBuffer)
        hasher.combine(aluResult)
        hasher.combine(aluFlagsBuffer)
        hasher.combine(aluFlags)
        hasher.combine(flags)
        hasher.combine(pc)
        hasher.combine(pc_if)
        hasher.combine(if_id)
        hasher.combine(controlWord)
        return hasher.finalize()
    }
    
    public func valueOfXYPair() -> Int {
        return registerX.integerValue<<8 | registerY.integerValue
    }

    public func valueOfUVPair() -> Int {
        return registerU.integerValue<<8 | registerV.integerValue
    }
    
    public static func logChanges(logger: Logger,
                                  prevState: CPUStateSnapshot,
                                  nextState: CPUStateSnapshot) {
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
        } else {
            logger.append("if_id: %@ (unchanged)", nextState.if_id)
        }
        if prevState.controlWord != nextState.controlWord {
            logger.append("controlWord: 0x%04x --> 0x%04x", prevState.controlWord.unsignedIntegerValue, nextState.controlWord.unsignedIntegerValue)
            logger.append("controlSignals: %@ --> %@", prevState.controlWord, nextState.controlWord)
        }
        if prevState.registerA != nextState.registerA {
            logger.append("registerA: 0x%02x --> 0x%02x", prevState.registerA.value, nextState.registerA.value)
        } else {
            logger.append("registerA: 0x%02x (unchanged)", nextState.registerA.value)
        }
        if prevState.registerB != nextState.registerB {
            logger.append("registerB: 0x%02x --> 0x%02x", prevState.registerB.value, nextState.registerB.value)
        } else {
            logger.append("registerB: 0x%02x (unchanged)", nextState.registerB.value)
        }
        if prevState.registerC != nextState.registerC {
            logger.append("registerC: 0x%02x --> 0x%02x", prevState.registerC.value, nextState.registerC.value)
        } else {
            logger.append("registerC: 0x%02x (unchanged)", nextState.registerC.value)
        }
        if prevState.registerD != nextState.registerD {
            logger.append("registerD: 0x%02x --> 0x%02x", prevState.registerD.value, nextState.registerD.value)
        } else {
            logger.append("registerD: 0x%02x (unchanged)", nextState.registerD.value)
        }
        if prevState.registerG != nextState.registerG {
            logger.append("registerG: 0x%02x --> 0x%02x", prevState.registerG.value, nextState.registerG.value)
        }
        if prevState.registerH != nextState.registerH {
            logger.append("registerH: 0x%02x --> 0x%02x", prevState.registerH.value, nextState.registerH.value)
        }
        if prevState.registerX != nextState.registerX {
            logger.append("registerX: 0x%02x --> 0x%02x", prevState.registerX.value, nextState.registerX.value)
        } else {
            logger.append("registerX: 0x%02x (unchanged)", nextState.registerX.value)
        }
        if prevState.registerY != nextState.registerY {
            logger.append("registerY: 0x%02x --> 0x%02x", prevState.registerY.value, nextState.registerY.value)
        } else {
            logger.append("registerY: 0x%02x (unchanged)", nextState.registerY.value)
        }
        if prevState.registerU != nextState.registerU {
            logger.append("registerU: 0x%02x --> 0x%02x", prevState.registerU.value, nextState.registerU.value)
        } else {
            logger.append("registerU: 0x%02x (unchanged)", nextState.registerU.value)
        }
        if prevState.registerV != nextState.registerV {
            logger.append("registerV: 0x%02x --> 0x%02x", prevState.registerV.value, nextState.registerV.value)
        } else {
            logger.append("registerV: 0x%02x (unchanged)", nextState.registerV.value)
        }
        if prevState.aluResultBuffer != nextState.aluResultBuffer {
            logger.append("aluResultBuffer: %@ --> %@", prevState.aluResultBuffer, nextState.aluResultBuffer)
        }
        if prevState.aluResult != nextState.aluResult {
            logger.append("aluResult: %@ --> %@", prevState.aluResult, nextState.aluResult)
        }
        if prevState.aluFlagsBuffer != nextState.aluFlagsBuffer {
            logger.append("aluFlagsBuffer: %@ --> %@", prevState.aluFlagsBuffer, nextState.aluFlagsBuffer)
        }
        if prevState.aluFlags != nextState.aluFlags {
            logger.append("aluFlags: %@ --> %@", prevState.aluFlags, nextState.aluFlags)
        }
        if prevState.flags != nextState.flags {
            logger.append("flags: %@ --> %@", prevState.flags, nextState.flags)
        }
    }
}
