//
//  AssemblerCommandLineDriver.swift
//  TurtleAssembler
//
//  Created by Andrew Fox on 8/1/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import TurtleCore
import TurtleSimulatorCore

/// Provides an interface for driving the assembler from the command-line.
public final class AssemblerCommandLineDriver {
    public struct AssemblerCommandLineDriverError: Error {
        public let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    let kEEPROMSize = 1 << 17

    public var status: Int32 = 1
    public var stdout: TextOutputStream = String()
    public var stderr: TextOutputStream = String()
    let arguments: [String]
    public private(set) var inputFileName: URL?
    public private(set) var outputFileName: URL?
    public var shouldBeQuiet = false

    public required init(withArguments arguments: [String]) {
        self.arguments = arguments
    }

    public func run() {
        do {
            try tryRun()
        }
        catch let error as AssemblerCommandLineDriverError {
            reportError(withMessage: error.message)
        }
        catch let error as CompilerError {
            reportError(withMessage: error.message)
        }
        catch {
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
        try writeToFile(instructions: try compile())
        status = 0
    }

    func compile() throws -> [UInt16] {
        let fileName = inputFileName!.relativePath
        let maybeText = String(data: try Data(contentsOf: inputFileName!), encoding: .utf8)
        guard let text = maybeText else {
            throw AssemblerCommandLineDriverError(
                "Failed to read input file as UTF-8 text: \(fileName)"
            )
        }
        let frontEnd = Assembler()
        frontEnd.compile(text)
        if frontEnd.hasError {
            throw CompilerError.makeOmnibusError(fileName: fileName, errors: frontEnd.errors)
        }
        return frontEnd.instructions
    }

    func writeToFile(instructions: [UInt16]) throws {
        var data = Data(count: kEEPROMSize)
        for i in 0..<instructions.count {
            let word = instructions[i]
            data[i * 2 + 0] = UInt8((word & 0xff00) >> 8)
            data[i * 2 + 1] = UInt8(word & 0x00ff)
        }
        try data.write(to: outputFileName!)
    }

    public func parseArguments() throws {
        let argParser = AssemblerCommandLineArgumentParser(args: arguments)
        do {
            try argParser.parse()
        }
        catch let error as AssemblerCommandLineParserError {
            switch error {
            case .unexpectedEndOfInput:
                throw AssemblerCommandLineDriverError(makeUsageMessage())
            case .unknownOption(let option):
                throw AssemblerCommandLineDriverError(
                    "unknown option `\(option)'\n\n\(makeUsageMessage())"
                )
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
                break  // do nothing

            case .inputFileName(let fileName):
                try parseInputFileName(fileName)

            case .outputFileName(let fileName):
                try parseOutputFileName(fileName)

            case .quiet:
                shouldBeQuiet = true
            }
        }

        if inputFileName == nil {
            throw AssemblerCommandLineDriverError("expected input filename")
        }

        let baseName: URL = inputFileName!.deletingPathExtension()

        if outputFileName == nil {
            outputFileName = baseName.appendingPathExtension("bin")
        }
    }

    func makeUsageMessage() -> String {
        """
        OVERVIEW: assembler for the Turtle16 computer

        USAGE:
        \(arguments[0]) [options] file...
                    
        OPTIONS:
        \t-h         Display available options
        \t-o <file>  Specify the output filename
        \t-q         Quiet. Do not print progress to stdout

        """
    }

    func parseInputFileName(_ fileName: String) throws {
        if inputFileName != nil {
            throw AssemblerCommandLineDriverError(
                "assembler currently only supports one input file at a time."
            )
        }
        inputFileName = URL(fileURLWithPath: fileName)
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(
            atPath: inputFileName!.relativePath,
            isDirectory: &isDirectory
        ) {
            throw AssemblerCommandLineDriverError(
                "input file does not exist: \(inputFileName!.relativePath)"
            )
        }
        if isDirectory.boolValue {
            throw AssemblerCommandLineDriverError(
                "input file is a directory: \(inputFileName!.relativePath)"
            )
        }
        if !FileManager.default.isReadableFile(atPath: inputFileName!.relativePath) {
            throw AssemblerCommandLineDriverError(
                "input file is not readable: \(inputFileName!.relativePath)"
            )
        }
    }

    func parseOutputFileName(_ fileName: String) throws {
        if outputFileName != nil {
            throw AssemblerCommandLineDriverError("output filename can only be specified one time.")
        }
        outputFileName = URL(fileURLWithPath: fileName)
        if !FileManager.default.fileExists(
            atPath: outputFileName!.deletingLastPathComponent().relativePath
        ) {
            let name = outputFileName!.deletingLastPathComponent().relativePath
            throw AssemblerCommandLineDriverError(
                "specified output directory does not exist: \(name)"
            )
        }
        if FileManager.default.fileExists(atPath: outputFileName!.relativePath) {
            if !FileManager.default.isWritableFile(atPath: outputFileName!.relativePath) {
                let name = outputFileName!.relativePath
                throw AssemblerCommandLineDriverError(
                    "output file exists but is not writable: \(name)"
                )
            }
        }
    }
}
