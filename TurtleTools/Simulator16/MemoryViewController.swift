//
//  MemoryViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/18/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleSimulatorCore

class MemoryViewController: NSViewController {
    @IBOutlet var memoryTabSelector: NSPopUpButton!
    @IBOutlet var memoryTabView: NSTabView!
    
    public let debugger: DebugConsole
    public var hexDataViewControllers: [HexDataViewController] = []
    
    let kInstructionMemoryIdentifier = NSUserInterfaceItemIdentifier("InstructionMemory")
    let kInstructionMemoryHiIdentifier = NSUserInterfaceItemIdentifier("InstructionMemoryHi")
    let kInstructionMemoryLoIdentifier = NSUserInterfaceItemIdentifier("InstructionMemoryLo")
    let kDataMemoryIdentifier = NSUserInterfaceItemIdentifier("DataMemory")
    let kOpcodeDecodeROM1Identifier = NSUserInterfaceItemIdentifier("kOpcodeDecodeROM1Identifier")
    let kOpcodeDecodeROM2Identifier = NSUserInterfaceItemIdentifier("kOpcodeDecodeROM2Identifier")
    let kOpcodeDecodeROM3Identifier = NSUserInterfaceItemIdentifier("kOpcodeDecodeROM3Identifier")
    
    public required init(debugger: DebugConsole) {
        self.debugger = debugger
        super.init(nibName: NSNib.Name("MemoryViewController"), bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHexDataView(identifier: kInstructionMemoryIdentifier,
                       dataSource: InstructionMemoryTableViewDataSource(computer: debugger.computer))
        addHexDataView(identifier: kInstructionMemoryLoIdentifier,
                       dataSource: InstructionMemoryLoTableViewDataSource(computer: debugger.computer))
        addHexDataView(identifier: kInstructionMemoryHiIdentifier,
                       dataSource: InstructionMemoryHiTableViewDataSource(computer: debugger.computer))
        addHexDataView(identifier: kDataMemoryIdentifier,
                       dataSource: DataMemoryTableViewDataSource(computer: debugger.computer))
        addHexDataView(identifier: kOpcodeDecodeROM1Identifier,
                       dataSource: OpcodeDecodeROM1(computer: debugger.computer))
        addHexDataView(identifier: kOpcodeDecodeROM2Identifier,
                       dataSource: OpcodeDecodeROM2(computer: debugger.computer))
        addHexDataView(identifier: kOpcodeDecodeROM3Identifier,
                       dataSource: OpcodeDecodeROM3(computer: debugger.computer))
        
        syncMemoryTabView()
    }
    
    fileprivate func addHexDataView(identifier: NSUserInterfaceItemIdentifier, dataSource: NSTableViewDataSource) {
        let indexOfTab = memoryTabView.indexOfTabViewItem(withIdentifier: identifier)
        guard indexOfTab != NSNotFound else {
            fatalError("XIB does not contain tab with expected identifier: \(identifier)")
        }
        let tabViewItem = memoryTabView.tabViewItem(at: indexOfTab)
        let hexDataViewController = HexDataViewController(dataSource, debugger.computer)
        guard let tabViewItemView = tabViewItem.view else {
            return;
        }
        tabViewItemView.addSubview(hexDataViewController.view)
        tabViewItemView.addConstraints([
            NSLayoutConstraint(item: hexDataViewController.view,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: tabViewItem.view,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: hexDataViewController.view,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: tabViewItem.view,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: hexDataViewController.view,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: tabViewItem.view,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: hexDataViewController.view,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: tabViewItem.view,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0)
        ])
        hexDataViewControllers.append(hexDataViewController)
    }
    
    fileprivate func syncMemoryTabView() {
        memoryTabView.selectTabViewItem(withIdentifier: memoryTabSelector.selectedItem?.identifier ?? NSUserInterfaceItemIdentifier(""))
    }
    
    @IBAction func chooseVisibleAddressSpace(_ sender: Any) {
        syncMemoryTabView()
    }
    
    @IBAction func loadMemory(_ sender: Any) {
        let identifier: NSUserInterfaceItemIdentifier = memoryTabSelector.selectedItem!.identifier!
        let panel = NSOpenPanel()
        panel.begin { [weak self] (response: NSApplication.ModalResponse) in
            if (response == NSApplication.ModalResponse.OK) {
                if let url = panel.url {
                    self?.loadMemory(identifier, url)
                }
            }
        }
    }
    
    fileprivate func loadMemory(_ identifier: NSUserInterfaceItemIdentifier, _ url: URL) {
        switch identifier {
        case kInstructionMemoryIdentifier:
            debugger.interpreter.runOne(instruction: .load("program", url))
            
        case kInstructionMemoryHiIdentifier:
            debugger.interpreter.runOne(instruction: .load("program_hi", url))
            
        case kInstructionMemoryLoIdentifier:
            debugger.interpreter.runOne(instruction: .load("program_lo", url))
            
        case kDataMemoryIdentifier:
            debugger.interpreter.runOne(instruction: .load("data", url))
            
        case kOpcodeDecodeROM1Identifier:
            debugger.interpreter.runOne(instruction: .load("OpcodeDecodeROM1", url))
            
        case kOpcodeDecodeROM2Identifier:
            debugger.interpreter.runOne(instruction: .load("OpcodeDecodeROM2", url))
            
        case kOpcodeDecodeROM3Identifier:
            debugger.interpreter.runOne(instruction: .load("OpcodeDecodeROM3", url))
        
        default:
            NSSound.beep()
        }
    }
    
    @IBAction func saveMemory(_ sender: Any) {
        let identifier: NSUserInterfaceItemIdentifier = memoryTabSelector.selectedItem!.identifier!
        let panel = NSSavePanel()
        panel.begin { [weak self] (response: NSApplication.ModalResponse) in
            if (response == NSApplication.ModalResponse.OK) {
                if let url = panel.url {
                    self?.saveMemory(identifier, url)
                }
            }
        }
    }
    
    fileprivate func saveMemory(_ identifier: NSUserInterfaceItemIdentifier, _ url: URL) {
        switch identifier {
        case kInstructionMemoryIdentifier:
            debugger.interpreter.runOne(instruction: .save("program", url))
            
        case kInstructionMemoryHiIdentifier:
            debugger.interpreter.runOne(instruction: .save("program_hi", url))
            
        case kInstructionMemoryLoIdentifier:
            debugger.interpreter.runOne(instruction: .save("program_lo", url))
            
        case kDataMemoryIdentifier:
            debugger.interpreter.runOne(instruction: .save("data", url))
            
        case kOpcodeDecodeROM1Identifier:
            debugger.interpreter.runOne(instruction: .save("OpcodeDecodeROM1", url))
            
        case kOpcodeDecodeROM2Identifier:
            debugger.interpreter.runOne(instruction: .save("OpcodeDecodeROM2", url))
            
        case kOpcodeDecodeROM3Identifier:
            debugger.interpreter.runOne(instruction: .save("OpcodeDecodeROM3", url))
        
        default:
            NSSound.beep()
        }
    }
}
