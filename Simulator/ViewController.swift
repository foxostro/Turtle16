//
//  ViewController.swift
//  Simulator
//
//  Created by Andrew Fox on 7/27/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa
import TurtleSimulatorCore
import TurtleAssemblerCore
import TurtleCore

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
    @IBOutlet var ipsLabel:NSTextField!
    var logger:TextViewLogger!
    let executor = ComputerExecutor()
    let stopwatch = ComputerStopwatch()
    let microcodeGenerator = MicrocodeGenerator()
    let kExampleProgramName = "Example"
    let toneGenerator = ConcreteToneGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInstructionsPerSecondLabel()
        logger = TextViewLogger(textView: eventLog)
        microcodeGenerator.generate()
        setupExecutor()
    }
    
    func setupInstructionsPerSecondLabel() {
        let formatter = NumberFormatter()
        formatter.roundingIncrement = 1
        formatter.usesGroupingSeparator = true
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        ipsLabel.formatter = formatter
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            let ips = self?.stopwatch.measure() ?? 0.0
            if ips > 0.0 {
                self?.ipsLabel.objectValue = ips
            }
        }
    }
    
    func setupExecutor() {
        let computer = Computer(toneGenerator: toneGenerator)
        executor.computer = computer
        executor.stopwatch = stopwatch
        
        executor.didUpdateSerialOutput = {[weak self] (aString: String) -> Void in
            self?.didUpdateSerialOutput(aString)
        }
        
        executor.didStart = {[weak self] in
            guard let this = self else { return }
            this.toneGenerator.reset()
            this.toneGenerator.start()
            this.disableEventLog()
            this.disableCPUStateUpdate()
            this.makeStopButtonAvailable()
        }
        
        executor.didStop = {[weak self] in
            guard let this = self else { return }
            this.toneGenerator.reset()
            this.updateCPUState(this.executor.cpuState)
            this.enableCPUStateUpdate()
            this.enableEventLog()
            this.makeRunButtonAvailable()
        }
        
        executor.didHalt = {[weak self] in
            guard let this = self else { return }
            this.toneGenerator.reset()
            this.updateCPUState(this.executor.cpuState)
            this.enableCPUStateUpdate()
            this.enableEventLog()
            this.makeRunButtonAvailable()
        }
        
        executor.didReset = {[weak self] in
            guard let this = self else { return }
            this.serialOutput.textStorage?.mutableString.setString("")
            this.logger.clear()
            this.toneGenerator.reset()
            this.updateCPUState(this.executor.cpuState)
            this.enableCPUStateUpdate()
            this.enableEventLog()
            this.makeRunButtonAvailable()
        }
        
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: nil) { [weak self] _ in
            self?.executor.stop()
        }
        
        executor.provideInstructions(generateExampleProgram())
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
        if let fileName = Bundle.main.path(forResource: kExampleProgramName, ofType: "txt") {
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
        executor.singleStep()
    }
    
    @IBAction func runOrStop(_ sender: Any) {
        executor.runOrStop()
    }
    
    @IBAction func reset(_ sender: Any) {
        executor.reset()
    }
    
    func updateCPUState(_ cpuState: CPUStateSnapshot) {
        registerA.stringValue = cpuState.registerA.displayString
        registerB.stringValue = cpuState.registerB.displayString
        registerC.stringValue = cpuState.registerC.displayString
        registerD.stringValue = cpuState.registerD.displayString
        registerG.stringValue = cpuState.registerG.displayString
        registerH.stringValue = cpuState.registerH.displayString
        registerU.stringValue = cpuState.registerU.displayString
        registerV.stringValue = cpuState.registerV.displayString
        registerX.stringValue = cpuState.registerX.displayString
        registerY.stringValue = cpuState.registerY.displayString
        aluResult.stringValue = cpuState.aluResult.displayString
        controlWord.stringValue = cpuState.controlWord.stringValue
        controlSignals.stringValue = cpuState.controlWord.description
        programCounter.stringValue = cpuState.pc.description
        if_id.stringValue = cpuState.if_id.description
        bus.stringValue = cpuState.bus.displayString
    }
        
    func didUpdateSerialOutput(_ aString: String) {
        if let serialOutputDisplay = serialOutput.textStorage?.mutableString {
            serialOutputDisplay.setString(aString)
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
                    self.executor.saveMicrocode(to: url, errorBlock: {
                        NSAlert(error: $0).runModal()
                    })
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
                    self.executor.saveProgram(to: url, errorBlock: {
                        NSAlert(error: $0).runModal()
                    })
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
                    self.executor.loadProgram(from: url, errorBlock: {
                        NSAlert(error: $0).runModal()
                    })
                }
            }
        }
    }
    
    @IBAction func loadProgramFromSource(sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["asm"]
        panel.allowsOtherFileTypes = false
        panel.begin { (response: NSApplication.ModalResponse) in
            if (response == NSApplication.ModalResponse.OK) {
                if let url = panel.url {
                    do {
                        let programText = try String(contentsOf: url, encoding: .utf8)
                        let frontEnd = AssemblerFrontEnd()
                        frontEnd.compile(programText)
                        if frontEnd.hasError {
                            let error = frontEnd.makeOmnibusError(fileName: nil, errors: frontEnd.errors)
                            self.alert(withMessage: error.message)
                        } else {
                            self.executor.provideInstructions(frontEnd.instructions)
                        }
                    } catch {
                        self.alert(withMessage: String(describing: error))
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
    
    func disableEventLog() {
        executor.logger = nil
        eventLog.textColor = NSColor.disabledControlTextColor
    }
    
    func enableEventLog() {
        executor.logger = logger
        eventLog.textColor = NSColor.controlTextColor
    }
    
    func disableCPUStateUpdate() {
        setCPUStateTextColor(NSColor.disabledControlTextColor)
    }
    
    func enableCPUStateUpdate() {
        setCPUStateTextColor(NSColor.controlTextColor)
    }
    
    func setCPUStateTextColor(_ color: NSColor) {
        registerA.textColor = color
        registerB.textColor = color
        registerC.textColor = color
        registerD.textColor = color
        registerG.textColor = color
        registerH.textColor = color
        registerU.textColor = color
        registerV.textColor = color
        registerX.textColor = color
        registerY.textColor = color
        aluResult.textColor = color
        controlWord.textColor = color
        controlSignals.textColor = color
        programCounter.textColor = color
        if_id.textColor = color
        bus.textColor = color
    }
}
