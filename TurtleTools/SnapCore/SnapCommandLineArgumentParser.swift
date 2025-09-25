//
//  SnapCommandLineArgumentParser.swift
//  SnapCore
//
//  Created by Andrew Fox on 6/2/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

public enum SnapCommandLineParserError: Error, Equatable {
    case unexpectedEndOfInput
    case unknownOption(String)
}

public final class SnapCommandLineArgumentParser {
    public enum Option: Equatable {
        case printHelp
        case inputFileName(String)
        case outputFileName(String)
        case S
        case ir
        case astDump
        case test
        case chooseSpecificTest(String)
        case listTests
        case quiet
        case unoptimized
        case run
        case platform(String)
    }

    private var args: [String]
    public private(set) var options: [Option] = []

    public init(args: [String]) {
        self.args = args
    }

    public func parse() throws {
        try advance() // strip off the program name
        try parseOptions()
        try parseInputFilenames()
        if options.isEmpty {
            throw SnapCommandLineParserError.unexpectedEndOfInput
        }
    }

    private func parseOptions() throws {
        switch args.first {
        case "test":
            try advance()
            options.append(.test)

        case "run":
            try advance()
            options.append(.run)

        default:
            break // do nothing
        }

        while !args.isEmpty {
            let option = try peek()
            if !option.hasPrefix("-") {
                return
            }
            if option == "-h" {
                try advance()
                options.append(.printHelp)
            }
            else if option == "-o" {
                try advance()
                let fileName = try peek()
                try advance()
                options.append(.outputFileName(fileName))
            }
            else if option == "-S" {
                try advance()
                options.append(.S)
            }
            else if option == "-ast-dump" {
                try advance()
                options.append(.astDump)
            }
            else if option == "-ir" {
                try advance()
                options.append(.ir)
            }
            else if option == "-q" {
                try advance()
                options.append(.quiet)
            }
            else if option == "-t" {
                try advance()
                let testName = try peek()
                try advance()
                options.append(.chooseSpecificTest(testName))
            }
            else if option == "-listTests" {
                try advance()
                options.append(.listTests)
            }
            else if option == "-O0" {
                try advance()
                options.append(.unoptimized)
            }
            else if option == "--platform" {
                try advance()
                let platformName = try peek()
                try advance()
                options.append(.platform(platformName))
            }
            else {
                throw SnapCommandLineParserError.unknownOption(option)
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
            throw SnapCommandLineParserError.unexpectedEndOfInput
        }
        args.removeFirst()
    }
}
