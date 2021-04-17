//
//  DataMemoryTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/16/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class DataMemoryTableViewDataSource: NSObject, NSTableViewDataSource {
    public let computer: Turtle16Computer
    
    let kNumberOfRows = (1<<16)/0x10-1
    let kColumnIdentifierAddress = NSUserInterfaceItemIdentifier("Address")
    let kColumnIdentifierZero = NSUserInterfaceItemIdentifier("zero")
    let kColumnIdentifierOne = NSUserInterfaceItemIdentifier("one")
    let kColumnIdentifierTwo = NSUserInterfaceItemIdentifier("two")
    let kColumnIdentifierThree = NSUserInterfaceItemIdentifier("three")
    let kColumnIdentifierFour = NSUserInterfaceItemIdentifier("four")
    let kColumnIdentifierFive = NSUserInterfaceItemIdentifier("five")
    let kColumnIdentifierSix = NSUserInterfaceItemIdentifier("six")
    let kColumnIdentifierSeven = NSUserInterfaceItemIdentifier("seven")
    let kColumnIdentifierEight = NSUserInterfaceItemIdentifier("eight")
    let kColumnIdentifierNine = NSUserInterfaceItemIdentifier("nine")
    let kColumnIdentifierA = NSUserInterfaceItemIdentifier("a")
    let kColumnIdentifierB = NSUserInterfaceItemIdentifier("b")
    let kColumnIdentifierC = NSUserInterfaceItemIdentifier("c")
    let kColumnIdentifierD = NSUserInterfaceItemIdentifier("d")
    let kColumnIdentifierE = NSUserInterfaceItemIdentifier("e")
    let kColumnIdentifierF = NSUserInterfaceItemIdentifier("f")
    let kColumnIdentifierText = NSUserInterfaceItemIdentifier("Text")
    
    public init(computer: Turtle16Computer) {
        self.computer = computer
    }
    
    public func tableView(_ tableView: NSTableView,
                          objectValueFor tableColumn: NSTableColumn?,
                          row: Int) -> Any? {
        switch tableColumn?.identifier {
        case kColumnIdentifierAddress:
            return String(format: "%04x", row*16)
            
        case kColumnIdentifierZero:
            return String(format: "%04x", computer.ram[row*16+0])
            
        case kColumnIdentifierOne:
            return String(format: "%04x", computer.ram[row*16+1])
            
        case kColumnIdentifierTwo:
            return String(format: "%04x", computer.ram[row*16+2])
            
        case kColumnIdentifierThree:
            return String(format: "%04x", computer.ram[row*16+3])
            
        case kColumnIdentifierFour:
            return String(format: "%04x", computer.ram[row*16+4])
            
        case kColumnIdentifierFive:
            return String(format: "%04x", computer.ram[row*16+5])
            
        case kColumnIdentifierSix:
            return String(format: "%04x", computer.ram[row*16+6])
            
        case kColumnIdentifierSeven:
            return String(format: "%04x", computer.ram[row*16+7])
            
        case kColumnIdentifierEight:
            return String(format: "%04x", computer.ram[row*16+8])
            
        case kColumnIdentifierNine:
            return String(format: "%04x", computer.ram[row*16+9])
            
        case kColumnIdentifierA:
            return String(format: "%04x", computer.ram[row*16+10])
            
        case kColumnIdentifierB:
            return String(format: "%04x", computer.ram[row*16+11])
            
        case kColumnIdentifierC:
            return String(format: "%04x", computer.ram[row*16+12])
            
        case kColumnIdentifierD:
            return String(format: "%04x", computer.ram[row*16+13])
            
        case kColumnIdentifierE:
            return String(format: "%04x", computer.ram[row*16+14])
            
        case kColumnIdentifierF:
            return String(format: "%04x", computer.ram[row*16+15])
            
        case kColumnIdentifierText:
            let words = computer.ram[(row*16)...(row*16+15)]
            var bytes: [UInt8] = []
            for word in words {
                bytes.append(UInt8(word >> 8) & 0xff)
                bytes.append(UInt8(word & 0xff))
            }
            let text = bytes.map { (byte: UInt8) -> String in
                (byte >= 32 && byte < 126) ? String(UnicodeScalar(byte)) : "."
            }.joined(separator: "")
            return text
            
        default:
            return nil
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return kNumberOfRows
    }
}
