//
//  MemoryViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/18/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import Turtle16SimulatorCore

class MemoryViewController: NSViewController {
    @IBOutlet var memoryTabSelector: NSPopUpButton!
    @IBOutlet var memoryTabView: NSTabView!
    
    public let debugger: DebugConsole
    public var hexDataViewControllers: [HexDataViewController] = []
    
    let kInstructionMemoryIdentifier = NSUserInterfaceItemIdentifier("InstructionMemory")
    let kDataMemoryIdentifier = NSUserInterfaceItemIdentifier("DataMemory")
    let kOpcodeDecodeROMU25Identifier = NSUserInterfaceItemIdentifier("U25")
    let kOpcodeDecodeROMU26Identifier = NSUserInterfaceItemIdentifier("U26")
    let kOpcodeDecodeROMU33Identifier = NSUserInterfaceItemIdentifier("U33")
    
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
        addHexDataView(identifier: kDataMemoryIdentifier,
                       dataSource: DataMemoryTableViewDataSource(computer: debugger.computer))
        addHexDataView(identifier: kOpcodeDecodeROMU25Identifier,
                       dataSource: OpcodeDecodeROMU25(computer: debugger.computer))
        addHexDataView(identifier: kOpcodeDecodeROMU26Identifier,
                       dataSource: OpcodeDecodeROMU26(computer: debugger.computer))
        addHexDataView(identifier: kOpcodeDecodeROMU33Identifier,
                       dataSource: OpcodeDecodeROMU33(computer: debugger.computer))
        
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
            
        case kDataMemoryIdentifier:
            debugger.interpreter.runOne(instruction: .load("data", url))
            
        case kOpcodeDecodeROMU25Identifier:
            debugger.interpreter.runOne(instruction: .load("U25", url))
            
        case kOpcodeDecodeROMU26Identifier:
            debugger.interpreter.runOne(instruction: .load("U26", url))
            
        case kOpcodeDecodeROMU33Identifier:
            debugger.interpreter.runOne(instruction: .load("U33", url))
        
        default:
            NSSound.beep()
        }
    }
}