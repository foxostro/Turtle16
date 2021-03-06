//
//  Trace.swift
//  TurtleSimulatorCore
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import TurtleCore

public class Trace: NSObject {
    public private(set) var instructions: [Instruction] = []
    public private(set) var pc: ProgramCounter? = nil
    
    public func append(_ instruction: Instruction) {
        if pc == nil {
            pc = instruction.pc
        }
        instructions.append(instruction)
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
            result += "\(ins.pc): \(ins.disassembly ?? ins.description)"
            
            if ins.guardFail {
                result += " ; guardFail=true"
            }
            
            if let address = ins.guardAddress {
                result += String(format: " ; guardAddress=0x%04x", address)
            }
            
            if let flags = ins.guardFlags {
                result += String(format: " ; guardFlags=\(flags)")
            }
            
            if ins.isBreakpoint {
                result += " ; isBreakpoint=true"
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
    
    public static func ==(lhs: Trace, rhs: Trace) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        guard rhs != nil else { return false }
        guard type(of: rhs!) == type(of: self) else { return false }
        guard let rhs = rhs as? Trace else { return false }
        guard instructions == rhs.instructions else { return false }
        return true
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(instructions)
        return hasher.finalize()
    }
}
