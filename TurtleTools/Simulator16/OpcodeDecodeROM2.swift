//
//  OpcodeDecodeROM2.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleSimulatorCore

class OpcodeDecodeROM2: HexDataTableViewDataSource {
    public override func load(address: Int) -> Int {
        Int((computer.decoder.decode(address) >> 8) & 0xff)
    }
    
    public override var numberOfRows: Int {
        (1<<9)/0x10-1
    }
    
    public override var wordFormat: String {
        return "%02x"
    }
}
