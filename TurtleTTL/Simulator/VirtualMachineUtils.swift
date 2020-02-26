//
//  VirtualMachineUtils.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 2/26/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class VirtualMachineUtils: NSObject {
    public static func makeInstructionROM(program: String) -> InstructionROM {
        return InstructionROM().withStore(TraceUtils.assemble(program))
    }
}
