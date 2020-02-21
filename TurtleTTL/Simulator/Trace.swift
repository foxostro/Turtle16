//
//  Trace.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class Trace: NSObject {
    let formatter = InstructionFormatter()
    
    public enum Element {
        case instruction(Instruction)
        case guardFlags(Flags)
        case guardAddress(UInt16)
    }
    
    public private(set) var elements: [Element] = []
    
    public func append(instruction: Instruction) {
        elements.append(.instruction(instruction))
    }
    
    public func appendGuard(flags: Flags) {
        elements.append(.guardFlags(flags))
    }
    
    public func appendGuard(address: UInt16) {
        elements.append(.guardAddress(address))
    }
    
    public override var description: String {
        var result = ""
        for el in elements {
            switch el {
            case .instruction(let ins):
                result += formatter.format(instruction: ins)
            case .guardFlags(let flags):
                result += "guard<flags=\(flags)>"
            case .guardAddress(let address):
                result += "guard<address=0x" + String(address, radix: 16) + ">"
            }
            result += "\n"
        }
        return result
    }
}
