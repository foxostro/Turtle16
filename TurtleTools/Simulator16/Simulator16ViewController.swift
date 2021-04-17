//
//  Simulator16ViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/15/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleCore
import Turtle16SimulatorCore

class Simulator16ViewController: NSViewController {
    @IBOutlet var debuggerOutput: NSTextView!
    @IBOutlet var debuggerInput: NSTextField!
    @IBOutlet var halted: NSTextField!
    @IBOutlet var resetting: NSTextField!
    @IBOutlet var timeStamp: NSTextField!
    @IBOutlet var ovf: NSTextField!
    @IBOutlet var z: NSTextField!
    @IBOutlet var c0: NSTextField!
    @IBOutlet var registerTableView: NSTableView!
    @IBOutlet var memoryTabSelector: NSPopUpButton!
    @IBOutlet var memoryTabView: NSTabView!
    @IBOutlet var instructionMemoryTableView: NSTableView!
    @IBOutlet var dataMemoryTableView: NSTableView!
    
    let registerTableViewDataSource: RegisterTableViewDataSource
    let registerTableViewDelegate: RegisterTableViewDelegate
    let instructionMemoryTableViewDataSource: InstructionMemoryTableViewDataSource
    let dataMemoryTableViewDataSource: DataMemoryTableViewDataSource
    let computer: Turtle16Computer
    let debugger: DebugConsole
    
    required init?(coder: NSCoder) {
        computer = Turtle16Computer(SchematicLevelCPUModel())
        debugger = DebugConsole(computer: computer)
        registerTableViewDataSource = RegisterTableViewDataSource(computer: computer)
        registerTableViewDelegate = RegisterTableViewDelegate()
        instructionMemoryTableViewDataSource = InstructionMemoryTableViewDataSource(computer: computer)
        dataMemoryTableViewDataSource = DataMemoryTableViewDataSource(computer: computer)
        
        super.init(coder: coder)
    }

    fileprivate func loadExampleProgram() {
        let url = Bundle(for: type(of: self)).url(forResource: "example", withExtension: "bin")!
        debugger.interpreter.run(instructions: [
            .reset,
            .loadProgram(url)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadExampleProgram()
        
        let logger = TextViewLogger(textView: debuggerOutput)
        logger.appendTrailingNewline = false
        debugger.logger = logger
        
        debugger.sandboxAccessManager = ConcreteSandboxAccessManager()
        
        debuggerOutput.string = "\n"
        debuggerOutput.font = debuggerInput.font
        
        registerTableView.dataSource = registerTableViewDataSource
        registerTableView.delegate = registerTableViewDelegate
        
        instructionMemoryTableView.dataSource = instructionMemoryTableViewDataSource
        dataMemoryTableView.dataSource = dataMemoryTableViewDataSource
        
        syncMemoryTabView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidBecomeKey(notification:)), name: NSWindow.didBecomeKeyNotification, object: self.view.window)
        debuggerInput.becomeFirstResponder()
        
        reloadView()
    }
    
    fileprivate func syncMemoryTabView() {
        memoryTabView.selectTabViewItem(withIdentifier: memoryTabSelector.selectedItem?.identifier ?? NSUserInterfaceItemIdentifier(""))
    }
    
    fileprivate func reloadView() {
        halted.isHidden = !computer.isHalted
        resetting.isHidden = !computer.isResetting
        timeStamp.stringValue = "t=\(computer.timeStamp)"
        ovf.isHidden = (computer.ovf == 0)
        z.isHidden = (computer.z == 0)
        c0.isHidden = (computer.carry == 0)
        registerTableView.reloadData()
        instructionMemoryTableView.reloadData()
        dataMemoryTableView.reloadData()
    }
    
    @objc func windowDidBecomeKey(notification: Notification) {
        debuggerInput.becomeFirstResponder()
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
    
    @IBAction func submitCommandLine(_ sender: Any) {
        debugger.eval(debuggerInput.stringValue)
        if debugger.shouldQuit {
            NSApp.terminate(self)
        }
        reloadView()
        debugger.logger.append("\n")
        debuggerInput.stringValue = ""
        debuggerInput.becomeFirstResponder()
    }
}
