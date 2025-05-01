//
//  AssemblerCommandLineArgumentParser.swift
//  TurtleCore
//
//  Created by Andrew Fox on 2/2/24.
//  Copyright © 2024 Andrew Fox. All rights reserved.
//

public enum AssemblerCommandLineParserError: Error, Equatable {
    case unexpectedEndOfInput
    case unknownOption(String)
}

public final class AssemblerCommandLineArgumentParser {
    var args: [String]
    public enum Option: Equatable {
        case printHelp
        case inputFileName(String)
        case outputFileName(String)
        case quiet
    }
    public private(set) var options: [Option] = []

    public init(args: [String]) {
        self.args = args
    }

    public func parse() throws {
        try advance()  // strip off the program name
        try parseOptions()
        try parseInputFilenames()
        if options.isEmpty {
            throw AssemblerCommandLineParserError.unexpectedEndOfInput
        }
    }

    private func parseOptions() throws {
        while !args.isEmpty {
            let option = try peek()
            if !option.hasPrefix("-") {
                return
            }
            if option == "-h" {
                try advance()
                options.append(.printHelp)
            } else if option == "-o" {
                try advance()
                let fileName = try peek()
                try advance()
                options.append(.outputFileName(fileName))
            } else if option == "-q" {
                try advance()
                options.append(.quiet)
            } else {
                throw AssemblerCommandLineParserError.unknownOption(option)
            }
        }
    }

    private func parseInputFilenames() throws {
        while !args.isEmpty {
            let fileName = try peek()
            options.append(.inputFileName(fileName))
            try advance()
        }
    }

    private func peek() throws -> String {
        args.first!
    }

    private func advance() throws {
        guard !args.isEmpty else {
            throw AssemblerCommandLineParserError.unexpectedEndOfInput
        }
        args.removeFirst()
    }
}
