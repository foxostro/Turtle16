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
    @IBOutlet var registers: NSTextField!
    
    public let computer: Turtle16Computer
    public let debugger: DebugConsole
    
    required init?(coder: NSCoder) {
        computer = Turtle16Computer(SchematicLevelCPUModel())
        debugger = DebugConsole(computer: computer)
        
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
        
        let r0 = String(format: "%d", computer.getRegister(0))
        let r1 = String(format: "%d", computer.getRegister(1))
        let r2 = String(format: "%d", computer.getRegister(2))
        let r3 = String(format: "%d", computer.getRegister(3))
        let r4 = String(format: "%d", computer.getRegister(4))
        let r5 = String(format: "%d", computer.getRegister(5))
        let r6 = String(format: "%d", computer.getRegister(6))
        let r7 = String(format: "%d", computer.getRegister(7))
        let pc = String(format: "%d", computer.pc)
        let hr0 = String(format: "0x%04x", computer.getRegister(0))
        let hr1 = String(format: "0x%04x", computer.getRegister(1))
        let hr2 = String(format: "0x%04x", computer.getRegister(2))
        let hr3 = String(format: "0x%04x", computer.getRegister(3))
        let hr4 = String(format: "0x%04x", computer.getRegister(4))
        let hr5 = String(format: "0x%04x", computer.getRegister(5))
        let hr6 = String(format: "0x%04x", computer.getRegister(6))
        let hr7 = String(format: "0x%04x", computer.getRegister(7))
        let hpc = String(format: "0x%04x", computer.pc)
        registers.stringValue = """
Name    Hex       Decimal
r0      \(hr0)    \(r0)
r1      \(hr1)    \(r1)
r2      \(hr2)    \(r2)
r3      \(hr3)    \(r3)
r4      \(hr4)    \(r4)
r5      \(hr5)    \(r5)
r6      \(hr6)    \(r6)
r7      \(hr7)    \(r7)
pc      \(hpc)    \(pc)
"""
        registers.font = debuggerInput.font
    }
}
