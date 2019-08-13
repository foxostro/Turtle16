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
    @IBOutlet var aluResult:NSTextField!
    @IBOutlet var controlWord:NSTextField!
    @IBOutlet var controlSignals:NSTextField!
    @IBOutlet var programCounter:NSTextField!
    @IBOutlet var bus:NSTextField!
    @IBOutlet var outputDisplay:NSTextField!
    @IBOutlet var stepButton:NSButton!
    @IBOutlet var runButton:NSButton!
    @IBOutlet var eventLog:NSTextView!
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
        var program = [Instruction]()
        do {
            program = try tryGenerateExampleProgram()
        } catch let error as AssemblerBackEnd.AssemblerBackEndError {
            alert(withMessage: "Assembler Back End Error: " + error.message)
        } catch let error as CodeGenerator.CodeGeneratorError {
            alert(withMessage: "Code Generator Error: " + error.message)
        } catch {
            alert(withMessage: "Unknown Error")
        }
        return program
    }
    
    func alert(withMessage message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
    
    func tryGenerateExampleProgram() throws -> [Instruction] {
        let a = makeAssemblerBackEnd()
        a.begin()
        try a.li("A", 0)
        try a.li("B", 1)
        try a.li("D", 1) // select the output display as the target for "M"
        try a.li("M", 0) // initialize output display to zero
        try a.label("loop")
        try a.add("A")
        try a.jc("end")
        try a.mov("M", "A") // move the value in A to the output display
        try a.jmp("loop")
        try a.label("end")
        a.hlt()
        try a.end()
        return a.instructions
    }
    
    func makeAssemblerBackEnd() -> AssemblerBackEnd {
        let codeGenerator = CodeGenerator(microcodeGenerator: microcodeGenerator)
        let assembler = AssemblerBackEnd(codeGenerator: codeGenerator)
        return assembler
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
        computer.registerA.stringValue = registerA.stringValue
        refresh()
    }
    
    @IBAction func modifyRegisterB(_ sender: Any) {
        computer.registerB.stringValue = registerB.stringValue
        refresh()
    }
    
    @IBAction func modifyRegisterD(_ sender: Any) {
        computer.registerD.stringValue = registerD.stringValue
        refresh()
    }
    
    @IBAction func modifyRegisterX(_ sender: Any) {
        computer.registerX.stringValue = registerX.stringValue
        refresh()
    }
    
    @IBAction func modifyRegisterY(_ sender: Any) {
        computer.registerY.stringValue = registerY.stringValue
        refresh()
    }
    
    @IBAction func modifyRegisterPC(_ sender: Any) {
        computer.programCounter.stringValue = programCounter.stringValue
        refresh()
    }
    
    func refresh() {
        registerA.stringValue = computer.registerA.stringValue
        registerB.stringValue = computer.registerB.stringValue
        registerC.stringValue = computer.registerC.stringValue
        registerD.stringValue = computer.registerD.stringValue
        registerX.stringValue = computer.registerX.stringValue
        registerY.stringValue = computer.registerY.stringValue
        aluResult.stringValue = computer.alu.stringValue
        controlWord.stringValue = computer.controlWordRegister.stringValue
        controlSignals.stringValue = computer.controlWordRegister.description
        programCounter.stringValue = computer.programCounter.stringValue
        bus.stringValue = computer.busStringValue
        outputDisplay.stringValue = String(computer.registerD.contents)
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
}
