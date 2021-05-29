//
//  InstructionMemoryHiTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 5/28/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class InstructionMemoryHiTableViewDataSource: HexDataTableViewDataSource {
    public override func store(address: Int, value: Int) {
        let lowByte: UInt16 = computer.instructions[address] & 0x00ff
        computer.instructions[address] = UInt16(value<<8) | lowByte
    }
    
    public override func load(address: Int) -> Int {
        return Int((computer.instructions[address] & 0xff00) >> 8)
    }
    
    public override var numberOfRows: Int {
        (1<<16)/0x10-1
    }
    
    public override var wordFormat: String {
        return "%02x"
    }
}
