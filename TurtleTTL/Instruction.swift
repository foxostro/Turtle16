//
//  Instruction.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

// An instruction loaded from instruction memory.
// Each instruction is a sixteen bit value composed of an eight-bit opcode and
// an eight-bit immediate value.
public class Instruction: NSObject {
    public let opcode: UInt8
    public let immediate: UInt8
    public let disassembly: String
    
    public static func makeBasicDescription(opcode: UInt8, immediate: UInt8) -> String {
        return String(format: "{op=0b%@, imm=0b%@}",
                      String(opcode, radix: 2),
                      String(immediate, radix: 2))
    }
    
    public override convenience init() {
        self.init(opcode: 0, immediate: 0)
    }
    
    public convenience init(opcode: Int, immediate: Int, disassembly: String? = nil) {
        self.init(opcode: UInt8(opcode),
                  immediate: UInt8(immediate),
                  disassembly: disassembly)
    }
    
    public init(opcode: UInt8, immediate: UInt8, disassembly: String? = nil) {
        self.opcode = opcode
        self.immediate = immediate
        self.disassembly = disassembly ?? Instruction.makeBasicDescription(opcode: opcode, immediate: immediate)
    }
    
    public init?(_ stringValue: String) {
        let pattern = "\\{op=0b([10]+), imm=0b([10]+)\\}"
        let regex = try! NSRegularExpression(pattern: pattern)
        let maybeMatch = regex.firstMatch(in: stringValue, options: [], range: NSRange(stringValue.startIndex..., in: stringValue))
        
        if let match = maybeMatch {
            let opcodeString = String(stringValue[Range(match.range(at: 1), in: stringValue)!])
            let maybeOpcode = UInt8(opcodeString, radix: 2)
            if let opcode = maybeOpcode {
                self.opcode = opcode
            } else {
                return nil
            }
            
            let immediateString = String(stringValue[Range(match.range(at: 2), in: stringValue)!])
            let maybeImmediate = UInt8(immediateString, radix: 2)
            if let immediate = maybeImmediate {
                self.immediate = immediate
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        self.disassembly = stringValue
    }
    
    public var value:UInt16 {
        return UInt16(Int(opcode) << 8 | Int(immediate))
    }
    
    public override var description: String {
        return disassembly
    }
    
    public override func isEqual(_ rhs: Any?) -> Bool {
        if let rhs = rhs as? Instruction {
            return self == rhs
        } else {
            return false
        }
    }
}

public func ==(lhs: Instruction, rhs: Instruction) -> Bool {
    return lhs.value == rhs.value
}
