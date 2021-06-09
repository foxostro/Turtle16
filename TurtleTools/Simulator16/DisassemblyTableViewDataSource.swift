//
//  DisassemblyTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 6/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class DisassemblyTableViewDataSource: NSObject, NSTableViewDataSource {
    public let computer: Turtle16Computer
    public private(set) var disassembly: [Disassembler.Entry] = []
    
    let kNumberOfRows = 65535
    let kAddressIdentifier = NSUserInterfaceItemIdentifier("Address")
    let kWordIdentifier = NSUserInterfaceItemIdentifier("Word")
    let kLabelIdentifier = NSUserInterfaceItemIdentifier("Label")
    let kMnemonicIdentifier = NSUserInterfaceItemIdentifier("Mnemonic")
    
    public init(computer: Turtle16Computer) {
        self.computer = computer
        super.init()
        regenerateDisassembly()
    }
    
    public func tableView(_ tableView: NSTableView,
                          objectValueFor tableColumn: NSTableColumn?,
                          row: Int) -> Any? {
        switch tableColumn?.identifier {
        case kAddressIdentifier:
            return String(format: "%04x", row)
            
        case kWordIdentifier:
            return String(format: "%04x", computer.instructions[row])
            
        case kLabelIdentifier:
            if row < disassembly.count, let label = disassembly[row].label {
                return label + ":"
            }
            return ""
            
        case kMnemonicIdentifier:
            if row < disassembly.count, let mnemonic = disassembly[row].mnemonic {
                return mnemonic
            }
            return ""
            
        default:
            return nil
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return kNumberOfRows
    }
    
    func regenerateDisassembly() {
        let disassembler = Disassembler()
        disassembly = disassembler.disassemble(computer.instructions)
    }
}
