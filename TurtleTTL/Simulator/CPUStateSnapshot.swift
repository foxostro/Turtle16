//
//  CPUStateSnapshot.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/11/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public class CPUStateSnapshot: NSObject {
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
        if_id = Instruction()
        controlWord = ControlWord()
    }
    
    public init(bus: Register,
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
        return CPUStateSnapshot(bus: bus,
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
        if let rhs = rhs as? CPUStateSnapshot {
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
}

public func ==(lhs: CPUStateSnapshot, rhs: CPUStateSnapshot) -> Bool {
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
