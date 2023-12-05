//
//  InstructionMemoryLoTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 5/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleSimulatorCore

class InstructionMemoryLoTableViewDataSource: HexDataTableViewDataSource {
    public override func store(address: Int, value: Int) {
        let highByte: UInt16 = (computer.instructions[address] & 0xff00) >> 8
        computer.instructions[address] = highByte | UInt16(value)
    }
    
    public override func load(address: Int) -> Int {
        return Int(computer.instructions[address] & 0x00ff)
    }
    
    public override var numberOfRows: Int {
        (1<<16)/0x10-1
    }
    
    public override var wordFormat: String {
        return "%02x"
    }
}
