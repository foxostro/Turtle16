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
    public private(set) var pc: ProgramCounter? = nil
    
    public func append(instruction: Instruction) {
        if pc == nil {
            pc = instruction.pc
        }
        instructions.append(instruction)
    }
    
    public func appendGuard(instruction: Instruction, fail: Bool) {
        append(instruction: instruction.withGuard(fail: fail))
    }
    
    public func appendGuard(instruction: Instruction,
                            flags: Flags,
                            address: UInt16) {
        append(instruction: instruction.withGuard(flags: flags).withGuard(address: address))
    }
    
    public func appendGuard(instruction: Instruction, address: UInt16) {
        append(instruction: instruction.withGuard(address: address))
    }
    
    public func fetchInstruction(from pc: ProgramCounter) -> Instruction? {
        if let offset = self.pc?.integerValue {
            let index = pc.integerValue - offset
            if index < instructions.count {
                return instructions[index]
            }
        }
        return nil
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
        if result.count > 0 {
            result.removeLast()
        }
        return result
    }
    
    public override func copy() -> Any {
        let theCopy = Trace()
        theCopy.pc = pc
        theCopy.instructions = instructions
        return theCopy
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? Trace {
            return self == rhs
        }
        return false
    }
}

public func ==(lhs: Trace, rhs: Trace) -> Bool {
    return lhs.instructions == rhs.instructions
}
