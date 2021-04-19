//
//  DataMemoryTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class DataMemoryTableViewDataSource: HexDataTableViewDataSource {
    public override func store(address: Int, value: Int) {
        computer.ram[address] = UInt16(value)
    }
    
    public override func load(address: Int) -> Int {
        return Int(computer.ram[address])
    }
    
    public override var numberOfRows: Int {
        (1<<16)/0x10-1
    }
}
