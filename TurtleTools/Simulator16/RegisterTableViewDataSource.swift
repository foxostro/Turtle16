//
//  RegisterTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class RegisterTableViewDataSource: NSObject, NSTableViewDataSource {
    public let computer: Turtle16Computer
    
    let kNumberOfRows = 9
    let kRegIdentifier = NSUserInterfaceItemIdentifier("Reg")
    let kHexIdentifier = NSUserInterfaceItemIdentifier("Hex")
    let kDecIdentifier = NSUserInterfaceItemIdentifier("Dec")
    
    public init(computer: Turtle16Computer) {
        self.computer = computer
    }
    
    public func tableView(_ tableView: NSTableView,
                          objectValueFor tableColumn: NSTableColumn?,
                          row: Int) -> Any? {
        switch tableColumn?.identifier {
        case kRegIdentifier:
            return (row == kNumberOfRows-1) ? "pc" : "r\(row)"
            
        case kHexIdentifier:
            let value = (row == kNumberOfRows-1) ? computer.pc : computer.getRegister(row)
            return String(format: "%04x", value)
            
        case kDecIdentifier:
            let value = (row == kNumberOfRows-1) ? computer.pc : computer.getRegister(row)
            return value
            
        default:
            return nil
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return kNumberOfRows
    }
}
