//
//  AssemblerScanner.swift
//  TurtleTTL
//
//  Created by Andrew Fox on 8/20/19.
//  Copyright © 2019 Andrew Fox. All rights reserved.
//

import Cocoa

public class AssemblerScanner: TurtleScanner {
    public struct AssemblerScannerError: Error {
        public let line: Int
        public let message: String
        
        public init(line: Int, format: String, _ args: CVarArg...) {
            self.line = line
            message = String(format:format, arguments:args)
        }
    }
    
    struct Rule {
        let pattern: String
        let emit: (AssemblerScanner, String) -> AssemblerToken?
    }
    
    let rules: [Rule] = [
        Rule(pattern: ",") {
            AssemblerToken(type: .comma, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "\n") {
            let token = AssemblerToken(type: .newline, lineNumber: $0.lineNumber, lexeme: $1)
            $0.lineNumber += 1
            return token
        },
        Rule(pattern: "//") {(scanner: AssemblerScanner, lexeme: String) in
            scanner.advanceToNewline()
            return nil
        },
        Rule(pattern: "NOP") {
            AssemblerToken(type: .nop, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "CMP") {
            AssemblerToken(type: .cmp, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "HLT") {
            AssemblerToken(type: .hlt, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[_a-zA-Z][_a-zA-Z0-9]+") {
            AssemblerToken(type: .identifier, lineNumber: $0.lineNumber, lexeme: $1)
        },
        Rule(pattern: "[ \t]+") {(scanner: AssemblerScanner, lexeme: String) in
            nil
        }
    ]
    
    public private(set) var tokens: [AssemblerToken] = []
    var lineNumber = 1
    
    public func scanTokens() throws {
        while !isAtEnd {
            try scanToken()
        }
    }
    
    public func scanToken() throws {
        for rule in rules {
            if let lexeme = match(pattern: rule.pattern) {
                if let token = rule.emit(self, lexeme) {
                    tokens.append(token)
                }
                return
            }
        }
        
        throw unexpectedCharacterError(peek()!)
    }
    
    func emit(type: AssemblerToken.TokenType, lineNumber: Int, lexeme: String) {
        tokens.append(AssemblerToken(type: type, lineNumber: lineNumber, lexeme: lexeme))
    }
    
    func unexpectedCharacterError(_ character: String) -> AssemblerScannerError {
        return AssemblerScannerError(line: lineNumber, format: "unexpected character: `%@'", character)
    }
}
