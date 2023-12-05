//
//  DisassemblyTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 6/7/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleSimulatorCore

class DisassemblyTableViewDataSource: NSObject, NSTableViewDataSource {
    public let computer: Turtle16Computer
    
    let kNumberOfRows = 65535
    let kAddressIdentifier = NSUserInterfaceItemIdentifier("Address")
    let kWordIdentifier = NSUserInterfaceItemIdentifier("Word")
    let kLabelIdentifier = NSUserInterfaceItemIdentifier("Label")
    let kMnemonicIdentifier = NSUserInterfaceItemIdentifier("Mnemonic")
    
    public init(computer: Turtle16Computer) {
        self.computer = computer
        super.init()
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
            let entries = computer.disassembly.entries
            if row < entries.count, let label = entries[row].label {
                return label + ":"
            }
            return ""
            
        case kMnemonicIdentifier:
            let entries = computer.disassembly.entries
            if row < entries.count, let mnemonic = entries[row].mnemonic {
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
}
