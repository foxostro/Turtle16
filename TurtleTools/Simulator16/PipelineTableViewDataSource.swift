//
//  PipelineTableViewDataSource.swift
//  Simulator16
//
//  Created by Andrew Fox on 6/9/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class PipelineTableViewDataSource: NSObject, NSTableViewDataSource {
    public let computer: Turtle16Computer
    
    let kNameIdentifier = NSUserInterfaceItemIdentifier("Stage")
    let kProgramCounterIdentifier = NSUserInterfaceItemIdentifier("PC")
    let kDisassemblyIdentifier = NSUserInterfaceItemIdentifier("Disassembly")
    let kStatusIdentifier = NSUserInterfaceItemIdentifier("Status")
    
    public init(computer: Turtle16Computer) {
        self.computer = computer
    }
    
    public func tableView(_ tableView: NSTableView,
                          objectValueFor tableColumn: NSTableColumn?,
                          row: Int) -> Any? {
        switch tableColumn?.identifier {
        case kNameIdentifier:
            return computer.cpu.getPipelineStageInfo(row).name
            
        case kProgramCounterIdentifier:
            if let pc = computer.cpu.getPipelineStageInfo(row).pc {
                return String(format: "%04x", pc)
            } else {
                return ""
            }
            
        case kDisassemblyIdentifier:
            let disassembledInstruction: String?
            if let pc = computer.cpu.getPipelineStageInfo(row).pc {
                disassembledInstruction = computer.disassembly.entries.first(where: { $0.address == pc })?.mnemonic
            } else {
                disassembledInstruction = nil
            }
            return disassembledInstruction ?? ""
            
        case kStatusIdentifier:
            return computer.cpu.getPipelineStageInfo(row).status
            
        default:
            return nil
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return computer.cpu.numberOfPipelineStages
    }
}
