//
//  SnapCommandLineDriver.swift
//  Snap
//
//  Created by Andrew Fox on 5/17/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import SnapCore
import TurtleCore
import TurtleCompilerToolbox
import TurtleSimulatorCore

// Provides an interface for driving the snap compiler from the command-line.
public class SnapCommandLineDriver: NSObject {
    public struct SnapCommandLineDriverError: Error {
        public let message: String
        
        public init(_ message: String) {
            self.message = message
        }
    }
    
    public var status: Int32 = 1
    public var stdout: TextOutputStream = String()
    public var stderr: TextOutputStream = String()
    let arguments: [String]
    public private(set) var inputFileName: URL? = nil
    public private(set) var programOutputFileName: URL? = nil
    public private(set) var irOutputFileName: URL? = nil
    public private(set) var asmOutputFileName: URL? = nil
    public var shouldOutputIR = false
    public var shouldOutputAssembly = false
    public var shouldDoASTDump = false
    public var shouldListTests = false
    public var shouldRunTests = false
    public var chooseSpecificTest: String? = nil
    public var shouldBeQuiet = false
    public var shouldEnableOptimizations = true
    
    public required init(withArguments arguments: [String]) {
        self.arguments = arguments
    }
    
    public func run() {
        do {
            try tryRun()
        } catch let error as SnapCommandLineDriverError {
            reportError(withMessage: error.message)
        } catch let error as CompilerError {
            reportError(withMessage: error.message)
        } catch {
            reportError(withMessage: error.localizedDescription)
        }
    }
    
    func reportError(withMessage message: String) {
        if !shouldBeQuiet {
            stderr.write("Error: " + message)
        }
    }
    
    func tryRun() throws {
        try parseArguments()
        
        if shouldListTests {
            let fileName = inputFileName!.relativePath
            let maybeText = String(data: try Data(contentsOf: inputFileName!), encoding: .utf8)
            guard let text = maybeText else {
                throw SnapCommandLineDriverError("failed to read input file as UTF-8 text: \(fileName)")
            }
            let testNames = try collectNamesOfTests(text, fileName)
            stdout.write("Unit Tests:\n")
            for testName in testNames {
                stdout.write(testName + "\n")
            }
            status = 0
            return
        }
        
        if shouldRunTests {
            try tryRunTests()
            status = 0
            return
        }
        
        let fileName = inputFileName!.relativePath
        let maybeText = String(data: try Data(contentsOf: inputFileName!), encoding: .utf8)
        guard let text = maybeText else {
            throw SnapCommandLineDriverError("failed to read input file as UTF-8 text: \(fileName)")
        }
        let frontEnd = SnapCompiler()
        frontEnd.isUsingStandardLibrary = true
        frontEnd.shouldRunSpecificTest = nil
        frontEnd.shouldEnableOptimizations = shouldEnableOptimizations
        frontEnd.compile(text, inputFileName)
        if frontEnd.hasError {
            throw CompilerError.makeOmnibusError(fileName: fileName, errors: frontEnd.errors)
        }
        printNumberOfInstructionWordsUsed(frontEnd)
        
        if shouldDoASTDump {
            stdout.write(frontEnd.ast.description)
            stdout.write("\n")
        }
        
        if shouldOutputAssembly {
            try writeDisassemblyToFile(instructions: frontEnd.instructions, programDebugInfo: frontEnd.programDebugInfo)
        }
        
        if shouldOutputIR {
            try writeToFile(ir: frontEnd.ir, programDebugInfo: frontEnd.programDebugInfo)
        }
        
        try writeToFile(instructions: frontEnd.instructions)
        
        status = 0
    }
    
    fileprivate func reportInfoMessage(_ message: String) {
        if !shouldBeQuiet {
            self.stdout.write(message)
        }
    }
    
    fileprivate func printNumberOfInstructionWordsUsed(_ frontEnd: SnapCompiler) {
        let numberOfInstructions = frontEnd.instructions.count
        if numberOfInstructions > 32767 {
            reportInfoMessage("WARNING: generated code exceeds 32768 instruction memory words: \(numberOfInstructions) words used\n")
        } else {
            reportInfoMessage("instruction words used: \(numberOfInstructions)\n")
        }
    }
    
