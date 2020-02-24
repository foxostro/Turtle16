//
//  Trace.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class Trace: NSObject {
    public typealias Address = UInt16
    public enum Element {
        case instruction(ProgramCounter, Instruction)
        case guardFlags(ProgramCounter, Flags)
        case guardAddress(ProgramCounter, Address)
    }
    
    public private(set) var pc: ProgramCounter? = nil
    public private(set) var elements: [Element] = []
    
    public func append(pc: ProgramCounter, instruction: Instruction) {
        if elements.isEmpty {
            self.pc = pc
        }
        elements.append(.instruction(pc, instruction))
    }
    
    public func appendGuard(pc: ProgramCounter, flags: Flags) {
        if elements.isEmpty {
            self.pc = pc
        }
        elements.append(.guardFlags(pc, flags))
    }
    
    public func appendGuard(pc: ProgramCounter, address: Address) {
        if elements.isEmpty {
            self.pc = pc
        }
        elements.append(.guardAddress(pc, address))
    }
    
    public override var description: String {
        var result = ""
        for el in elements {
            switch el {
            case .instruction(let pc, let ins):
                result += String(format: "0x%04x:\t%@", pc.value, ins)
            case .guardFlags(let pc, let flags):
                result += String(format: "guard:\tflags=%@, traceExitingPC=0x%04x", flags, pc.value)
            case .guardAddress(let pc, let address):
                result += String(format: "guard:\taddress=0x%04x, traceExitingPC=0x%04x", address, pc.value)
            }
            result += "\n"
        }
        result.removeLast()
        return result
    }
}
