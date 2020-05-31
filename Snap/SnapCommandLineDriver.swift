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
        
        public init(format: String, _ args: CVarArg...) {
            message = String(format:format, arguments:args)
        }
    }
    
    public var status: Int32 = 1
    public var stdout: TextOutputStream = String()
    public var stderr: TextOutputStream = String()
    let arguments: [String]
    public private(set) var inputFileName: URL?
    public private(set) var outputFileName: URL?
    
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
        stderr.write("Error: " + message + "\n")
    }
    
    func tryRun() throws {
        try parseArguments()
        try writeToFile(instructions: try compile())
        status = 0
    }
    
    func compile() throws -> [Instruction] {
        let fileName = inputFileName!.relativePath
        let maybeText = String(data: try Data(contentsOf: inputFileName!), encoding: .utf8)
        guard let text = maybeText else {
            throw SnapCommandLineDriverError(format: "Failed to read input file as UTF-8 text: %@", fileName)
        }
        let frontEnd = SnapCompilerFrontEnd()
        frontEnd.compile(text)
        if frontEnd.hasError {
            throw CompilerError.makeOmnibusError(fileName: fileName, errors: frontEnd.errors)
        }
        return frontEnd.instructions
    }
    
    func writeToFile(instructions: [Instruction]) throws {
        let computer = Computer()
        computer.provideInstructions(instructions)
        try computer.saveProgram(to: outputFileName!)
    }
    
    public func parseArguments() throws {
        if (arguments.count != 3) {
            throw SnapCommandLineDriverError(format: "usage: Snap <INPUT> <OUTPUT>\nExpected two arguments, got \(arguments.count-1): \(arguments.debugDescription)")
        }
        
        try parseInputFileName()
        try parseOutputFileName()
    }

    func parseInputFileName() throws {
        inputFileName = URL(fileURLWithPath: arguments[1])
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: inputFileName!.relativePath, isDirectory: &isDirectory) {
            throw SnapCommandLineDriverError(format: "Input file does not exist: %@", inputFileName!.relativePath)
        }
        if (isDirectory.boolValue) {
            throw SnapCommandLineDriverError(format: "Input file is a directory: %@", inputFileName!.relativePath)
        }
        if !FileManager.default.isReadableFile(atPath: inputFileName!.relativePath) {
            throw SnapCommandLineDriverError(format: "Input file is not readable: %@", inputFileName!.relativePath)
        }
    }
    
    func parseOutputFileName() throws {
        outputFileName = URL(fileURLWithPath: arguments[2])
        if !FileManager.default.fileExists(atPath: outputFileName!.deletingLastPathComponent().relativePath) {
            throw SnapCommandLineDriverError(format: "Specified output directory does not exist: %@", outputFileName!.deletingLastPathComponent().relativePath)
        }
        if FileManager.default.fileExists(atPath: outputFileName!.relativePath) {
            if !FileManager.default.isWritableFile(atPath: outputFileName!.relativePath) {
                throw SnapCommandLineDriverError(format: "Output file exists but is not writable: %@", outputFileName!.relativePath)
            }
        }
    }
}