    func tryRunTests() throws {
        let fileName = inputFileName!.relativePath
        let maybeText = String(data: try Data(contentsOf: inputFileName!), encoding: .utf8)
        guard let text = maybeText else {
            throw SnapCommandLineDriverError("failed to read input file as UTF-8 text: \(fileName)")
        }
        let testNames = try collectNamesOfTests(text, fileName)
        if let chooseSpecificTest = chooseSpecificTest {
            try runSpecificTest(chooseSpecificTest, text, fileName)
        } else {
            for testName in testNames {
                try runSpecificTest(testName, text, fileName)
            }
        }
        status = 0
    }
    
    fileprivate func collectNamesOfTests(_ text: String, _ fileName: String) throws -> [String] {
        let frontEnd0 = SnapCompiler()
        frontEnd0.isUsingStandardLibrary = true
        frontEnd0.compile(text, inputFileName)
        if frontEnd0.hasError {
            throw CompilerError.makeOmnibusError(fileName: fileName, errors: frontEnd0.errors)
        }
        return frontEnd0.testNames
    }
    
    fileprivate func runSpecificTest(_ testName: String, _ text: String, _ fileName: String) throws {
        reportInfoMessage("Running test \"\(testName)\"...\n")
        let frontEnd = SnapCompiler()
        frontEnd.isUsingStandardLibrary = true
        frontEnd.shouldRunSpecificTest = testName
        frontEnd.compile(text, inputFileName)
        if frontEnd.hasError {
            throw CompilerError.makeOmnibusError(fileName: fileName, errors: frontEnd.errors)
        }
        printNumberOfInstructionWordsUsed(frontEnd)
        let directory: URL = inputFileName!.deletingPathExtension().deletingLastPathComponent()
        let baseName: String = inputFileName!.deletingPathExtension().lastPathComponent + " -- \(testName)"
        irOutputFileName = URL(fileURLWithPath: baseName + ".ir", relativeTo: directory)
        asmOutputFileName = URL(fileURLWithPath: baseName + ".asm", relativeTo: directory)
        if shouldOutputIR {
            try writeToFile(ir: frontEnd.ir, programDebugInfo: frontEnd.programDebugInfo)
        }
        if shouldOutputAssembly {
            try writeDisassemblyToFile(instructions: frontEnd.instructions, programDebugInfo: frontEnd.programDebugInfo)
        }
        let computer = Computer()
        let microcodeGenerator = MicrocodeGenerator()
        microcodeGenerator.generate()
        computer.provideMicrocode(microcode: microcodeGenerator.microcode)
        computer.logger = nil
        computer.programDebugInfo = frontEnd.programDebugInfo
        computer.provideInstructions(frontEnd.instructions)
        var previousSerialOutput = ""
        computer.didUpdateSerialOutput = {
            let delta = String($0.dropFirst(previousSerialOutput.count))
            previousSerialOutput = $0
            self.stdout.write(delta)
        }
        try computer.runUntilHalted()
        reportInfoMessage("\n\n")
    }
    
    func writeToFile(ir: [CrackleInstruction], programDebugInfo: SnapDebugInfo?) throws {
        let string = CrackleInstructionListingMaker.makeListing(instructions: ir, programDebugInfo: programDebugInfo)
        try string.write(to: irOutputFileName!, atomically: true, encoding: .utf8)
    }
    
    func writeDisassemblyToFile(instructions: [Instruction], programDebugInfo: SnapDebugInfo?) throws {
        let base = 0
        let string = AssemblyListingMaker.makeListing(base, instructions, programDebugInfo)
        try string.write(to: asmOutputFileName!, atomically: true, encoding: .utf8)
    }
    
    func writeToFile(instructions: [Instruction]) throws {
        if let programOutputFileName = programOutputFileName {
            let computer = Computer()
            computer.provideInstructions(instructions)
            try computer.saveProgram(to: programOutputFileName)
        }
    }
    
