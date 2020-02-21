//
//  Trace.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class Trace: NSObject {
    static let formatter = InstructionFormatter()
    public typealias PC = UInt16
    
    public enum Element {
        case instruction(PC, Instruction)
        case guardFlags(PC, Flags)
        case guardAddress(PC, UInt16)
    }
    
    public private(set) var elements: [Element] = []
    
    public func append(pc: PC, instruction: Instruction) {
        elements.append(.instruction(pc, instruction))
    }
    
    public func appendGuard(pc: PC, flags: Flags) {
        elements.append(.guardFlags(pc, flags))
    }
    
    public func appendGuard(pc: PC, address: UInt16) {
        elements.append(.guardAddress(pc, address))
    }
    
    public override var description: String {
        var result = ""
        for el in elements {
            switch el {
            case .instruction(let pc, let ins):
                result += String(format: "0x%04x:\t%@", pc, Trace.formatter.format(instruction: ins))
            case .guardFlags(let pc, let flags):
                result += String(format: "guard:\tflags=%@, traceExitingPC=0x%04x", flags, pc)
            case .guardAddress(let pc, let address):
                result += String(format: "guard:\taddress=0x%04x, traceExitingPC=0x%04x", address, pc)
            }
            result += "\n"
        }
        return result
    }
}
