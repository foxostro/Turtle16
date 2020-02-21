//
//  InstructionFormatter.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/20/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class InstructionFormatter: NSObject {
    let microcodeGenerator = MicrocodeGenerator()
    
    public override init() {
        microcodeGenerator.generate()
    }
    
    public func format(instruction: Instruction) -> String {
        let maybeMnemonic = microcodeGenerator.getMnemonic(withOpcode: Int(instruction.opcode))
        guard var mnemonic = maybeMnemonic else { return "UNKNOWN" }
        if mnemonic.hasPrefix("ALU") {
            switch instruction.immediate {
            case 0b0110:
                return "CMP"
            case 0b1001:
                mnemonic = "ADD" + mnemonic.dropFirst(3)
                return mnemonic
            default:
                return mnemonic
            }
        }
        return mnemonic
    }
}
