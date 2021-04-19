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
    @IBOutlet var instructionMemoryTableView: NSTableView!
    @IBOutlet var dataMemoryTableView: NSTableView!
    
    public var instructionMemoryTableViewDataSource: InstructionMemoryTableViewDataSource!
    public var dataMemoryTableViewDataSource: DataMemoryTableViewDataSource!
    
    public let debugger: DebugConsole
    
    public required init(debugger: DebugConsole) {
        self.debugger = debugger
        super.init(nibName: NSNib.Name("MemoryViewController"), bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionMemoryTableViewDataSource = InstructionMemoryTableViewDataSource(computer: debugger.computer)
        dataMemoryTableViewDataSource = DataMemoryTableViewDataSource(computer: debugger.computer)
        
        instructionMemoryTableView.dataSource = instructionMemoryTableViewDataSource
        dataMemoryTableView.dataSource = dataMemoryTableViewDataSource
        
        syncMemoryTabView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.virtualMachineStateDidChange(notification:)), name:  Turtle16Computer.kVirtualMachineStateDidChange, object: debugger.computer)
    }
    
    fileprivate func syncMemoryTabView() {
        memoryTabView.selectTabViewItem(withIdentifier: memoryTabSelector.selectedItem?.identifier ?? NSUserInterfaceItemIdentifier(""))
    }
    
    @objc func virtualMachineStateDidChange(notification: Notification) {
        instructionMemoryTableView.reloadData()
        dataMemoryTableView.reloadData()
    }
    
    @IBAction func chooseVisibleAddressSpace(_ sender: Any) {
        syncMemoryTabView()
    }
    
    @IBAction func loadMemory(_ sender: Any) {
        if memoryTabSelector.selectedItem?.identifier == NSUserInterfaceItemIdentifier("InstructionMemory") {
            let panel = NSOpenPanel()
            panel.begin { [weak self] (response: NSApplication.ModalResponse) in
                if (response == NSApplication.ModalResponse.OK) {
                    if let url = panel.url {
                        self?.loadProgram(url)
                    }
                }
            }
        }
        else if memoryTabSelector.selectedItem?.identifier == NSUserInterfaceItemIdentifier("DataMemory") {
            let panel = NSOpenPanel()
            panel.begin { [weak self] (response: NSApplication.ModalResponse) in
                if (response == NSApplication.ModalResponse.OK) {
                    if let url = panel.url {
                        self?.loadData(url)
                    }
                }
            }
        }
    }
    
    fileprivate func loadProgram(_ url: URL) {
        debugger.interpreter.runOne(instruction: .loadProgram(url))
        instructionMemoryTableView.reloadData()
        dataMemoryTableView.reloadData()
    }
    
    fileprivate func loadData(_ url: URL) {
        debugger.interpreter.runOne(instruction: .loadData(url))
        instructionMemoryTableView.reloadData()
        dataMemoryTableView.reloadData()
    }
}
