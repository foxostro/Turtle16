//
//  DebugConsoleViewController.swift
//  Simulator16
//
//  Created by Andrew Fox on 4/18/21.
//  Copyright © 2021 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleCore
import Turtle16SimulatorCore

class DebugConsoleViewController: NSViewController, NSControlTextEditingDelegate {
    @IBOutlet var debuggerOutput: NSTextView!
    @IBOutlet var debuggerInput: NSTextField!
    @IBOutlet var halted: NSTextField!
    @IBOutlet var resetting: NSTextField!
    @IBOutlet var stall: NSTextField!
    @IBOutlet var timeStamp: NSTextField!
    @IBOutlet var ovf: NSTextField!
    @IBOutlet var z: NSTextField!
    @IBOutlet var c0: NSTextField!
    
    let debugger: DebugConsole
    var history: [String] = []
    var cursor = 0
    
    public required init(debugger: DebugConsole) {
        self.debugger = debugger
        super.init(nibName: NSNib.Name("DebugConsoleViewController"), bundle: Bundle(for: type(of: self)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.virtualMachineStateDidChange(notification:)), name:  .virtualMachineStateDidChange, object: debugger.computer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logger = TextViewLogger(textView: debuggerOutput)
        logger.appendTrailingNewline = false
        debugger.logger = logger
        
        debuggerOutput.string = "\n"
        debuggerOutput.font = debuggerInput.font
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidBecomeKey(notification:)), name: NSWindow.didBecomeKeyNotification, object: self.view.window)
        debuggerInput.becomeFirstResponder()
        
        reload()
    }
    
    @objc func windowDidBecomeKey(notification: Notification) {
        debuggerInput.becomeFirstResponder()
    }
    
    @objc func virtualMachineStateDidChange(notification: Notification) {
        reload()
    }
    
    fileprivate func reload() {
        let computer = debugger.computer
        halted.isHidden = !computer.isHalted
        resetting.isHidden = !computer.isResetting
        stall.isHidden = !computer.isStalling
        timeStamp.stringValue = "t=\(computer.timeStamp)"
        ovf.isHidden = (computer.ovf == 0)
        z.isHidden = (computer.z == 0)
        c0.isHidden = (computer.carry == 0)
    }
    
    @IBAction func submitCommandLine(_ sender: Any) {
        let command: String
        if debuggerInput.stringValue == "" {
            command = history.last ?? ""
        } else {
            command = debuggerInput.stringValue
        }
        debugger.eval(command)
        if debugger.shouldQuit {
            NSApp.terminate(self)
        }
        debugger.logger.append("\n")
        debuggerInput.stringValue = ""
        history.insert(command, at: 0)
        cursor = 0
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if control === debuggerInput {
            if commandSelector == #selector(moveUp(_:)) {
                debuggerInput.stringValue = history[cursor]
                cursor = min(cursor + 1, history.count - 1)
                return true
            } else if commandSelector == #selector(moveDown(_:)) {
                debuggerInput.stringValue = history[cursor]
                cursor = max(cursor - 1, 0)
                return true
            }
        }
        return false
    }
}
