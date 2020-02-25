//
//  Trace.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class Trace: NSObject {
    public private(set) var instructions: [Instruction] = []
    public var pc: ProgramCounter? {
        return instructions.first?.pc
    }
    
    public func append(instruction: Instruction) {
        instructions.append(instruction)
    }
    
    public func appendGuard(pc: ProgramCounter, fail: Bool) {
        append(instruction: Instruction(opcode: 0,
                                        immediate: 0,
                                        disassembly: "NOP",
                                        pc: pc,
                                        guardFail: fail))
    }
    
    public func appendGuard(pc: ProgramCounter,
                            flags: Flags,
                            address: UInt16) {
        append(instruction: Instruction(opcode: 0,
                                        immediate: 0,
                                        disassembly: "NOP",
                                        pc: pc,
                                        guardFlags: flags,
                                        guardAddress: address))
    }
    
    public func appendGuard(pc: ProgramCounter, address: UInt16) {
        append(instruction: Instruction(opcode: 0,
                                        immediate: 0,
                                        disassembly: "NOP",
                                        pc: pc,
                                        guardFlags: nil,
                                        guardAddress: address))
    }
    
    public override var description: String {
        var result = ""
        for ins in instructions {
            result += "\(ins.pc): \(ins)"
            
            if let guardFail = ins.guardFail {
                result += " ; guardFail=\(guardFail)"
            }
            
            if let address = ins.guardAddress {
                result += String(format: " ; guardAddress=0x%04x", address)
            }
            
            if let flags = ins.guardFlags {
                result += String(format: " ; guardFlags=\(flags)")
            }
            
            result += "\n"
        }
        result.removeLast()
        return result
    }
}
