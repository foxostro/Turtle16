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
}
