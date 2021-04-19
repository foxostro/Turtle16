//
//  OpcodeDecodeROMU25.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class OpcodeDecodeROMU25: HexDataTableViewDataSource {
    public override func load(address: Int) -> Int {
        Int(computer.opcodeDecodeROM[address] & 0xff)
    }
    
    public override var numberOfRows: Int {
        (1<<9)/0x10-1
    }
    
    public override var wordFormat: String {
        return "%02x"
    }
}