    public func parseArguments() throws {
        let argParser = SnapCommandLineArgumentParser(args: arguments)
        do {
            try argParser.parse()
        } catch let error as SnapCommandLineParserError {
            switch error {
            case .unexpectedEndOfInput:
                throw SnapCommandLineDriverError(makeUsageMessage())
            case .unknownOption(let option):
                throw SnapCommandLineDriverError("unknown option `\(option)'\n\n\(makeUsageMessage())")
            }
        }
        let options = argParser.options
        
        if options.contains(.printHelp) {
            stdout.write(makeUsageMessage())
            exit(0)
        }
            
        for option in options {
            switch option {
            case .printHelp:
                break // do nothing
                
            case .inputFileName(let fileName):
                try parseInputFileName(fileName)
                
            case .outputFileName(let fileName):
                try parseOutputFileName(fileName)
                
            case .S:
                shouldOutputAssembly = true
                
            case .ir:
                shouldOutputIR = true
                
            case .astDump:
                shouldDoASTDump = true
                
            case .test:
                shouldRunTests = true
                
            case .listTests:
                shouldListTests = true
                
            case .chooseSpecificTest(let testName):
                chooseSpecificTest = testName
                
            case .quiet:
                shouldBeQuiet = true
                
            case .unoptimized:
                shouldEnableOptimizations = false
            }
        }
        
        if !shouldRunTests && inputFileName == nil {
            throw SnapCommandLineDriverError("expected input filename")
        }
        
        let baseName: URL = inputFileName!.deletingPathExtension()
        
        if programOutputFileName == nil {
            programOutputFileName = baseName.appendingPathExtension("program")
        }
        
        if irOutputFileName == nil {
            irOutputFileName = baseName.appendingPathExtension("ir")
        }
        
        if asmOutputFileName == nil {
            asmOutputFileName = baseName.appendingPathExtension("asm")
        }
    }
    
    func makeUsageMessage() -> String {
        return """
OVERVIEW: compiler for the Snap programming language

USAGE:
\(arguments[0]) [test] [options] file...
            
OPTIONS:
\ttest       Compile the program for testing and run immediately in a VM.
\t-h         Display available options
\t-o <file>  Specify the output filename
\t-S         Output assembly code
\t-ir        Output intermediate representation
\t-ast-dump  Print the abstract syntax tree to stdout
\t-q         Quiet. Do not print progress to stdout
\t-O0        Disable optimizations
"""
    }

    func parseInputFileName(_ fileName: String) throws {
        if inputFileName != nil {
            throw SnapCommandLineDriverError("compiler currently only supports one input file at a time.")
        }
        inputFileName = URL(fileURLWithPath: fileName)
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: inputFileName!.relativePath, isDirectory: &isDirectory) {
            throw SnapCommandLineDriverError("input file does not exist: \(inputFileName!.relativePath)")
        }
        if (isDirectory.boolValue) {
            throw SnapCommandLineDriverError("input file is a directory: \(inputFileName!.relativePath)")
        }
        if !FileManager.default.isReadableFile(atPath: inputFileName!.relativePath) {
            throw SnapCommandLineDriverError("input file is not readable: \(inputFileName!.relativePath)")
        }
    }
    
    func parseOutputFileName(_ fileName: String) throws {
        if programOutputFileName != nil {
            throw SnapCommandLineDriverError("output filename can only be specified one time.")
        }
        programOutputFileName = URL(fileURLWithPath: fileName)
        if !FileManager.default.fileExists(atPath: programOutputFileName!.deletingLastPathComponent().relativePath) {
            let name = programOutputFileName!.deletingLastPathComponent().relativePath
            throw SnapCommandLineDriverError("specified output directory does not exist: \(name)")
        }
        if FileManager.default.fileExists(atPath: programOutputFileName!.relativePath) {
            if !FileManager.default.isWritableFile(atPath: programOutputFileName!.relativePath) {
                let name = programOutputFileName!.relativePath
                throw SnapCommandLineDriverError("output file exists but is not writable: \(name)")
            }
        }
    }
}
