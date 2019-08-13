//
//  AssemblerCommandLineDriver.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa
import Darwin

public class AssemblerCommandLineDriver: NSObject {
    public struct AssemblerCommandLineDriverError: Error {
        public let message: String
        
        public init(format: String, _ args: CVarArg...) {
            message = String(format:format, arguments:args)
        }
    }
    
    public var status: Int32 = 1
    let arguments: [String]
    var inputFileName: URL? = nil
    var outputFileName: URL? = nil
    
    public required init(withArguments arguments: [String]) {
        self.arguments = arguments
    }
    
    public func run() {
        do {
            try tryRun()
        } catch let error as AssemblerCommandLineDriverError {
            reportError(withMessage: error.message)
        } catch {
            reportError(withMessage: error.localizedDescription)
        }
    }
    
    func reportError(withMessage message: String) {
        fputs("Error: " + message + "\n", stderr)
    }
    
    func tryRun() throws {
        try parseArguments()
        status = 0
    }
    
    func parseArguments() throws {
        if (arguments.count != 3) {
            throw AssemblerCommandLineDriverError(format: "Expected two arguments, got %d:\n%@", arguments.count-1, arguments.joined(separator: " "))
        }
        
        try parseInputFileName()
        try parseOutputFileName()
    }

    func parseInputFileName() throws {
        inputFileName = URL(fileURLWithPath: arguments[1])
        print("inputFileName: " + inputFileName!.relativePath)
        if !FileManager.default.fileExists(atPath: inputFileName!.relativePath) {
            throw AssemblerCommandLineDriverError(format: "Input file does not exist: %@", inputFileName!.relativePath)
        }
        if !FileManager.default.isReadableFile(atPath: inputFileName!.relativePath) {
            throw AssemblerCommandLineDriverError(format: "Input file is not readable: %@", inputFileName!.relativePath)
        }
    }
    
    func parseOutputFileName() throws {
        outputFileName = URL(fileURLWithPath: arguments[2])
        print("outputFileName: " + outputFileName!.relativePath)
        if !FileManager.default.fileExists(atPath: outputFileName!.deletingLastPathComponent().relativePath) {
            throw AssemblerCommandLineDriverError(format: "Specified output directory does not exist: %@", outputFileName!.deletingLastPathComponent().relativePath)
        }
        if FileManager.default.fileExists(atPath: outputFileName!.relativePath) {
            if !FileManager.default.isWritableFile(atPath: outputFileName!.relativePath) {
                throw AssemblerCommandLineDriverError(format: "Output file exists but is not writable: %@", inputFileName!.relativePath)
            }
        }
    }
}
