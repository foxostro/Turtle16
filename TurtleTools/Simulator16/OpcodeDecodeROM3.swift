//
//  OpcodeDecodeROM3.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/19/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class OpcodeDecodeROM3: HexDataTableViewDataSource {
    public override func load(address: Int) -> Int {
        Int((computer.decoder.decode(address) >> 16) & 0x1f)
    }
    
    public override var numberOfRows: Int {
        (1<<9)/0x10-1
    }
    
    public override var wordFormat: String {
        return "%02x"
    }
}
