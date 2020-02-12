//
//  ViewController.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleTTL

class ViewController: NSViewController {
    @IBOutlet var registerA:NSTextField!
    @IBOutlet var registerB:NSTextField!
    @IBOutlet var registerC:NSTextField!
    @IBOutlet var registerD:NSTextField!
    @IBOutlet var registerG:NSTextField!
    @IBOutlet var registerH:NSTextField!
    @IBOutlet var registerU:NSTextField!
    @IBOutlet var registerV:NSTextField!
    @IBOutlet var registerX:NSTextField!
    @IBOutlet var registerY:NSTextField!
    @IBOutlet var aluResult:NSTextField!
    @IBOutlet var controlWord:NSTextField!
    @IBOutlet var controlSignals:NSTextField!
    @IBOutlet var programCounter:NSTextField!
    @IBOutlet var pc_if:NSTextField!
    @IBOutlet var if_id:NSTextField!
    @IBOutlet var bus:NSTextField!
    @IBOutlet var stepButton:NSButton!
    @IBOutlet var runButton:NSButton!
    @IBOutlet var eventLog:NSTextView!
    @IBOutlet var serialInput:NSTextField!
    @IBOutlet var serialOutput:NSTextView!
    var logger:TextViewLogger!
    let executor = ComputerExecutor()
    let microcodeGenerator = MicrocodeGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger = TextViewLogger(textView: eventLog)
        microcodeGenerator.generate()
        setupExecutor()
    }
    
    func setupExecutor() {
        executor.computer = ComputerRev1()
        executor.logger = logger
        executor.provideMicrocode(microcode: microcodeGenerator.microcode)
        executor.provideInstructions(generateExampleProgram())
        
        executor.onStep = {
            self.refresh()
        }
        
        executor.didStart = {
            self.makeStopButtonAvailable()
        }
        
        executor.didStop = {
            self.makeRunButtonAvailable()
        }
        
        executor.didHalt = {
            self.stepButton.isEnabled = false
            self.runButton.isEnabled = false
        }
        
        executor.didReset = {
            self.makeRunButtonAvailable()
            self.stepButton.isEnabled = true
            self.runButton.isEnabled = true
            self.logger.clear()
            self.refresh()
        }
        
        executor.beginTimer()
    }
    
    func generateExampleProgram() -> [Instruction] {
        let frontEnd = AssemblerFrontEnd()
        frontEnd.compile(loadExampleProgram())
        if frontEnd.hasError {
            let error = frontEnd.makeOmnibusError(fileName: nil, errors: frontEnd.errors)
            alert(withMessage: error.message)
        }
        return frontEnd.instructions
    }
    
    func alert(withMessage message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
    
    func loadExampleProgram() -> String {
        if let fileName = Bundle.main.path(forResource: "Example", ofType: "txt") {
            do {
                return try String(contentsOfFile: fileName)
            } catch {
                alert(withMessage: "Error: Example program could not be loaded.")
            }
        } else {
            alert(withMessage: "Error: Example program could not be found.")
        }
        return ""
    }
    
    func makeRunButtonAvailable() {
        stepButton.isEnabled = true
        runButton.title = "Run"
        runButton.keyEquivalent = "r"
        runButton.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
    }
    
    func makeStopButtonAvailable() {
        stepButton.isEnabled = false
        runButton.title = "Stop"
        runButton.keyEquivalent = "."
        runButton.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
    }

    @IBAction func step(_ sender: Any) {
        executor.step()
    }
    
    @IBAction func runOrStop(_ sender: Any) {
        executor.runOrStop()
    }
    
    @IBAction func reset(_ sender: Any) {
        executor.reset()
    }
    
    func refresh() {
        registerA.stringValue = executor.describeRegisterA()
        registerB.stringValue = executor.describeRegisterB()
        registerC.stringValue = executor.describeRegisterC()
        registerD.stringValue = executor.describeRegisterD()
        registerG.stringValue = executor.describeRegisterG()
        registerH.stringValue = executor.describeRegisterH()
        registerU.stringValue = executor.describeRegisterU()
        registerV.stringValue = executor.describeRegisterV()
        registerX.stringValue = executor.describeRegisterX()
        registerY.stringValue = executor.describeRegisterY()
        aluResult.stringValue = executor.describeALUResult()
        controlWord.stringValue = executor.describeControlWord()
        controlSignals.stringValue = executor.describeControlSignals()
        programCounter.stringValue = executor.describePC()
        if_id.stringValue = executor.describeIFID()
        bus.stringValue = executor.describeBus()
        
        if let serialOutputDisplay = serialOutput.textStorage?.mutableString {
            serialOutputDisplay.setString(executor.describeSerialOutput())
            serialOutput.scrollToEndOfDocument(self)
        }
    }
    
    @IBAction func saveMicrocode(sender: Any?) {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.allowedFileTypes = ["microcode"]
        panel.allowsOtherFileTypes = false
        panel.begin { (response: NSApplication.ModalResponse) in
            if (response == NSApplication.ModalResponse.OK) {
                if let url = panel.url {
                    do {
                        try self.executor.saveMicrocode(to: url)
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                }
            }
        }
    }
    
    @IBAction func loadMicrocode(sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["microcode"]
        panel.allowsOtherFileTypes = false
        panel.begin { (response: NSApplication.ModalResponse) in
            if (response == NSApplication.ModalResponse.OK) {
                if let url = panel.url {
                    do {
                        try self.executor.loadMicrocode(from: url)
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                }
            }
        }
    }
    
    @IBAction func saveProgram(sender: Any?) {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.allowedFileTypes = ["program"]
        panel.allowsOtherFileTypes = false
        panel.begin { (response: NSApplication.ModalResponse) in
            if (response == NSApplication.ModalResponse.OK) {
                if let url = panel.url {
                    do {
                        try self.executor.saveProgram(to: url)
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                }
            }
        }
    }
    
    @IBAction func loadProgram(sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["program"]
        panel.allowsOtherFileTypes = false
        panel.begin { (response: NSApplication.ModalResponse) in
            if (response == NSApplication.ModalResponse.OK) {
                if let url = panel.url {
                    do {
                        try self.executor.loadProgram(from: url)
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                }
            }
        }
    }
    
    @IBAction func provideSerialInput(sender: Any?) {
        let bytes = Array(serialInput.stringValue.appending("\n").utf8)
        executor.provideSerialInput(bytes: bytes)
        serialInput.stringValue = ""
    }
}
