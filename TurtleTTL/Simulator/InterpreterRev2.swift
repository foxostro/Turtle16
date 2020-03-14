//
//  InterpreterRev2.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 3/14/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Cocoa

public class InterpreterRev2: InterpreterRev1 {
    // The Rev2 hardware loads the LINK register from PC/IF. This fixes a
    // hardware bug in Rev1 which broke the JALR instruction.
    override func handleControlSignalLinkIn() {
        if (.active == cpuState.controlWord.LinkIn) {
            cpuState.registerG = Register(withValue: UInt8((cpuState.pc_if.value >> 8) & 0xff))
            cpuState.registerH = Register(withValue: UInt8(cpuState.pc_if.value & 0xff))
        }
    }
}
