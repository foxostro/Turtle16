//
//  CPUStateSnapshot.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/11/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public struct CPUStateSnapshot {
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
}
