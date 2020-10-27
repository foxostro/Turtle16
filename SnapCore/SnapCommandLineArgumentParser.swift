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

public class SnapCommandLineArgumentParser: NSObject {
    var args: [String]
    public enum Option: Equatable {
        case printHelp
        case inputFileName(String)
        case outputFileName(String)
        case S
        case ir
        case astDump
        case test
        case quiet
    }
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
        if args.first == "test" {
            try advance()
            options.append(.test)
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
        return args.first!
    }
    
    private func advance() throws {
        guard !args.isEmpty else {
            throw SnapCommandLineParserError.unexpectedEndOfInput
        }
        args.removeFirst()
    }
}
