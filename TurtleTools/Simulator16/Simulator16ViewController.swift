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
    
    public let registerTableViewDataSource: RegisterTableViewDataSource
    public let registerTableViewDelegate: RegisterTableViewDelegate
    
    public let computer: Turtle16Computer
    public let debugger: DebugConsole
    
    required init?(coder: NSCoder) {
        computer = Turtle16Computer(SchematicLevelCPUModel())
        debugger = DebugConsole(computer: computer)
        registerTableViewDataSource = RegisterTableViewDataSource(computer: computer)
        registerTableViewDelegate = RegisterTableViewDelegate()
        
        super.init(coder: coder)
    }

    fileprivate func loadExampleProgram() {
        let url = Bundle(for: type(of: self)).url(forResource: "example", withExtension: "bin")!
        debugger.interpreter.run(instructions: [
            .reset,
            .load(url)
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
        
        reloadView()
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
    
    public func reloadView() {
        halted.isHidden = !computer.isHalted
        resetting.isHidden = !computer.isResetting
        timeStamp.stringValue = "t=\(computer.timeStamp)"
        ovf.isHidden = (computer.ovf == 0)
        z.isHidden = (computer.z == 0)
        c0.isHidden = (computer.carry == 0)
        registerTableView.reloadData()
    }
}
