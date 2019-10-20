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
    @IBOutlet var computer:Computer!
    @IBOutlet var registerA:NSTextField!
    @IBOutlet var registerB:NSTextField!
    @IBOutlet var registerC:NSTextField!
    @IBOutlet var registerD:NSTextField!
    @IBOutlet var registerX:NSTextField!
    @IBOutlet var registerY:NSTextField!
    @IBOutlet var registerU:NSTextField!
    @IBOutlet var registerV:NSTextField!
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
        setupLogger()
        microcodeGenerator.generate()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.provideInstructions(generateExampleProgram())
        setupExecutor()
    }
    
    func setupLogger() {
        logger = TextViewLogger(textView: eventLog)
        computer.logger = logger
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
    
    func setupExecutor() {
        executor.computer = computer
        
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
    
    @IBAction func modifyRegisterA(_ sender: Any) {
        computer.modifyRegisterA(withString: registerA.stringValue)
        refresh()
    }
    
    @IBAction func modifyRegisterB(_ sender: Any) {
        computer.modifyRegisterB(withString: registerB.stringValue)
        refresh()
    }
    
    @IBAction func modifyRegisterC(_ sender: Any) {
        computer.modifyRegisterC(withString: registerC.stringValue)
        refresh()
    }
    
    @IBAction func modifyRegisterD(_ sender: Any) {
        computer.modifyRegisterD(withString: registerD.stringValue)
        refresh()
    }
    
    @IBAction func modifyRegisterX(_ sender: Any) {
        computer.modifyRegisterX(withString: registerX.stringValue)
        refresh()
    }
    
    @IBAction func modifyRegisterY(_ sender: Any) {
        computer.modifyRegisterY(withString: registerY.stringValue)
        refresh()
    }
    
    @IBAction func modifyRegisterU(_ sender: Any) {
        computer.modifyRegisterU(withString: registerU.stringValue)
        refresh()
    }
    
    @IBAction func modifyRegisterV(_ sender: Any) {
        computer.modifyRegisterV(withString: registerV.stringValue)
        refresh()
    }
    
    @IBAction func modifyPC(_ sender: Any) {
        computer.modifyPC(withString: programCounter.stringValue)
        refresh()
    }
    
    @IBAction func modifyPCIF(_ sender: Any) {
        computer.modifyPCIF(withString: pc_if.stringValue)
        refresh()
    }
    
    @IBAction func modifyIFID(_ sender: Any) {
        computer.modifyIFID(withString: if_id.stringValue)
        refresh()
    }
    
    func refresh() {
        registerA.stringValue = computer.describeRegisterA()
        registerB.stringValue = computer.describeRegisterB()
        registerC.stringValue = computer.describeRegisterC()
        registerD.stringValue = computer.describeRegisterD()
        registerX.stringValue = computer.describeRegisterX()
        registerY.stringValue = computer.describeRegisterY()
        registerU.stringValue = computer.describeRegisterU()
        registerV.stringValue = computer.describeRegisterV()
        aluResult.stringValue = computer.describeALUResult()
        controlWord.stringValue = computer.describeControlWord()
        controlSignals.stringValue = computer.describeControlSignals()
        programCounter.stringValue = computer.describePC()
        if_id.stringValue = computer.describeIFID()
        bus.stringValue = computer.describeBus()
        
        if let serialOutputDisplay = serialOutput.textStorage?.mutableString {
            serialOutputDisplay.setString(computer.describeSerialOutput())
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
                        try self.computer.saveMicrocode(to: url)
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
                        try self.computer.loadMicrocode(from: url)
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
                        try self.computer.saveProgram(to: url)
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
                        try self.computer.loadProgram(from: url)
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                }
            }
        }
    }
    
    @IBAction func provideSerialInput(sender: Any?) {
        let bytes = Array(serialInput.stringValue.appending("\n").utf8)
        computer.provideSerialInput(bytes: bytes)
        serialInput.stringValue = ""
    }
}
